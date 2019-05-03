#import <React/RCTViewManager.h>
#import <React/RCTBorderDrawing.h>

#import "REAAllTransitions.h"
#import "RCTConvert+REATransition.h"

@interface REAMaskRemover : NSObject <CAAnimationDelegate>
@end

@implementation REAMaskRemover {
  CALayer *_layer;
}

- (instancetype)initWithLayer:(CALayer *)layer;
{
  self = [super init];
  if (self) {
    _layer = layer;
  }
  return self;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
  if (flag) {
    _layer.mask = nil;
  }
}

@end


@interface REASnapshotRemover : NSObject <CAAnimationDelegate>
@end

@implementation REASnapshotRemover {
  UIView *_view;
}

- (instancetype)initWithView:(UIView *)view;
{
  self = [super init];
  if (self) {
    _view = view;
  }
  return self;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
  [_view removeFromSuperview];
}

@end

@implementation REATransitionGroup

- (instancetype)initWithConfig:(NSDictionary *)config
{
  if (self = [super initWithConfig:config]) {
    _sequence = [RCTConvert BOOL:config[@"sequence"]];
    NSArray *transitions = [RCTConvert NSArray:config[@"transitions"]];
    NSMutableArray<REATransition*> *inflated = [NSMutableArray new];
    for (NSDictionary *transitionConfig in transitions) {
      [inflated addObject:[REATransition inflate:transitionConfig]];
      inflated.lastObject.parent = self;
    }
    _transitions = inflated;
  }
  return self;
}

- (instancetype)init
{
  if (self = [super init]) {
    _transitions = [NSMutableArray new];
  }
  return self;
}

- (NSArray<REATransitionAnimation *> *)animationsForTransitioning:(NSMutableDictionary<NSNumber *,REATransitionValues *> *)startValues
                                                           endValues:(NSMutableDictionary<NSNumber *,REATransitionValues *> *)endValues
                                                             forRoot:(UIView *)root
{
  CFTimeInterval delay = self.delay;
  NSMutableArray *animations = [NSMutableArray new];
  for (REATransition *transition in _transitions) {
    NSArray *subanims = [transition animationsForTransitioning:startValues endValues:endValues forRoot:root];
    CFTimeInterval finishTime = CACurrentMediaTime();
    for (REATransitionAnimation *anim in subanims) {
      [anim delayBy:delay];
      finishTime = MAX(finishTime, anim.finishTime);
    }
    [animations addObjectsFromArray:subanims];
    if (_sequence) {
      delay = finishTime - CACurrentMediaTime();
    }
  }
  return animations;
}

@end


@implementation REAVisibilityTransition

- (instancetype)initWithConfig:(NSDictionary *)config
{
  if (self = [super initWithConfig:config]) {
    _animationType = [RCTConvert REATransitionAnimationType:config[@"animation"]];
  }
  return self;
}

- (REATransitionAnimation *)appearView:(UIView *)view
                                 inParent:(UIView *)parent
                                  forRoot:(UIView *)root
{
  return nil;
}

- (REATransitionAnimation *)disappearView:(UIView *)view
                                  fromParent:(UIView *)parent
                                     forRoot:(UIView *)root
{
  return nil;
}

- (REATransitionAnimation *)animationForTransitioning:(REATransitionValues *)startValues
                                            endValues:(REATransitionValues *)endValues
                                              forRoot:(UIView *)root
{
  BOOL isViewAppearing = (startValues == nil);
  if (isViewAppearing && !IS_LAYOUT_ONLY(endValues.view)) {
    NSNumber *parentKey = endValues.reactParent.reactTag;
    REATransitionValues *parentStartValues = [self findStartValuesForKey:parentKey];
    REATransitionValues *parentEndValues = [self findEndValuesForKey:parentKey];
    BOOL isParentAppearing = (parentStartValues == nil && parentEndValues != nil);
    if (!isParentAppearing) {
      return [self appearView:endValues.view inParent:endValues.parent forRoot:root];
    }
  }

  if (endValues == nil && !IS_LAYOUT_ONLY(startValues.view) && startValues.reactParent.window != nil) {
    startValues.view.center = startValues.centerInReactParent;
    return [self disappearView:startValues.view fromParent:startValues.reactParent forRoot:root];
  }
  return nil;
}

@end


@implementation REAInTransition
- (instancetype)initWithConfig:(NSDictionary *)config
{
  if (self = [super initWithConfig:config]) {
  }
  return self;
}

