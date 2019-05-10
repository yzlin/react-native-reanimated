#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <React/RCTView.h>

#import "REATransitionAnimation.h"
#import "REATransitionValues.h"

// TODO: fix below implementation
#define IS_LAYOUT_ONLY(view) ([view isKindOfClass:[RCTView class]] && view.backgroundColor == nil)

typedef NS_ENUM(NSInteger, REATransitionType) {
  REATransitionTypeNone = 0,
  REATransitionTypeGroup,
  REATransitionTypeIn,
  REATransitionTypeOut,
  REATransitionTypeChange
};

typedef NS_ENUM(NSInteger, REATransitionAnimationType) {
  REATransitionAnimationTypeNone = 0,
  REATransitionAnimationTypeFade,
  REATransitionAnimationTypeScale,
  REATransitionAnimationTypeSlideTop,
  REATransitionAnimationTypeSlideBottom,
  REATransitionAnimationTypeSlideRight,
  REATransitionAnimationTypeSlideLeft,
  REATransitionAnimationTypeCircle,
};

typedef NS_ENUM(NSInteger, REATransitionInterpolationType) {
  REATransitionInterpolationLinear = 0,
  REATransitionInterpolationEaseIn,
  REATransitionInterpolationEaseOut,
  REATransitionInterpolationEaseInOut,
};

typedef NS_ENUM(NSInteger, REATransitionPropagationType) {
  REATransitionPropagationNone = 0,
  REATransitionPropagationTop,
  REATransitionPropagationBottom,
  REATransitionPropagationLeft,
  REATransitionPropagationRight,
};

typedef NSDictionary<NSNumber *,UIView *> REAViewRegistry;
typedef NSArray<REATransitionValues*> REATransitionValuesList;

@interface REATransition : NSObject
@property (nonatomic) NSMutableArray<NSNumber *> *targetTags;
@property (nonatomic) NSMutableDictionary<NSNumber *, NSNumber *> *targetMapping;
@property (nonatomic, weak) REATransition *parent;
@property (nonatomic) CFTimeInterval duration;
@property (nonatomic) CFTimeInterval delay;
@property (nonatomic) REATransitionInterpolationType interpolation;
@property (nonatomic) REATransitionPropagationType propagation;
- (instancetype)initWithConfig:(NSDictionary *)config NS_DESIGNATED_INITIALIZER;
- (CAMediaTimingFunction *)mediaTiming;
- (void)startCaptureWithViewRegistry:(REAViewRegistry *)viewRegistry;
- (void)playWithViewRegistry:(REAViewRegistry *)viewRegistry;
- (REATransitionValues *)findStartValuesForKey:(NSNumber *)key;
- (REATransitionValues *)findEndValuesForKey:(NSNumber *)key;
- (REATransitionAnimation *)animationForTransitioning:(REATransitionValues*)startValues
                                            endValues:(REATransitionValues*)endValues
                                              forRoot:(UIView *)root;
- (NSArray<REATransitionAnimation*> *)animationsForTransitioning:(REATransitionValuesList *)startValues
                                                          endValues:(REATransitionValuesList *)endValues
                                                            forRoot:(UIView *)root;

+ (REATransition *)inflate:(NSDictionary *)config;
@end
