#import <Foundation/Foundation.h>
#import <React/RCTUIManager.h>

@interface REATransitionManager : NSObject

- (instancetype)initWithUIManager:(RCTUIManager *)uiManager;
- (void)animateNextTransitionInRoot:(nonnull NSNumber *)reactTag withConfig:(NSDictionary *)config;
- (void)animateChange:(nonnull NSNumber *)reactTag withConfig:(NSDictionary *)config;
- (void)animateAppear:(nonnull NSNumber *)reactTag withConfig:(NSDictionary *)config;
- (void)animateDisappear:(nonnull NSNumber *)reactTag withConfig:(NSDictionary *)config;

@end
