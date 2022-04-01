#if TARGET_IPHONE_SIMULATOR
#import <dlfcn.h>
#endif

// #import <React/RCTFollyConvert.h>
#import <React/RCTUIManager.h>
// #import <folly/json.h>

#import <RNGestureHandlerStateManager.h>
#import "LayoutAnimationsProxy.h"
#import "NativeMethods.h"
#import "NativeProxy.h"
#import "REAAnimationsManager.h"
#import "REAEventDispatcherObserver.h"
#import "REAIOSErrorHandler.h"
#import "REAIOSScheduler.h"
#import "REAModule.h"
#import "REANodesManager.h"
#import "REAUIManager.h"
#import "REAUtils.h"
#import "ReanimatedSensorContainer.h"

#if __has_include(<reacthermes/HermesExecutorFactory.h>)
#import <reacthermes/HermesExecutorFactory.h>
#elif __has_include(<hermes/hermes.h>)
#import <hermes/hermes.h>
#else
#import <jsi/JSCRuntime.h>
#endif

#import <React-Fabric/react/renderer/core/ShadowNode.h> // ShadowNode::Shared
#import <React-Fabric/react/renderer/uimanager/primitives.h> // shadowNodeFromValue

#import <iostream>

namespace reanimated {

using namespace facebook;
using namespace react;

static CGFloat SimAnimationDragCoefficient(void)
{
  static float (*UIAnimationDragCoefficient)(void) = NULL;
#if TARGET_IPHONE_SIMULATOR
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    UIAnimationDragCoefficient = (float (*)(void))dlsym(RTLD_DEFAULT, "UIAnimationDragCoefficient");
  });
#endif
  return UIAnimationDragCoefficient ? UIAnimationDragCoefficient() : 1.f;
}

static CFTimeInterval calculateTimestampWithSlowAnimations(CFTimeInterval currentTimestamp)
{
#if TARGET_IPHONE_SIMULATOR
  static CFTimeInterval dragCoefChangedTimestamp = CACurrentMediaTime();
  static CGFloat previousDragCoef = SimAnimationDragCoefficient();

  const CGFloat dragCoef = SimAnimationDragCoefficient();
  if (previousDragCoef != dragCoef) {
    previousDragCoef = dragCoef;
    dragCoefChangedTimestamp = CACurrentMediaTime();
  }

  const bool areSlowAnimationsEnabled = dragCoef != 1.f;
  if (areSlowAnimationsEnabled) {
    return (dragCoefChangedTimestamp + (currentTimestamp - dragCoefChangedTimestamp) / dragCoef);
  } else {
    return currentTimestamp;
  }
#else
  return currentTimestamp;
#endif
}

