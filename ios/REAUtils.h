#import <Foundation/Foundation.h>
#include <jsi/jsi.h>
#define REA_LOG_ERROR_IF_NIL(value, errorMsg) \
  ({                                          \
    if (value == nil)                         \
      RCTLogError(errorMsg);                  \
  })

namespace reanimated {

using namespace facebook;

class REAUtils {
 public:
  static NSString *convertJSIStringToNSString(jsi::Runtime &runtime, const jsi::String &value);
  static NSDictionary *convertJSIObjectToNSDictionary(jsi::Runtime &runtime, const jsi::Object &value);
  static NSArray *convertJSIArrayToNSArray(jsi::Runtime &runtime, const jsi::Array &value);
  static id convertJSIValueToObjCObject(jsi::Runtime &runtime, const jsi::Value &value);
  static jsi::Value convertNSNumberToJSIBoolean(jsi::Runtime &runtime, NSNumber *value);
  static jsi::Value convertNSNumberToJSINumber(jsi::Runtime &runtime, NSNumber *value);
  static jsi::String convertNSStringToJSIString(jsi::Runtime &runtime, NSString *value);
  static jsi::Object convertNSDictionaryToJSIObject(jsi::Runtime &runtime, NSDictionary *value);
  static jsi::Array convertNSArrayToJSIArray(jsi::Runtime &runtime, NSArray *value);
  static std::vector<jsi::Value> convertNSArrayToStdVector(jsi::Runtime &runtime, NSArray *value);
  static jsi::Value convertObjCObjectToJSIValue(jsi::Runtime &runtime, id value);
  static NSSet *convertProps(jsi::Runtime &rt, const jsi::Value &props);
};

} // namespace reanimated
