//
//  SnapshotsManager.m
//  RNReanimated
//
//  Created by Szymon Kapala on 24/03/2021.
//

#import "REAAnimationsManager.h"
#import <React/RCTComponentData.h>
#import "REAAnimationRootView.h"
#import "REAHeroView.h"

@interface REAAnimationsManager ()

@property (atomic, nullable) void(^startAnimationForTag)(NSNumber *);
@property (atomic, nullable) NSMutableDictionary*(^getStyleWhileMounting)(NSNumber *, NSNumber*, NSDictionary*, NSNumber*);
@property (atomic, nullable) NSMutableDictionary*(^getStyleWhileUnmounting)(NSNumber *, NSNumber*, NSDictionary*, NSNumber*);
@property (atomic, nullable) void(^removeConfigForTag)(NSNumber *);

@end

@implementation REAAnimationsManager {
  RCTUIManager* _uiManager;
  NSMutableDictionary<NSNumber*, REASnapshooter*>* _firstSnapshots;
  NSMutableDictionary<NSNumber*, REASnapshooter*>* _secondSnapshots;
  NSMutableDictionary<NSNumber*, NSMutableArray*>* _blocksForTags;
}

- (instancetype)initWithUIManager:(RCTUIManager *)uiManager
{
  if (self = [super init]) {
    _uiManager = uiManager;
    _firstSnapshots = [NSMutableDictionary new];
    _secondSnapshots = [NSMutableDictionary new];
    _blocksForTags = [NSMutableDictionary new];
  }
  return self;
}

- (void)invalidate
{
  _getStyleWhileUnmounting = nil;
  _getStyleWhileMounting = nil;
  _startAnimationForTag = nil;
  _removeConfigForTag = nil;
  _blocksForTags = nil;
  _uiManager = nil;
}

- (void)startAnimationWithFirstSnapshot:(REASnapshooter*)snapshooter
{
  _firstSnapshots[snapshooter.tag] = nil;
  _secondSnapshots[snapshooter.tag] = nil;
  _firstSnapshots[snapshooter.tag] = snapshooter;
  _startAnimationForTag(snapshooter.tag);
}

- (void)addSecondSnapshot:(REASnapshooter*)snapshooter
{
  _secondSnapshots[snapshooter.tag] = snapshooter;
  if ([snapshooter.capturedValues count] == 0) { // Root config should be removed on next unmounting animation
    [self addBlockOnAnimationEnd:snapshooter.tag block:^{
      _removeConfigForTag(snapshooter.tag);
    }];
  }
}

- (void)addBlockOnAnimationEnd:(NSNumber*)tag block:(void (^)(void))block {
  if (!_blocksForTags[tag]) {
    _blocksForTags[tag] = [NSMutableArray new];
  }
  [_blocksForTags[tag] addObject:block];
}

- (void)setAnimationStartingBlock:(void (^)(NSNumber *tag))startAnimation
{
  _startAnimationForTag = startAnimation;
}

- (void)setAnimationMountingBlock:(NSMutableDictionary* (^)(NSNumber *tag, NSNumber* progress, NSDictionary* target, NSNumber* depth))block
{
  _getStyleWhileMounting = block;
}

- (void)setAnimationUnmountingBlock:(NSMutableDictionary* (^)(NSNumber *tag, NSNumber* progress, NSDictionary* initial, NSNumber* depth))block
{
  _getStyleWhileUnmounting = block;
}

- (void)setRemovingConfigBlock:(void (^)(NSNumber *tag))block
{
  _removeConfigForTag = block;
}

