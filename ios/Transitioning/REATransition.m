#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <React/RCTConvert.h>
#import <React/RCTViewManager.h>

#import "REATransition.h"
#import "REATransitionValues.h"
#import "REAAllTransitions.h"
#import "RCTConvert+REATransition.h"

#define DEFAULT_PROPAGATION_SPEED 3

typedef NSMutableDictionary<NSNumber*, REATransitionValues*> REAValuesMap;
typedef NSMutableArray<REATransitionValues*> REAValuesList;

@implementation REATransition {
  __weak UIView *_root;
  REAValuesMap *_startValues;
  REAValuesMap *_endValues;
  REAValuesList *_startList;
  REAValuesList *_endList;
}

+ (REATransition *)inflate:(NSDictionary *)config
{
  REATransitionType type = [RCTConvert REATransitionType:config[@"type"]];
  switch (type) {
    case REATransitionTypeGroup:
      return [[REATransitionGroup alloc] initWithConfig:config];
    case REATransitionTypeIn:
      return [[REAInTransition alloc] initWithConfig:config];
    case REATransitionTypeOut:
      return [[REAOutTransition alloc] initWithConfig:config];
    case REATransitionTypeChange:
      return [[REAChangeTransition alloc] initWithConfig:config];
    case REATransitionTypeNone:
    default:
      RCTLogError(@"Invalid transitioning type %@", config[@"type"]);
  }
  return nil;
}

- (instancetype)initWithConfig:(NSDictionary *)config
{
  if (self = [super init]) {
    _duration = [RCTConvert double:config[@"durationMs"]] / 1000.0;
    _delay = [RCTConvert double:config[@"delayMs"]] / 1000.0;
    _interpolation = [RCTConvert REATransitionInterpolationType:config[@"interpolation"]];
    _propagation = [RCTConvert REATransitionPropagationType:config[@"propagation"]];

    _startValues = [NSMutableDictionary new];
    _endValues = [NSMutableDictionary new];
    _startList = [NSMutableArray new];
    _endList = [NSMutableArray new];
  }
  return self;
}

- (void)captureRecursiveIn:(UIView *)view to:(REAValuesMap *)map forRoot:(UIView *)root
{
  NSNumber *tag = view.reactTag;
  if (tag != nil) {
    map[tag] = [[REATransitionValues alloc] initWithView:view forRoot:root];
    for (UIView *subview in view.reactSubviews) {
      [self captureRecursiveIn:subview to:map forRoot:root];
    }
  }
}

- (void)startCaptureWithViewRegistry:(REAViewRegistry *)viewRegistry
{
  _startValues = [NSMutableDictionary new];
  for (NSNumber *targetTag in _targetTags) {
    UIView *view = viewRegistry[targetTag];
    _startValues[view.reactTag] = [[REATransitionValues alloc] initWithView:view forRoot:nil];
  }
}

- (void)matchByMapping:(REAValuesMap *)start end:(REAValuesMap *)end
{
  [_targetMapping enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, NSNumber * _Nonnull value, BOOL * _Nonnull stop) {
    REATransitionValues *startValues = [start objectForKey:key];
    REATransitionValues *endValues = [end objectForKey:value];
    if (startValues != nil && endValues != nil) {
      [start removeObjectsForKeys:@[key, value]];
      [end removeObjectsForKeys:@[key, value]];
      [_startList addObject:startValues];
      [_endList addObject:endValues];
    }
  }];
}

- (void)matchByTags:(REAValuesMap *)start end:(REAValuesMap *)end
{
  NSMutableArray *keysToRemove = [NSMutableArray new];
  [start enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, REATransitionValues * _Nonnull startValues, BOOL * _Nonnull stop) {
    REATransitionValues *endValues = [end objectForKey:key];
    if (endValues != nil) {
      [_startList addObject:startValues];
      [_endList addObject:endValues];
      [keysToRemove addObject:key];
    }
  }];
  [start removeObjectsForKeys:keysToRemove];
  [end removeObjectsForKeys:keysToRemove];
}

- (void)addUnmatched:(REAValuesMap *)start end:(REAValuesMap *)end
{
  [start enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, REATransitionValues * _Nonnull startValues, BOOL * _Nonnull stop) {
    [_startList addObject:startValues];
    [_endList addObject:[REATransitionValues new]];
  }];
  [end enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, REATransitionValues * _Nonnull endValues, BOOL * _Nonnull stop) {
    [_startList addObject:[REATransitionValues new]];
    [_endList addObject:endValues];
  }];
  [start removeAllObjects];
  [end removeAllObjects];
}