std::shared_ptr<NativeReanimatedModule> createReanimatedModule(
    RCTBridge *bridge,
    std::shared_ptr<CallInvoker> jsInvoker)
{
  REAModule *reanimatedModule = [bridge moduleForClass:[REAModule class]];

  // RCTUIManager *uiManager = reanimatedModule.nodesManager.uiManager;
  auto measuringFunction = [](int viewTag) -> std::vector<std::pair<std::string, double>> {
    // return measure(viewTag, uiManager);
    return std::vector<std::pair<std::string, double>>(0);
  };

  auto scrollToFunction = [](int viewTag, double x, double y, bool animated) {
    //  scrollTo(viewTag, uiManager, x, y, animated); TODO
  };

  id<RNGestureHandlerStateManager> gestureHandlerStateManager = [bridge moduleForName:@"RNGestureHandlerModule"];
  auto setGestureStateFunction = [gestureHandlerStateManager](int handlerTag, int newState) {
    setGestureState(gestureHandlerStateManager, handlerTag, newState);
  };

  auto propObtainer = [reanimatedModule](
                          jsi::Runtime &rt, const int viewTag, const jsi::String &propName) -> jsi::Value {
    /* NSString *propNameConverted = [NSString stringWithFormat:@"%s", propName.utf8(rt).c_str()];
    std::string resultStr = std::string([[reanimatedModule.nodesManager obtainProp:[NSNumber numberWithInt:viewTag]
                                                                          propName:propNameConverted] UTF8String]);
    jsi::Value val = jsi::String::createFromUtf8(rt, resultStr);
    return val; */
    return 5;
  };

#if __has_include(<reacthermes/HermesExecutorFactory.h>)
  std::shared_ptr<jsi::Runtime> animatedRuntime = facebook::hermes::makeHermesRuntime();
#elif __has_include(<hermes/hermes.h>)
  std::shared_ptr<jsi::Runtime> animatedRuntime = facebook::hermes::makeHermesRuntime();
#else
  std::shared_ptr<jsi::Runtime> animatedRuntime = facebook::jsc::makeJSCRuntime();
#endif

  std::shared_ptr<Scheduler> scheduler = std::make_shared<REAIOSScheduler>(jsInvoker);
  std::shared_ptr<ErrorHandler> errorHandler = std::make_shared<REAIOSErrorHandler>(scheduler);
  std::shared_ptr<NativeReanimatedModule> module;

  __block std::weak_ptr<Scheduler> weakScheduler = scheduler;
  // ((REAUIManager *)uiManager).flushUiOperations = ^void() {
  //   std::shared_ptr<Scheduler> scheduler = weakScheduler.lock();
  //   if (scheduler != nullptr) {
  //     scheduler->triggerUI();
  //   }
  // };

  auto requestRender = [reanimatedModule, &module](std::function<void(double)> onRender, jsi::Runtime &rt) {
    [reanimatedModule.nodesManager postOnAnimation:^(CADisplayLink *displayLink) {
      double frameTimestamp = calculateTimestampWithSlowAnimations(displayLink.targetTimestamp) * 1000;
      jsi::Object global = rt.global(); // TODO: fix crash on reload
      jsi::String frameTimestampName = jsi::String::createFromAscii(rt, "_frameTimestamp");
      global.setProperty(rt, frameTimestampName, frameTimestamp);
      onRender(frameTimestamp);
      global.setProperty(rt, frameTimestampName, jsi::Value::undefined());
    }];
  };

  auto synchronouslyUpdateUIPropsFunction = [reanimatedModule](jsi::Runtime &rt, Tag tag, const jsi::Value &props) {
    NSNumber *viewTag = @(tag);
    NSDictionary *uiProps = REAUtils::convertJSIObjectToNSDictionary(rt, props.asObject(rt));
    [reanimatedModule.nodesManager synchronouslyUpdateViewOnUIThread:viewTag props:uiProps];
  };

  auto getCurrentTime = []() { return calculateTimestampWithSlowAnimations(CACurrentMediaTime()) * 1000; };

  // Layout Animations start
  // REAUIManager *reaUiManagerNoCast = [bridge moduleForClass:[REAUIManager class]];
  // RCTUIManager *reaUiManager = reaUiManagerNoCast;
  // REAAnimationsManager *animationsManager = [[REAAnimationsManager alloc] initWithUIManager:reaUiManager];
  // [reaUiManagerNoCast setUp:animationsManager];

  auto notifyAboutProgress = [=](int tag, jsi::Object newStyle) {
    // if (animationsManager) {
    //   NSDictionary *propsDict = convertJSIObjectToNSDictionary(*animatedRuntime, newStyle);
    //   [animationsManager notifyAboutProgress:propsDict tag:[NSNumber numberWithInt:tag]];
    // }
  };

  auto notifyAboutEnd = [=](int tag, bool isCancelled) {
    // if (animationsManager) {
    //   [animationsManager notifyAboutEnd:[NSNumber numberWithInt:tag] cancelled:isCancelled];
    // }
  };

  auto configurePropsFunction = [reanimatedModule](
                                    jsi::Runtime &rt, const jsi::Value &uiProps, const jsi::Value &nativeProps) {
    NSSet *uiPropsSet = REAUtils::convertProps(rt, uiProps);
    NSSet *nativePropsSet = REAUtils::convertProps(rt, nativeProps);
    [reanimatedModule.nodesManager configureUiProps:uiPropsSet andNativeProps:nativePropsSet];
  };

  std::shared_ptr<LayoutAnimationsProxy> layoutAnimationsProxy =
      std::make_shared<LayoutAnimationsProxy>(notifyAboutProgress, notifyAboutEnd);
  std::weak_ptr<jsi::Runtime> wrt = animatedRuntime;
  /*[animationsManager setAnimationStartingBlock:^(
                         NSNumber *_Nonnull tag, NSString *type, NSDictionary *_Nonnull values, NSNumber *depth) {
    std::shared_ptr<jsi::Runtime> rt = wrt.lock();
    if (wrt.expired()) {
      return;
    }
    jsi::Object yogaValues(*rt);
    for (NSString *key in values.allKeys) {
      NSNumber *value = values[key];
      yogaValues.setProperty(*rt, [key UTF8String], [value doubleValue]);
    }

    jsi::Value layoutAnimationRepositoryAsValue =
        rt->global().getPropertyAsObject(*rt, "global").getProperty(*rt, "LayoutAnimationRepository");
    if (!layoutAnimationRepositoryAsValue.isUndefined()) {
      jsi::Function startAnimationForTag =
          layoutAnimationRepositoryAsValue.getObject(*rt).getPropertyAsFunction(*rt, "startAnimationForTag");
      startAnimationForTag.call(
          *rt,
          jsi::Value([tag intValue]),
          jsi::String::createFromAscii(*rt, std::string([type UTF8String])),
          yogaValues,
          jsi::Value([depth intValue]));
    }
  }];

  [animationsManager setRemovingConfigBlock:^(NSNumber *_Nonnull tag) {
    std::shared_ptr<jsi::Runtime> rt = wrt.lock();
    if (wrt.expired()) {
      return;
    }
    jsi::Value layoutAnimationRepositoryAsValue =
        rt->global().getPropertyAsObject(*rt, "global").getProperty(*rt, "LayoutAnimationRepository");
    if (!layoutAnimationRepositoryAsValue.isUndefined()) {
      jsi::Function removeConfig =
          layoutAnimationRepositoryAsValue.getObject(*rt).getPropertyAsFunction(*rt, "removeConfig");
      removeConfig.call(*rt, jsi::Value([tag intValue]));
    }
  }];*/

  // Layout Animations end

  // sensors
  ReanimatedSensorContainer *reanimatedSensorContainer = [[ReanimatedSensorContainer alloc] init];
  auto registerSensorFunction = [=](int sensorType, int interval, std::function<void(double[])> setter) -> int {
    return [reanimatedSensorContainer registerSensor:(ReanimatedSensorType)sensorType
                                            interval:interval
                                              setter:^(double *data) {
                                                setter(data);
                                              }];
  };

  auto unregisterSensorFunction = [=](int sensorId) { [reanimatedSensorContainer unregisterSensor:sensorId]; };
  // end sensors

  PlatformDepMethodsHolder platformDepMethodsHolder = {
      requestRender,
      synchronouslyUpdateUIPropsFunction,
      scrollToFunction,
      measuringFunction,
      getCurrentTime,
      registerSensorFunction,
      unregisterSensorFunction,
      setGestureStateFunction,
      configurePropsFunction};

  module = std::make_shared<NativeReanimatedModule>(
      jsInvoker,
      scheduler,
      animatedRuntime,
      errorHandler,
      propObtainer,
      layoutAnimationsProxy,
      platformDepMethodsHolder);

  scheduler->setRuntimeManager(module);

  [reanimatedModule.nodesManager registerEventHandler:^(NSString *eventNameNSString, id<RCTEvent> event) {
    // handles RCTEvents from RNGestureHandler

    auto &rt = *module->runtime;

    std::string eventName = [eventNameNSString UTF8String];
    jsi::Value payload = REAUtils::convertNSDictionaryToJSIObject(rt, [event arguments][2]);
    // TODO: check if NaN and INF values are converted properly

    jsi::Object global = rt.global();
    jsi::String eventTimestampName = jsi::String::createFromAscii(rt, "_eventTimestamp");
    global.setProperty(rt, eventTimestampName, CACurrentMediaTime() * 1000);
    module->onEvent(eventName, std::move(payload));
    global.setProperty(rt, eventTimestampName, jsi::Value::undefined());
  }];

  [reanimatedModule.nodesManager registerPerformOperations:^() {
    module->performOperations();
  }];

  reanimatedModule.nodesManager.eventDispatcherObserver = [[REAEventDispatcherObserver alloc] initWithReaModule:module
                                                                                                      andBridge:bridge];

  return module;
}

}
