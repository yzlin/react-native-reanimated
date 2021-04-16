//
// Created by Szymon Kapala on 4/16/21.
//

#ifndef REANIMATEDEXAMPLE_JNIHELPER_H
#define REANIMATEDEXAMPLE_JNIHELPER_H

#include <fbjni/fbjni.h>
#include <jsi/jsi.h>
#include <react/jni/CxxModuleWrapper.h>
#include <react/jni/JMessageQueueThread.h>
#include <react/jni/WritableNativeMap.h>
#include <jsi/JSIDynamic.h>

namespace reanimated {

using namespace facebook::jni;
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

jni::local_ref<PropsMap> ConvertToPropsMap(jsi::Runtime &rt, const jsi::Object &props)
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

};

#endif //REANIMATEDEXAMPLE_JNIHELPER_H
