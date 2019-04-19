#import <UIKit/UIKit.h>
#include <dlfcn.h>

#import "REATransitionAnimation.h"

#define DEFAULT_DURATION 0.25

CGFloat SimulatorAnimationDragCoefficient(void) {
#if TARGET_IPHONE_SIMULATOR
  static float (*dragCoeffFunc)(void) = NULL;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    dragCoeffFunc = (float (*)(void))dlsym(RTLD_DEFAULT, "UIAnimationDragCoefficient");
  });
  return dragCoeffFunc ? dragCoeffFunc() : 1.f;
#else
  return 1.f;
#endif
}

@implementation REATransitionAnimation {
  NSTimeInterval _delay;
}

+ (REATransitionAnimation *)transitionWithAnimation:(CAAnimation *)animation
                                              layer:(CALayer *)layer
                                         andKeyPath:(NSString*)keyPath;
{
  REATransitionAnimation *anim = [REATransitionAnimation new];
  anim.animation = animation;
  anim.layer = layer;
  anim.keyPath = keyPath;
  return anim;
}

- (void)play
{
  _animation.duration = self.duration * SimulatorAnimationDragCoefficient();
  _animation.beginTime = CACurrentMediaTime() + _delay * SimulatorAnimationDragCoefficient();
  [_layer addAnimation:_animation forKey:_keyPath];
}

- (void)delayBy:(CFTimeInterval)delay
{
  if (delay <= 0) {
    return;
  }
  _delay += delay;
}

- (CFTimeInterval)duration
{
  if (_animation.duration == 0) {
    return DEFAULT_DURATION;
  }
  return _animation.duration;
}

- (CFTimeInterval)finishTime
{
  if (_animation.beginTime == 0) {
    return CACurrentMediaTime() + self.duration + _delay;
  }
  return _animation.beginTime + self.duration + _delay;
}

@end
