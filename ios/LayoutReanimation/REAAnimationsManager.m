//
//  SnapshotsManager.m
//  RNReanimated
//
//  Created by Szymon Kapala on 24/03/2021.
//

#import "REAAnimationsManager.h"
#import <React/RCTComponentData.h>

@interface REAAnimationsManager ()

@property (atomic, nullable) void(^startAnimationForTag)(NSNumber *);
@property (atomic, nullable) NSMutableDictionary*(^getStyleWhileMounting)(NSNumber *, NSNumber*);
@property (atomic, nullable) NSMutableDictionary*(^getStyleWhileUnmounting)(NSNumber *, NSNumber*);

@end

@implementation REAAnimationsManager {
  RCTUIManager* _uiManager;
  NSMutableDictionary<NSNumber*, REASnapshooter*>* _firstSnapshots;
  NSMutableDictionary<NSNumber*, REASnapshooter*>* _secondSnapshots;
}

- (instancetype)initWithUIManager:(RCTUIManager *)uiManager
{
  if (self = [super init]) {
    _uiManager = uiManager;
    _firstSnapshots = [NSMutableDictionary new];
    _secondSnapshots = [NSMutableDictionary new];
  }
  return self;
}

- (void)invalidate
{
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
    // TODO
  }
}

- (void)setAnimationStartingBlock:(void (^)(NSNumber *tag))startAnimation
{
  _startAnimationForTag = startAnimation;
}

- (void)setAnimationMountingBlock:(NSMutableDictionary* (^)(NSNumber *tag, NSNumber* progress))block
{
  _getStyleWhileMounting = block;
}

- (void)setAnimationUnmountingBlock:(NSMutableDictionary* (^)(NSNumber *tag, NSNumber* progress))block
{
  _getStyleWhileUnmounting = block;
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
    NSDictionary<NSString*, NSNumber*>* startValues = first.capturedValues[[NSValue valueWithNonretainedObject:view]];
    NSDictionary<NSString*, NSNumber*>* targetValues = second.capturedValues[[NSValue valueWithNonretainedObject:view]];
    
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
      NSMutableDictionary* newProps = _getStyleWhileMounting(tag, [NSNumber numberWithDouble:progress]);
      /*if (newProps[@"height"]) {
        double height = newProps[@"height"];
        //TODO
        [newProps removeObjectForKey:@"height"];
      }
      if (newProps[@"width"]) {
        double width = newProps[@"width"];
        //TODO
        [newProps removeObjectForKey:@"width"];
      }
      if (newProps[@"originX"]) {
        double originX = newProps[@"originX"];
        //TODO
        [newProps removeObjectForKey:@"originX"];
      }
      if (newProps[@"originY"]) {
        double originY = newProps[@"originY"];
        //TODO
        [newProps removeObjectForKey:@"originY"];
      }*/
      [componentData setProps:newProps forView:view];
    }
    
    if (startValues != nil && targetValues == nil) { // disappearing
      //NSDictionary* newProps = _getStyleWhileUnmounting(tag, [NSNumber numberWithDouble:progress]);
    }
  }
}

- (void)notifyAboutEnd:(NSNumber*)tag
{
  [_firstSnapshots removeObjectForKey:tag];
  [_secondSnapshots removeObjectForKey:tag];
}

@end