- (void)notifyAboutProgress:(NSNumber*)progressNumber tag:(NSNumber*)tag
{
  double progress = [progressNumber doubleValue];
  NSLog(@"%@: %.21Lg", @"progress", (long double) progress);
  REASnapshooter* first = _firstSnapshots[tag];
  REASnapshooter* second = _secondSnapshots[tag];
  if (first == nil || second == nil) { // animation is not ready
    return;
  }
  
  NSMutableSet<NSString*>* allViewsSet = [NSMutableSet new];
  NSMutableArray<UIView *>* allViews = [NSMutableArray new];
  for (UIView *view in first.listView) {
    [allViews addObject:view];
    [allViewsSet addObject:[REASnapshooter idFor:view]];
  }
  for (UIView *view in second.listView) {
    if (![allViewsSet containsObject:[REASnapshooter idFor:view]]) {
      [allViewsSet addObject:[REASnapshooter idFor:view]];
      [allViews addObject:view];
    }
  }
  
  for (UIView *view in allViews) {
    NSMutableDictionary<NSString*, NSNumber*>* startValues = first.capturedValues[[REASnapshooter idFor:view]];
    NSMutableDictionary<NSString*, NSNumber*>* targetValues = second.capturedValues[[REASnapshooter idFor:view]];
    
    // TODO let ViewManager handle animation progress based on view snapshots
    if (startValues != nil && targetValues != nil) { //interpolate
      // TODO make it more flexiable
      // TODO interpolate transform matrix
      
      if ([view isKindOfClass:[REAHeroView class]] && !startValues[@"corrected"]) { // Hero changes origin
        startValues[@"corrected"] = @(YES);
        UIView *newParent = (UIView*)targetValues[@"parent"];
        UIView *windowView = UIApplication.sharedApplication.keyWindow;
        CGPoint point = CGPointMake([startValues[@"globalOriginX"] doubleValue], [startValues[@"globalOriginY"] doubleValue]);
        CGPoint correctedOrigin = [windowView convertPoint:point toView:newParent];
        startValues[@"originX"] = [NSNumber numberWithDouble:correctedOrigin.x];
        startValues[@"originY"] = [NSNumber numberWithDouble:correctedOrigin.y];
      }
      
      double currentWidth = [targetValues[@"width"] doubleValue] * progress + [startValues[@"width"] doubleValue] * (1.0 - progress);
      double currentHeight = [targetValues[@"height"] doubleValue] * progress + [startValues[@"height"] doubleValue] * (1.0 - progress);

      double currentX = [targetValues[@"originX"] doubleValue] * progress + [startValues[@"originX"] doubleValue] * (1.0 - progress);
      double currentY = [targetValues[@"originY"] doubleValue] * progress + [startValues[@"originY"] doubleValue] * (1.0 - progress);
      
      view.bounds = CGRectMake(0, 0, currentWidth, currentHeight);
      view.center = CGPointMake(currentX + currentWidth/2.0, currentY + currentHeight/2.0);
    }
    // Let's assume for now that this is a View componenet
    NSMutableDictionary* dataComponenetsByName = [_uiManager valueForKey:@"_componentDataByName"];
    RCTComponentData *componentData = dataComponenetsByName[@"RCTView"];
    
    if (startValues == nil && targetValues != nil) { // appearing
      
      double depth = 0; // distance to lowest appearing ancestor or AnimatedRoot
      if (targetValues[@"depth"] == nil) {
        UIView *lowestAppearingAncestor = view;
        while (![lowestAppearingAncestor isKindOfClass:[REAAnimationRootView class]] && first.capturedValues[[REASnapshooter idFor:lowestAppearingAncestor.superview]] == nil) {
          lowestAppearingAncestor = lowestAppearingAncestor.superview;
          depth++;
        }
        targetValues[@"depth"] = [NSNumber numberWithDouble:depth];
      }
      depth = [targetValues[@"depth"] doubleValue];
    
      NSMutableDictionary* newProps = _getStyleWhileMounting(tag, [NSNumber numberWithDouble:progress], targetValues, [NSNumber numberWithDouble: depth]);
      [self setNewProps:newProps forView:view withComponentData:componentData];
    }
    
    if (startValues != nil && targetValues == nil) { // disappearing
      // TODO allow nested AnimationRoots to disapprear diffrently
      
      double depth = 0; // distance to lowest appearing ancestor or AnimatedRoot
      if (startValues[@"depth"] == nil) {
        UIView *lowestDisappearingAncestor = view;
        while (![lowestDisappearingAncestor isKindOfClass:[REAAnimationRootView class]] && second.capturedValues[[REASnapshooter idFor:(UIView*)first.capturedValues[[REASnapshooter idFor: lowestDisappearingAncestor]][@"parent"]]] == nil) {
          lowestDisappearingAncestor = (UIView*)first.capturedValues[[REASnapshooter idFor: lowestDisappearingAncestor]][@"parent"];
          depth++;
        }
        startValues[@"depth"] = [NSNumber numberWithDouble:depth];
        
        if ([view isKindOfClass:[REAAnimationRootView class]] && first.capturedValues[[REASnapshooter idFor:(UIView*)startValues[@"parent"]]] == nil) {
          // If I'm a root and I don't have any roots above me
          
          if (view.superview == nil) {
            NSMutableArray * viewsToDetach = [NSMutableArray new];
            
            NSMutableArray * pathToWindow = ((NSMutableArray *)startValues[@"pathToWindow"]);
            for (int i = 1; i < [pathToWindow count]; ++i) {
              UIView *current = pathToWindow[i-1];
              
              if (current != view && [current isKindOfClass:[REAAnimationRootView class]]) {
                break;
              }
              
              UIView *nextView = pathToWindow[i];
              if (current.superview == nil) {
                [viewsToDetach addObject:current];
                [nextView addSubview:current];
              }
            }
            
            [self addBlockOnAnimationEnd:tag block:^{
              for (UIView * current in viewsToDetach) {
                [current removeFromSuperview];
              }
            }];
          }
          
        } else {
          if (view.superview == nil) {
            [((UIView*)startValues[@"parent"]) addSubview:view];
            [self addBlockOnAnimationEnd:tag block:^{
              [view removeFromSuperview];
            }];
          }

        }
      }
      depth = [startValues[@"depth"] doubleValue];
      
      NSMutableDictionary* newProps = _getStyleWhileUnmounting(tag, [NSNumber numberWithDouble:progress], startValues, startValues[@"depth"]);
      [self setNewProps:newProps forView:view withComponentData:componentData];
    }
  }
}

