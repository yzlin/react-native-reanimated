//
// Created by Szymon Kapala on 4/15/21.
//

#ifndef REANIMATEDEXAMPLE_LayoutAnimations_H
#define REANIMATEDEXAMPLE_LayoutAnimations_H
#include <fbjni/fbjni.h>
#include <jsi/jsi.h>

namespace reanimated
{

using namespace facebook::jni;
using namespace facebook;
using namespace react;


class LayoutAnimationProxy : public jni::HybridClass<LayoutAnimationProxy> {
 public:
  static auto constexpr kJavaDescriptor =
      "Lcom/swmansion/reanimated/layoutReanimation/LayoutAnimationProxy;";
  static jni::local_ref<jhybriddata> initHybrid(
        jni::alias_ref<jhybridobject> jThis);
  static void registerNatives();

  void startAnimationForTag(int tag);
  void removeConfigForTag(int tag);
  jni::local_ref<JMap<JString, JObject>> getStyleWhileMounting(int tag, float progress, alias_ref<JMap<JString, JDouble>> values, int depth);
  jni::local_ref<JMap<JString, JObject>> getStyleWhileUnmounting(int tag, float progress, alias_ref<JMap<JString, JDouble>> values, int depth);

  void setWeakUIRuntime(std::weak_ptr<jsi::Runtime> wrt);

 private:
  friend HybridBase;
  jni::global_ref<LayoutAnimationProxy::javaobject> javaPart_;
  std::weak_ptr<jsi::Runtime> weakUIRuntime;

  explicit LayoutAnimationProxy(jni::alias_ref<LayoutAnimationProxy::jhybridobject> jThis);
};

);
#endif //REANIMATEDEXAMPLE_LayoutAnimations_H