- (REATransitionAnimation *)appearMasked:(UIView *)view
{
  CABasicAnimation *animation;
  CGPathRef startPath, endPath;
  switch (self.animationType) {
    case REATransitionAnimationTypeCircle: {
      CGFloat radius = hypot(view.frame.size.width, view.frame.size.height);
//      startPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 0, 0)].CGPath;
//      endPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(-radius, -radius, 2 * radius, 2 * radius)].CGPath;
      startPath = CGPathCreateWithRect(CGRectMake(0, 0, 0, 0), nil);
      endPath = CGPathCreateWithRect(CGRectMake(0, 0, view.frame.size.width, view.frame.size.height), nil);
      break;
    }
    default:
      return nil;
  }

  CAShapeLayer *mask = [CAShapeLayer new];
  mask.path = endPath;
  mask.backgroundColor = [UIColor blackColor].CGColor;

  animation = [CABasicAnimation animationWithKeyPath:@"path"];
  animation.fromValue = (__bridge id)startPath;
  animation.toValue = (__bridge id)endPath;
  animation.fillMode = kCAFillModeBackwards;
  animation.delegate = [[REAMaskRemover alloc] initWithLayer:view.layer];
  view.layer.mask = mask;

  return [REATransitionAnimation transitionWithAnimation:animation layer:mask andKeyPath:animation.keyPath];
}

- (REATransitionAnimation *)appearView:(UIView *)view
                              inParent:(UIView *)parent
                               forRoot:(UIView *)root
{
  CABasicAnimation *animation;
  switch (self.animationType) {
    case REATransitionAnimationTypeNone:
      return nil;
    case REATransitionAnimationTypeCircle:
      return [self appearMasked:view];
    case REATransitionAnimationTypeFade: {
      CGFloat finalOpacity = view.layer.opacity;
      animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
      animation.fromValue = @(0.0f);
      animation.toValue = @(finalOpacity);
      break;
    }
    case REATransitionAnimationTypeScale: {
      CATransform3D finalTransform = view.layer.transform;
      animation = [CABasicAnimation animationWithKeyPath:@"transform"];
      animation.fromValue = @(CATransform3DMakeScale(0, 0, 0));
      animation.toValue = @(finalTransform);
      break;
    }
    case REATransitionAnimationTypeSlideTop:
    case REATransitionAnimationTypeSlideBottom:
    case REATransitionAnimationTypeSlideLeft:
    case REATransitionAnimationTypeSlideRight: {
      CGPoint finalPosition = view.layer.position;
      CGPoint startPosition = finalPosition;
      switch (self.animationType) {
        case REATransitionAnimationTypeSlideTop:
          startPosition.y -= root.frame.size.height;
          break;
        case REATransitionAnimationTypeSlideBottom:
          startPosition.y += root.frame.size.height;
          break;
        case REATransitionAnimationTypeSlideLeft:
          startPosition.x -= root.frame.size.width;
          break;
        case REATransitionAnimationTypeSlideRight:
          startPosition.x += root.frame.size.width;
          break;
      }
      animation = [CABasicAnimation animationWithKeyPath:@"position"];
      animation.fromValue = @(startPosition);
      animation.toValue = @(finalPosition);
      break;
    }
  }
  animation.fillMode = kCAFillModeBackwards;

  return [REATransitionAnimation transitionWithAnimation:animation layer:view.layer andKeyPath:animation.keyPath];
}
@end


@implementation REAOutTransition
- (instancetype)initWithConfig:(NSDictionary *)config
{
  if (self = [super initWithConfig:config]) {
  }
  return self;
}

- (REATransitionAnimation *)disappearMasked:(UIView *)view
{
  CABasicAnimation *animation;
  CGPathRef startPath, endPath;
  switch (self.animationType) {
    case REATransitionAnimationTypeCircle: {
      CGFloat radius = hypot(view.frame.size.width, view.frame.size.height);
      startPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(-radius, -radius, 2 * radius, 2 * radius)].CGPath;
      endPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 0, 0)].CGPath;
      break;
    }
    default:
      return nil;
  }

  CAShapeLayer *mask = [CAShapeLayer new];
  mask.path = endPath;
  mask.backgroundColor = [UIColor blackColor].CGColor;

  animation = [CABasicAnimation animationWithKeyPath:@"path"];
  animation.fromValue = (__bridge id)startPath;
  animation.toValue = (__bridge id)endPath;
  animation.fillMode = kCAFillModeBackwards;
  animation.delegate = [[REASnapshotRemover alloc] initWithView:view];
  view.layer.mask = mask;

  return [REATransitionAnimation transitionWithAnimation:animation layer:mask andKeyPath:animation.keyPath];
}

