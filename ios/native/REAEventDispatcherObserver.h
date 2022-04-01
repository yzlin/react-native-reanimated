#include <React/RCTEventDispatcherProtocol.h>
#include <React/RCTEventEmitter.h>

#ifdef __cplusplus
#include <RNReanimated/NativeReanimatedModule.h>
#include <jsi/jsi.h>
#include <memory>
#endif

@interface REAEventDispatcherObserver : RCTEventEmitter <RCTEventDispatcherObserver>

#ifdef __cplusplus
- (instancetype)initWithReaModule:(std::shared_ptr<reanimated::NativeReanimatedModule>)module
                        andBridge:(RCTBridge *)bridge;
#endif

@end
