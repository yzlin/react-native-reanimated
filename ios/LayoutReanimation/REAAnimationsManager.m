//
//  SnapshotsManager.m
//  RNReanimated
//
//  Created by Szymon Kapala on 24/03/2021.
//

#import "REAAnimationsManager.h"
#import <React/RCTComponentData.h>
#import "REAAnimationRootView.h"

@interface REAAnimationsManager ()

@property (atomic, nullable) void(^startAnimationForTag)(NSNumber *);
@property (atomic, nullable) NSMutableDictionary*(^getStyleWhileMounting)(NSNumber *, NSNumber*, NSDictionary*);
@property (atomic, nullable) NSMutableDictionary*(^getStyleWhileUnmounting)(NSNumber *, NSNumber*, NSDictionary*);
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

- (void)setAnimationMountingBlock:(NSMutableDictionary* (^)(NSNumber *tag, NSNumber* progress, NSDictionary* target))block
{
  _getStyleWhileMounting = block;
}

- (void)setAnimationUnmountingBlock:(NSMutableDictionary* (^)(NSNumber *tag, NSNumber* progress, NSDictionary* initial))block
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
  
  NSMutableSet<UIView *>* allViews = [NSMutableSet new];
  for (UIView *view in first.listView) {
    [allViews addObject:view];
  }
  for (UIView *view in second.listView) {
    [allViews addObject:view];
  }
  
  for (UIView *view in allViews) {
    NSMutableDictionary<NSString*, NSNumber*>* startValues = first.capturedValues[[NSValue valueWithNonretainedObject:view]];
    NSMutableDictionary<NSString*, NSNumber*>* targetValues = second.capturedValues[[NSValue valueWithNonretainedObject:view]];
    
    // TODO let ViewManager handle animation progress based on view snapshots
    if (startValues != nil && targetValues != nil) { //interpolate
      // TODO make it more flexiable
      // TODO interpolate transform matrix
      
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
      
      // only animated hightest appearing/disappearing view !!! Investigate if it's right approach
      // Maybe we should pass additional info to worklet if the a view is highest or not
      if (![view isKindOfClass:[REAAnimationRootView class]] && first.capturedValues[[NSValue valueWithNonretainedObject:targetValues[@"parent"]]] == nil) {
        continue;
      }
      
      NSMutableDictionary* newProps = _getStyleWhileMounting(tag, [NSNumber numberWithDouble:progress], targetValues);
      [self setNewProps:newProps forView:view withComponentData:componentData];
    }
    
    if (startValues != nil && targetValues == nil) { // disappearing
      // TODO allow nested AnimationRoots to disapprear diffrently
      
      // only animated hightest appearing/disappearing view !!! Investigate if it's right approach
      // Maybe we should pass additional info to worklet if the a view is highest or not
      if (![view isKindOfClass:[REAAnimationRootView class]] && first.capturedValues[[NSValue valueWithNonretainedObject:targetValues[@"parent"]]] == nil) {
        if (view.superview == nil) {
          [((UIView*)targetValues[@"parent"]) addSubview:view];
        }
        
        continue;
      }
      
      if (view.superview == nil) {
        startValues[@"originX"] = startValues[@"globalOriginX"];
        startValues[@"originY"] = startValues[@"globalOriginY"];
        
        UIView *windowView = UIApplication.sharedApplication.keyWindow;
        [windowView addSubview:view];
        
        [self addBlockOnAnimationEnd:tag block:^{
          [view removeFromSuperview];
        }];
      }
      
      NSMutableDictionary* newProps = _getStyleWhileUnmounting(tag, [NSNumber numberWithDouble:progress], targetValues);
      [self setNewProps:newProps forView:view withComponentData:componentData];
    }
  }
}

- (void)notifyAboutEnd:(NSNumber*)tag
{
  if (_blocksForTags[tag] != nil) {
    for (void(^block)(void) in _blocksForTags[tag]) {
      block();
    }
    [_blocksForTags removeObjectForKey:tag];
  }
  
  [_firstSnapshots removeObjectForKey:tag];
  [_secondSnapshots removeObjectForKey:tag];
}

- (void)setNewProps:(NSMutableDictionary *)newProps forView:(UIView*)view withComponentData:(RCTComponentData*)componentData
{
  if (newProps[@"height"]) {
    double height = [newProps[@"height"] doubleValue];
    view.bounds = CGRectMake(0, 0, view.bounds.size.width, height);
    [newProps removeObjectForKey:@"height"];
  }
  if (newProps[@"width"]) {
    double width = [newProps[@"width"] doubleValue];
    view.bounds = CGRectMake(0, 0, width, view.bounds.size.height);
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