- (REATransitionAnimation *)disappearView:(UIView *)view
                               fromParent:(UIView *)parent
                                  forRoot:(UIView *)root
{
  if (self.animationType == REATransitionAnimationTypeNone) {
    return nil;
  }
  // Add view back to parent temporarily in order to take snapshot
  [parent addSubview:view];
  UIView *snapshotView = [view snapshotViewAfterScreenUpdates:NO];
  [view removeFromSuperview];
  snapshotView.frame = view.frame;
  [parent addSubview:snapshotView];
  CALayer *snapshot = snapshotView.layer;

  CABasicAnimation *animation;
  switch (self.animationType) {
    case REATransitionAnimationTypeFade: {
      CGFloat fromValue = snapshot.opacity;
      snapshot.opacity = 0.0f;
      animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
      animation.fromValue = @(fromValue);
      animation.toValue = @(0.0f);
      break;
    }
    case REATransitionAnimationTypeScale: {
      CATransform3D fromValue = snapshot.transform;
      snapshot.transform = CATransform3DMakeScale(0.001, 0.001, 0.001);
      animation = [CABasicAnimation animationWithKeyPath:@"transform"];
      animation.fromValue = @(fromValue);
      animation.toValue = @(CATransform3DMakeScale(0.001, 0.001, 0.001));
      break;
    }
    case REATransitionAnimationTypeCircle:
      return [self disappearMasked:snapshotView];
    case REATransitionAnimationTypeSlideTop:
    case REATransitionAnimationTypeSlideBottom:
    case REATransitionAnimationTypeSlideLeft:
    case REATransitionAnimationTypeSlideRight: {
      CGPoint startPosition = snapshot.position;
      CGPoint finalPosition = startPosition;
      switch (self.animationType) {
        case REATransitionAnimationTypeSlideTop:
          finalPosition.y -= root.frame.size.height;
          break;
        case REATransitionAnimationTypeSlideBottom:
          finalPosition.y += root.frame.size.height;
          break;
        case REATransitionAnimationTypeSlideLeft:
          finalPosition.x -= root.frame.size.width;
          break;
        case REATransitionAnimationTypeSlideRight:
          finalPosition.x += root.frame.size.width;
          break;
      }
      snapshot.position = finalPosition;
      animation = [CABasicAnimation animationWithKeyPath:@"position"];
      animation.fromValue = @(startPosition);
      animation.toValue = @(finalPosition);
      break;
    }
  }
  animation.fillMode = kCAFillModeBackwards;
  animation.delegate = [[REASnapshotRemover alloc] initWithView:snapshotView];

  return [REATransitionAnimation transitionWithAnimation:animation layer:snapshot andKeyPath:animation.keyPath];
}
@end


@implementation REAChangeTransition

