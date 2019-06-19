#import "REATransitionManager.h"

#import <React/RCTUIManager.h>
#import <React/RCTUIManagerObserverCoordinator.h>

#import "REATransition.h"
#import "REAAllTransitions.h"

@interface REATransitionManager () <RCTUIManagerObserver>
@end

@implementation REATransitionManager {
  NSMutableArray<REATransition *> *_pendingTransitions;
  RCTUIManager *_uiManager;
}

- (instancetype)initWithUIManager:(id)uiManager
{
  if (self = [super init]) {
    _uiManager = uiManager;
    _pendingTransitions = [NSMutableArray new];
  }
  return self;
}

- (void)scheduleTransitionCallbacks
{
  [_uiManager.observerCoordinator addObserver:self];
  [_uiManager prependUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,UIView *> *viewRegistry) {
    for (REATransition *transition in [_pendingTransitions reverseObjectEnumerator]) {
      [transition startCaptureWithViewRegistry:viewRegistry];
    }
  }];
  __weak id weakSelf = self;
  [_uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,UIView *> *viewRegistry) {
    [uiManager.observerCoordinator removeObserver:weakSelf];
  }];
}

- (void)enqueueTransition:(REATransition *)transition
{
  [_pendingTransitions addObject:transition];
  if (_pendingTransitions.count == 1) {
    // if it is the first transition enqueued in this frame we need to schedule calls to
    // begin and play transitions
    [self scheduleTransitionCallbacks];
  }
}

- (void)uiManagerWillPerformMounting:(RCTUIManager *)manager
{
  [manager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,UIView *> *viewRegistry) {
    for (REATransition *transition in [_pendingTransitions reverseObjectEnumerator]) {
      [transition playWithViewRegistry:viewRegistry];
    }
    [_pendingTransitions removeAllObjects];
  }];
}

- (void)animateNextTransitionInRoot:(NSNumber *)reactTag withConfig:(NSDictionary *)config
{
}

- (void)animateChange:(NSNumber *)reactTag withConfig:(NSDictionary *)config
{
//  if ([config[@"crossfade"] boolValue]) {
//    REACrossfadeTransition *transition = [[REACrossfadeTransition alloc] initWithConfig:nil];
//    transition.targetTags = @[reactTag];
//    [self enqueueTransition:transition];
//  } else {
    REAChangeTransition *transition = [[REAChangeTransition alloc] initWithConfig:nil];
    transition.targetTags = @[reactTag];
    [self enqueueTransition:transition];
//  }
}

- (void)animateAppear:(NSNumber *)reactTag withConfig:(NSDictionary *)config
{
  if (config[@"transitionFrom"] != nil) {
    REAChangeTransition *transition = [[REAChangeTransition alloc] initWithConfig:nil];
    transition.targetTags = @[reactTag, config[@"transitionFrom"]];
    transition.targetMapping = @{config[@"transitionFrom"]: reactTag};
    [self enqueueTransition:transition];
  } else {
    REAInTransition *transition = [[REAInTransition alloc] initWithConfig:nil];
    transition.targetTags = @[reactTag];
    transition.animationType = REATransitionAnimationTypeFade;
    [self enqueueTransition:transition];
  }
}

- (void)animateDisappear:(NSNumber *)reactTag withConfig:(NSDictionary *)config
{
  if (config[@"transitionFrom"] != nil) {
    REAChangeTransition *transition = [[REAChangeTransition alloc] initWithConfig:nil];
    transition.targetTags = @[reactTag, config[@"transitionFrom"]];
    transition.targetMapping = @{reactTag: config[@"transitionFrom"]};
    [self enqueueTransition:transition];
  } else {
    REAOutTransition *transition = [[REAOutTransition alloc] initWithConfig:nil];
    transition.animationType = REATransitionAnimationTypeFade;
    transition.targetTags = @[reactTag];
    [self enqueueTransition:transition];
  }
}

@end
