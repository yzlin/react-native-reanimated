package com.swmansion.reanimated.layoutReanimation;

import java.util.HashMap;
import java.util.Map;

public interface NativeMethodsHolder {
    public void startAnimationForTag(int tag, String type, HashMap<String, Integer> values);
    public void removeConfigForTag(int tag);
}
