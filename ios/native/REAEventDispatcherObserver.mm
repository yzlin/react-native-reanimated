#import "REAEventDispatcherObserver.h"
#import <React/RCTEventDispatcher.h>
#import <React/RCTEventDispatcherProtocol.h>
#import <React/RCTEventEmitter.h>
#import <React/RCTUIManagerUtils.h>
#import "REAUtils.h"

#ifdef __cplusplus
using namespace facebook;
using namespace reanimated;
#endif

@implementation REAEventDispatcherObserver {
  std::shared_ptr<facebook::jsi::Runtime> _runtime;
  std::shared_ptr<reanimated::NativeReanimatedModule> _module;
}

- (instancetype)initWithReaModule:(std::shared_ptr<reanimated::NativeReanimatedModule>)module
                        andBridge:(RCTBridge *)bridge
{
  self = [super init];
  [bridge moduleForClass:[RCTEventDispatcher class]];
  RCTEventDispatcher *eventDispatcher = [bridge moduleForName:@"EventDispatcher"];
  [eventDispatcher addDispatchObserver:self];

  _module = module;
  _runtime = module->runtime;
  return self;
}

- (NSArray<NSString *> *)supportedEvents
{
  return @[];
}

- (void)eventDispatcherWillDispatchEvent:(id<RCTEvent>)event
{
  NSDictionary *eventDataDictionary = [event arguments][2];
  auto &rt = *_runtime.get();
  jsi::Value payload = REAUtils::convertObjCObjectToJSIValue(rt, eventDataDictionary);
  int tag = [event.viewTag intValue];
  std::string eventName = std::to_string(tag) + std::string([event.eventName UTF8String]);
  jsi::Object global = rt.global();
  jsi::String eventTimestampName = jsi::String::createFromAscii(rt, "_eventTimestamp");
  global.setProperty(rt, eventTimestampName, CACurrentMediaTime() * 1000);
  _module->onEvent(eventName, std::move(payload));
  global.setProperty(rt, eventTimestampName, jsi::Value::undefined());
}

@end
