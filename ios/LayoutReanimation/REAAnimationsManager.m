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

@property (atomic, nullable) void(^startAnimationForTag)(NSNumber *, BOOL, NSDictionary *, NSNumber*);
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
  _startAnimationForTag = nil;
  _removeConfigForTag = nil;
  _blocksForTags = nil;
  _uiManager = nil;
}

- (void)notifyAboutChangeWithBeforeSnapshots:(REASnapshooter*)before afterSnapshooter:(REASnapshooter*)after
{
  REASnapshooter *prevBefore = _firstSnapshots[before.tag];
  REASnapshooter *prevAfter = _secondSnapshots[before.tag];
  // TODO: Do we want to sometimes skip an update?
  _firstSnapshots[before.tag] = before;
  _secondSnapshots[before.tag] = after;
  BOOL isMounting = true;
  if ([after.capturedValues count] == 0) {
    isMounting = false;
  }
  REASnapshooter *valueableSnapshooter = (isMounting)? after : before;
  UIView * rootView = valueableSnapshooter.listView.lastObject;
  NSDictionary * yogaValues = [self prepareDataForAnimatingWorklet: valueableSnapshooter.capturedValues[[REASnapshooter idFor:rootView]]];
  _startAnimationForTag(before.tag, isMounting, yogaValues, @(0));
}


- (void)addBlockOnAnimationEnd:(NSNumber*)tag block:(void (^)(void))block {
  if (!_blocksForTags[tag]) {
    _blocksForTags[tag] = [NSMutableArray new];
  }
  [_blocksForTags[tag] addObject:block];
}

- (void)setAnimationStartingBlock:(void (^)(NSNumber * tag, BOOL isMounting, NSDictionary* yogaValues, NSNumber* depth))startAnimation
{
  _startAnimationForTag = startAnimation;
}

- (void)setRemovingConfigBlock:(void (^)(NSNumber *tag))block
{
  _removeConfigForTag = block;
}

- (void)notifyAboutProgress:(NSDictionary *)newStyle tag:(NSNumber*)tag
{
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
      
      if ([view isKindOfClass:[REAAnimationRootView class]]) {
        [self setNewProps:[newStyle mutableCopy] forView:view withComponentData:componentData];
      }
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
      if ([view isKindOfClass:[REAAnimationRootView class]]) {
        [self setNewProps:[newStyle mutableCopy] forView:view withComponentData:componentData];
      }
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

- (NSDictionary*) prepareDataForAnimatingWorklet:(NSMutableDictionary*)values
{
  UIView *windowView = UIApplication.sharedApplication.keyWindow;
  NSDictionary* preparedData = @{
    @"width": values[@"width"],
    @"height": values[@"height"],
    @"originX": values[@"originX"],
    @"originY": values[@"originY"],
    @"globalOriginX": values[@"globalOriginX"],
    @"globalOriginY": values[@"globalOriginY"],
    @"windowWidth": [NSNumber numberWithDouble:windowView.bounds.size.width],
    @"windowHeight": [NSNumber numberWithDouble:windowView.bounds.size.height]
  };
  return preparedData;
}

@end