- (REATransitionAnimation *)animationForTransitioning:(REATransitionValues *)startValues
                                            endValues:(REATransitionValues *)endValues
                                              forRoot:(UIView *)root
{
  if (startValues == nil || endValues == nil || endValues.view.window == nil) {
    return nil;
  }
  BOOL animatePosition = !CGPointEqualToPoint(startValues.center, endValues.center);
  BOOL animateBounds = !CGRectEqualToRect(startValues.bounds, endValues.bounds);
  BOOL animateBackgroundColor = !CGColorEqualToColor(startValues.backgroundColor, endValues.backgroundColor);
  BOOL animateZPosition = startValues.zPosition != endValues.zPosition;
  BOOL animateCornerRadius = startValues.cornerRadius != endValues.cornerRadius;
  BOOL animateShadowPath = !CGPathEqualToPath(startValues.shadowPath, endValues.shadowPath);
  BOOL animateShadowOpacity = startValues.shadowOpacity != endValues.shadowOpacity;
  BOOL animateShadowOffset = !CGSizeEqualToSize(startValues.shadowOffset, endValues.shadowOffset);

  if (!animatePosition && !animateBounds && !animateBackgroundColor && !animateCornerRadius && !animateShadowPath && !animateShadowOpacity && !animateShadowOffset) {
    return nil;
  }

  CALayer *layer = endValues.view.layer;

  CAAnimationGroup *group = [CAAnimationGroup animation];
  group.fillMode = kCAFillModeBackwards;

  NSMutableArray *animations = [NSMutableArray new];

  if (animatePosition) {
    CGPoint fromValue = layer.presentationLayer.position;
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.fromValue = [NSValue valueWithCGPoint:fromValue];
    animation.toValue = [NSValue valueWithCGPoint:endValues.center];
    [animations addObject:animation];
  }

  if (animateBounds) {
    CGRect fromValue = layer.presentationLayer.bounds;
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"bounds"];
    animation.fromValue = [NSValue valueWithCGRect:fromValue];
    animation.toValue = [NSValue valueWithCGRect:endValues.bounds];
    [animations addObject:animation];
  }

  if (animateBackgroundColor) {
    CGColorRef fromValue = layer.presentationLayer.backgroundColor;
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    animation.fromValue = (__bridge id)fromValue;
    animation.toValue = (__bridge id)endValues.backgroundColor;
    [animations addObject:animation];
  }

  if (animateZPosition) {
    CGFloat fromValue = layer.presentationLayer.zPosition;
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"zPosition"];
    animation.fromValue = @(fromValue);
    animation.toValue = @(endValues.zPosition);
    [animations addObject:animation];
  }

  if (animateCornerRadius) {
    CGFloat fromValue = layer.presentationLayer.cornerRadius;
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
    animation.fromValue = @(fromValue);
    animation.toValue = @(endValues.cornerRadius);
    [animations addObject:animation];
  }

  if (animateShadowPath) {
    CGPathRef fromValue = layer.presentationLayer.shadowPath;
    CGPathRef toValue = endValues.shadowPath;
    if (fromValue == nil) {
      // shadow will appear
      CGFloat cornerRadius = layer.presentationLayer.cornerRadius;
      const RCTCornerRadii cornerRadii = (RCTCornerRadii){
        cornerRadius,
        cornerRadius,
        cornerRadius,
        cornerRadius
      };
      const RCTCornerInsets cornerInsets = RCTGetCornerInsets(cornerRadii, UIEdgeInsetsZero);
      fromValue = RCTPathCreateWithRoundedRect(layer.presentationLayer.bounds, cornerInsets, NULL);
      // we retain "toValue" so that we can release both to and from values at the end
      CGPathRetain(toValue);
      // make sure shadow offset stays the same
      animateShadowOffset = YES;
      startValues.shadowOffset = endValues.shadowOffset;
    } else if (toValue == nil) {
      // shadow is disappearing
      CGFloat cornerRadius = endValues.cornerRadius;
      const RCTCornerRadii cornerRadii = (RCTCornerRadii){
        cornerRadius,
        cornerRadius,
        cornerRadius,
        cornerRadius
      };
      const RCTCornerInsets cornerInsets = RCTGetCornerInsets(cornerRadii, UIEdgeInsetsZero);
      toValue = RCTPathCreateWithRoundedRect(endValues.bounds, cornerInsets, NULL);
      // we retain "fromValue" so that we can release both to and from values at the end
      CGPathRetain(fromValue);
      // make sure shadow offset stays the same
      animateShadowOffset = YES;
      endValues.shadowOffset = startValues.shadowOffset;
    } else {
      // retain both to and from values so that we can release them both
      // w/o adding extra checks
      CGPathRetain(fromValue);
      CGPathRetain(toValue);
    }
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"shadowPath"];
    animation.fromValue = (__bridge id)fromValue;
    animation.toValue = (__bridge id)toValue;
    [animations addObject:animation];
    // we update toValue here as in case of hiding shadow the path stays untouched
    // which causes weird articatcs when attempting to animate it back in
    layer.shadowPath = toValue;
    CGPathRelease(fromValue);
    CGPathRelease(toValue);
  }

  if (animateShadowOpacity) {
    CGFloat fromValue = layer.presentationLayer.shadowOpacity;
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
    animation.fromValue = @(fromValue);
    animation.toValue = @(endValues.shadowOpacity);
    [animations addObject:animation];
  }

  if (animateShadowOffset) {
    CGSize fromValue = layer.presentationLayer.shadowOffset;
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"shadowOffset"];
    animation.fromValue = @(fromValue);
    animation.toValue = @(endValues.shadowOffset);
    [animations addObject:animation];
  }

  group.animations = animations;
  return [REATransitionAnimation transitionWithAnimation:group layer:layer andKeyPath:nil];
}
@end