- (void)notifyAboutEnd:(NSNumber*)tag cancelled:(BOOL)cancelled
{
  if (_blocksForTags[tag] != nil) {
    for (void(^block)(void) in _blocksForTags[tag]) {
      block();
    }
    [_blocksForTags removeObjectForKey:tag];
  }
  
  if (!cancelled) {
    [_firstSnapshots removeObjectForKey:tag];
    [_secondSnapshots removeObjectForKey:tag];
  }
  
}

- (void)setNewProps:(NSMutableDictionary *)newProps forView:(UIView*)view withComponentData:(RCTComponentData*)componentData
{
  if (newProps[@"height"]) {
    double height = [newProps[@"height"] doubleValue];
    double oldHeight = view.bounds.size.height;
    view.bounds = CGRectMake(0, 0, view.bounds.size.width, height);
    view.center = CGPointMake(view.center.x, view.center.y - oldHeight/2.0 + view.bounds.size.height/2.0);
    [newProps removeObjectForKey:@"height"];
  }
  if (newProps[@"width"]) {
    double width = [newProps[@"width"] doubleValue];
    double oldWidth = view.bounds.size.width;
    view.bounds = CGRectMake(0, 0, width, view.bounds.size.height);
    view.center = CGPointMake(view.center.x + view.bounds.size.width/2.0 - oldWidth/2.0, view.center.y);
    [newProps removeObjectForKey:@"width"];
  }
  if (newProps[@"originX"]) {
    double originX = [newProps[@"originX"] doubleValue];
    view.center = CGPointMake(originX + view.bounds.size.width/2.0, view.center.y);
    [newProps removeObjectForKey:@"originX"];
  }
  if (newProps[@"originY"]) {
    double originY = [newProps[@"originY"] doubleValue];
    view.center = CGPointMake(view.center.x, originY + view.bounds.size.height/2.0);
    [newProps removeObjectForKey:@"originY"];
  }
  [componentData setProps:newProps forView:view];

}

@end
