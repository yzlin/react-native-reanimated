#import <UIKit/UIKit.h>

@interface REATransitionValues : NSObject

@property (nonatomic) CGPoint center;
@property (nonatomic) CGRect bounds;
@property (nonatomic) CGColorRef backgroundColor;
@property (nonatomic) CATransform3D transform;
@property (nonatomic) CGFloat zPosition;
@property (nonatomic) CGFloat cornerRadius;
@property (nonatomic) CGPoint centerRelativeToRoot;
@property (nonatomic, retain) UIView *view;
@property (nonatomic, retain) UIView *parent;
@property (nonatomic, retain) UIView *reactParent;
@property (nonatomic) CGPoint centerInReactParent;
@property (nonatomic) CGPathRef shadowPath;
@property (nonatomic) CGFloat shadowOpacity;
@property (nonatomic) CGSize shadowOffset;

- (instancetype)initWithView:(UIView *)view forRoot:(UIView *)root;

@end