- (void)playWithViewRegistry:(REAViewRegistry *)viewRegistry
{
  [_endValues removeAllObjects];
  for (NSNumber *targetTag in _targetTags) {
    UIView *view = viewRegistry[targetTag];
    if (view != nil) {
      _endValues[view.reactTag] = [[REATransitionValues alloc] initWithView:view forRoot:nil];
    }
  }

  [_startList removeAllObjects];
  [_endList removeAllObjects];

  // matching
  REAValuesMap *unmatchedStart = [NSMutableDictionary dictionaryWithDictionary:_startValues];
  REAValuesMap *unmatchedEnd = [NSMutableDictionary dictionaryWithDictionary:_endValues];
  [self matchByMapping:unmatchedStart end:unmatchedEnd];
  [self matchByTags:unmatchedStart end:unmatchedEnd];
  [self addUnmatched:unmatchedStart end:unmatchedEnd];


  NSArray *animations = [self animationsForTransitioning:_startList
                                               endValues:_endList
                                                 forRoot:nil];
  for (REATransitionAnimation *animation in animations) {
    [animation play];
  }

  [_startValues removeAllObjects];
  [_endValues removeAllObjects];
}

- (REATransitionValues *)findStartValuesForKey:(NSNumber *)key
{
  if (_parent != nil) {
    return [_parent findStartValuesForKey:key];
  }
  return _startValues[key];
}

- (REATransitionValues *)findEndValuesForKey:(NSNumber *)key
{
  if (_parent != nil) {
    return [_parent findEndValuesForKey:key];
  }
  return _endValues[key];
}

- (CFTimeInterval)propagationDelayForTransitioning:(REATransitionValues *)startValues
                                         endValues:(REATransitionValues *)endValues
                                           forRoot:(UIView *)root
{
  if (self.propagation == REATransitionPropagationNone) {
    return 0.;
  }

  REATransitionValues *values = endValues;
  if (values == nil) {
    values = startValues;
  }

  double fraction = 0.;
  switch (self.propagation) {
    case REATransitionPropagationLeft:
      fraction = values.center.x / root.layer.bounds.size.width;
      break;
    case REATransitionPropagationRight:
      fraction = 1. - values.center.x / root.layer.bounds.size.width;
      break;
    case REATransitionPropagationTop:
      fraction = values.center.y / root.layer.bounds.size.height;
      break;
    case REATransitionPropagationBottom:
      fraction = 1. - values.center.y / root.layer.bounds.size.height;
      break;
  }

  return _duration * MIN(MAX(0., fraction), 1.) / DEFAULT_PROPAGATION_SPEED;
}

- (CAMediaTimingFunction *)mediaTiming
{
  switch (self.interpolation) {
    case REATransitionInterpolationLinear:
      return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    case REATransitionInterpolationEaseIn:
      return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    case REATransitionInterpolationEaseOut:
      return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    case REATransitionInterpolationEaseInOut:
      return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  }
}

- (REATransitionAnimation *)animationForTransitioning:(REATransitionValues *)startValues
                                            endValues:(REATransitionValues *)endValues
                                              forRoot:(UIView *)root
{
  return nil;
}

- (NSArray<REATransitionAnimation *> *)animationsForTransitioning:(REATransitionValuesList *)startValuesList
                                                        endValues:(REATransitionValuesList *)endValuesList
                                                          forRoot:(UIView *)root
{
  NSMutableArray *animations = [NSMutableArray new];
  for (NSUInteger i = 0; i < startValuesList.count; i++) {
    REATransitionValues *startValues = [startValuesList objectAtIndex:i];
    REATransitionValues *endValues = [endValuesList objectAtIndex:i];
    REATransitionAnimation *animation = [self animationForTransitioning:startValues
                                                              endValues:endValues
                                                                forRoot:root];
    if (animation != nil) {
      animation.animation.timingFunction = self.mediaTiming;
      animation.animation.duration = self.duration;
      [animation delayBy:self.delay];
      CFTimeInterval propagationDelay = [self propagationDelayForTransitioning:startValues
                                                                     endValues:endValues
                                                                       forRoot:root];
      [animation delayBy:propagationDelay];
      [animations addObject:animation];
    }
  }
//  [startValues enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, REATransitionValues *startValue, BOOL *stop) {
//    REATransitionValues *endValue = endValues[key];
//    REATransitionAnimation *animation = [self animationForTransitioning:startValue endValues:endValue forRoot:root];
//    if (animation != nil) {
//      animation.animation.timingFunction = self.mediaTiming;
//      animation.animation.duration = self.duration;
//      [animation delayBy:self.delay];
//      CFTimeInterval propagationDelay = [self propagationDelayForTransitioning:startValue endValues:endValue forRoot:root];
//      [animation delayBy:propagationDelay];
//      //      animation.animation.duration -= propagationDelay;
//      [animations addObject:animation];
//    }
//  }];
//  [endValues enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, REATransitionValues *endValue, BOOL *stop) {
//    if (startValues[key] == nil) {
//      REATransitionAnimation *animation = [self animationForTransitioning:nil endValues:endValue forRoot:root];
//      if (animation != nil) {
//        animation.animation.timingFunction = self.mediaTiming;
//        animation.animation.duration = self.duration;
//        [animation delayBy:self.delay];
//        CFTimeInterval propagationDelay = [self propagationDelayForTransitioning:nil endValues:endValue forRoot:root];
//        [animation delayBy:propagationDelay];
//        //        animation.animation.duration -= propagationDelay;
//        [animations addObject:animation];
//      }
//    }
//  }];
  return animations;
}

@end
