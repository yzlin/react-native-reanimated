#import <React/RCTView.h>
#import <React/RCTViewManager.h>

#import "REATransition.h"
#import "REATransitionValues.h"

#define EPS 1e-6

@implementation REATransitionValues

- (instancetype)initWithView:(UIView *)view forRoot:(UIView *)root
{
  if (self = [super init]) {
    _view = view;
    if (view.layer.needsDisplay) {
      // some RCTView properties (like shadows) are only updated in willDisplay
      // therefore we trigger display here manually to make sure we read the
      // corect values after they are updated
      [view.layer display];
    }
    _parent = view.superview;
    _reactParent = view.reactSuperview;
    while (_reactParent != nil && _reactParent != root && IS_LAYOUT_ONLY(_reactParent)) {
      _reactParent = _reactParent.reactSuperview;
    }
    _center = view.center;
    _bounds = view.bounds;
    _backgroundColor = view.layer.backgroundColor;
    _zPosition = view.layer.zPosition;
    _cornerRadius = view.layer.cornerRadius;
    _shadowPath = view.layer.shadowOpacity < EPS ? nil : view.layer.shadowPath;
    _shadowOpacity = view.layer.shadowOpacity;
    _shadowOffset = view.layer.shadowOffset;
    _centerRelativeToRoot = [_parent convertPoint:_center toView:root];
    _centerInReactParent = [_parent convertPoint:_center toView:_reactParent];
  }
  return self;
}

@end
