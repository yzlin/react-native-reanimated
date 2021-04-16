//
// Created by Szymon Kapala on 4/16/21.
//
#include "LayoutAnimations.h"

namespace reanimated
{

using namespace facebook;
using namespace react;


struct PropsMap : jni::JavaClass<PropsMap, JMap<JString, JObject>>
{
  static constexpr auto kJavaDescriptor =
      "Ljava/util/HashMap;";

  static local_ref<PropsMap> create()
  {
    return newInstance();
  }

  void put(const std::string &key, jni::local_ref<JObject> object)
  {
    static auto method = getClass()
                             ->getMethod<jobject(jni::local_ref<JObject>, jni::local_ref<JObject>)>("put");
    method(self(), jni::make_jstring(key), object);
  }
};


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

static jni::local_ref<PropsMap> ConvertToPropsMap(jsi::Runtime &rt, const jsi::Object &props)
{
  auto map = PropsMap::create();

  auto propNames = props.getPropertyNames(rt);
  for (size_t i = 0, size = propNames.size(rt); i < size; i++)
  {
    auto jsiKey = propNames.getValueAtIndex(rt, i).asString(rt);
    auto value = props.getProperty(rt, jsiKey);
    auto key = jsiKey.utf8(rt);
    if (value.isUndefined() || value.isNull())
    {
      map->put(key, nullptr);
    }
    else if (value.isBool())
    {
      map->put(key, JBoolean::valueOf(value.getBool()));
    }
    else if (value.isNumber())
    {
      map->put(key, jni::autobox(value.asNumber()));
    }
    else if (value.isString())
    {
      map->put(key, jni::make_jstring(value.asString(rt).utf8(rt)));
    }
    else if (value.isObject())
    {
      if (value.asObject(rt).isArray(rt))
      {
        map->put(key, ReadableNativeArray::newObjectCxxArgs(jsi::dynamicFromValue(rt, value)));
      }
      else
      {
        map->put(key, ReadableNativeMap::newObjectCxxArgs(jsi::dynamicFromValue(rt, value)));
      }
    }
  }

  return map;
}

jni::local_ref<JMap<JString, JObject>> LayoutAnimations::getStyleWhileMounting(int tag, float progress, alias_ref<JMap<JString, JDouble>> values, int depth) {
    if (auto rt = this->weakUIRuntime.lock()) {
        jsi::Value layoutAnimationRepositoryAsValue = rt->global().getPropertyAsObject(*rt, "global").getProperty(*rt, "LayoutAnimationRepository");
        if (!layoutAnimationRepositoryAsValue.isUndefined()) {
          jsi::Function getMountingStyle = layoutAnimationRepositoryAsValue.getObject(*rt).getPropertyAsFunction(*rt, "getMountingStyle");
          jsi::Object target(*rt);

          for (const auto& entry : *values) {
            target.setProperty(*rt, entry.first->toStdString().c_str(), entry.second->doubleValue());
          }

          jsi::Value value = getMountingStyle.call(*rt, jsi::Value(tag), jsi::Value(progress), target, jsi::Value(depth));
          jsi::Object props = value.asObject(*rt);
          return ConvertToPropsMap(props);
    }
    return PropsMap::create();
}

jni::local_ref<JMap<JString, JObject>> LayoutAnimations::getStyleWhileUnmounting(int tag, float progress, alias_ref<JMap<JString, JDouble>> values, int depth) {
     if (auto rt = this->weakUIRuntime.lock()) {
        jsi::Value layoutAnimationRepositoryAsValue = rt->global().getPropertyAsObject(*rt, "global").getProperty(*rt, "LayoutAnimationRepository");
        if (!layoutAnimationRepositoryAsValue.isUndefined()) {
          jsi::Function getMountingStyle = layoutAnimationRepositoryAsValue.getObject(*rt).getPropertyAsFunction(*rt, "getUnmountingStyle");
          jsi::Object initial(*rt);

          for (const auto& entry : *values) {
            initial.setProperty(*rt, entry.first->toStdString().c_str(), entry.second->doubleValue());
          }

          jsi::Value value = getMountingStyle.call(*rt, jsi::Value(tag), jsi::Value(progress), initial, jsi::Value(depth));
          jsi::Object props = value.asObject(*rt);
          return ConvertToPropsMap(props);
    }
    return PropsMap::create();
}

void LayoutAnimations::registerNatives()
{
  registerHybrid({
      makeNativeMethod("initHybrid", LayoutAnimations::initHybrid),
      makeNativeMethod("startAnimationForTag", LayoutAnimations::startAnimationForTag),
      makeNativeMethod("removeConfigForTag", LayoutAnimations::removeConfigForTag)
      makeNativeMethod("getStyleWhileMounting", LayoutAnimations::getStyleWhileMounting)
      makeNativeMethod("getStyleWhileUnmounting", LayoutAnimations::getStyleWhileUnmounting)
  });
}

};

