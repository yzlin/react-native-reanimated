//
// Created by Szymon Kapala on 4/16/21.
//
#include "LayoutAnimations.h"

namespace reanimated
{

LayoutAnimations::LayoutAnimations(
    jni::alias_ref<LayoutAnimations::javaobject> jThis) : javaPart_(jni::make_global(jThis))
{}

jni::local_ref<LayoutAnimations::jhybriddata> LayoutAnimations::initHybrid(
    jni::alias_ref<jhybridobject> jThis)
{
  return makeCxxInstance(jThis);
}

void LayoutAnimations::setWeakUIRuntime(std::weak_ptr<jsi::Runtime> wrt) {
    this->weakUIRuntime = wrt;
}

void LayoutAnimations::startAnimationForTag(int tag) {
    if (auto rt = this->weakUIRuntime.lock()) {
        jsi::Value layoutAnimationRepositoryAsValue = rt->global().getPropertyAsObject(*rt, "global").getProperty(*rt, "LayoutAnimationRepository");
        if (!layoutAnimationRepositoryAsValue.isUndefined()) {
          jsi::Function startAnimationForTag = layoutAnimationRepositoryAsValue.getObject(*rt).getPropertyAsFunction(*rt, "startAnimationForTag");
          startAnimationForTag.call(*rt, jsi::Value(tag));
        }
    }
}

void LayoutAnimations::removeConfigForTag(int tag) {
    if (auto rt = this->weakUIRuntime.lock()) {
       jsi::Value layoutAnimationRepositoryAsValue = rt->global().getPropertyAsObject(*rt, "global").getProperty(*rt, "LayoutAnimationRepository");
       if (!layoutAnimationRepositoryAsValue.isUndefined()) {
         jsi::Function removeConfig = layoutAnimationRepositoryAsValue.getObject(*rt).getPropertyAsFunction(*rt, "removeConfig");
         removeConfig.call(*rt, jsi::Value(tag));
       }
    }
}

jni::local_ref<JMap<JString, JObject>> LayoutAnimations::getStyleWhileMounting(int tag, double progress, alias_ref<JMap<JString, JInteger>> values, int depth) {
    if (auto rt = this->weakUIRuntime.lock()) {
        jsi::Value layoutAnimationRepositoryAsValue = rt->global().getPropertyAsObject(*rt, "global").getProperty(*rt, "LayoutAnimationRepository");
        if (!layoutAnimationRepositoryAsValue.isUndefined()) {
          jsi::Function getMountingStyle = layoutAnimationRepositoryAsValue.getObject(*rt).getPropertyAsFunction(*rt, "getMountingStyle");
          jsi::Object target(*rt);

          for (const auto& entry : *values) {
            target.setProperty(*rt, entry.first->toStdString().c_str(), entry.second->value());
          }

          jsi::Value value = getMountingStyle.call(*rt, jsi::Value(tag), jsi::Value(progress), target, jsi::Value(depth));
          jsi::Object props = value.asObject(*rt);
          return ConvertToPropsMap(*rt, props);
         }
    }
    return PropsMap::create();
}

jni::local_ref<JMap<JString, JObject>> LayoutAnimations::getStyleWhileUnmounting(int tag, double progress, alias_ref<JMap<JString, JInteger>> values, int depth) {
     if (auto rt = this->weakUIRuntime.lock()) {
        jsi::Value layoutAnimationRepositoryAsValue = rt->global().getPropertyAsObject(*rt, "global").getProperty(*rt, "LayoutAnimationRepository");
        if (!layoutAnimationRepositoryAsValue.isUndefined()) {
          jsi::Function getMountingStyle = layoutAnimationRepositoryAsValue.getObject(*rt).getPropertyAsFunction(*rt, "getUnmountingStyle");
          jsi::Object initial(*rt);

          for (const auto& entry : *values) {
            initial.setProperty(*rt, entry.first->toStdString().c_str(), entry.second->value());
          }

          jsi::Value value = getMountingStyle.call(*rt, jsi::Value(tag), jsi::Value(progress), initial, jsi::Value(depth));
          jsi::Object props = value.asObject(*rt);
          return ConvertToPropsMap(*rt, props);
        }
    }
    return PropsMap::create();
}

void LayoutAnimations::notifyAboutProgress(double progress, int tag) {
    static const auto method = javaPart_
                           ->getClass()
                           ->getMethod<void(double, int)>("notifyAboutProgress");
    method(javaPart_.get(), progress, tag);
}

void LayoutAnimations::notifyAboutEnd(int tag, int cancelled) {
    static const auto method = javaPart_
                               ->getClass()
                               ->getMethod<void(int, int)>("notifyAboutEnd");
    method(javaPart_.get(), tag, cancelled);
}

void LayoutAnimations::registerNatives()
{
  registerHybrid({
      makeNativeMethod("initHybrid", LayoutAnimations::initHybrid),
      makeNativeMethod("startAnimationForTag", LayoutAnimations::startAnimationForTag),
      makeNativeMethod("removeConfigForTag", LayoutAnimations::removeConfigForTag),
      makeNativeMethod("getStyleWhileMounting", LayoutAnimations::getStyleWhileMounting),
      makeNativeMethod("getStyleWhileUnmounting", LayoutAnimations::getStyleWhileUnmounting)
  });
}

};

