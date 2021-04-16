package com.swmansion.reanimated.layoutReanimation;

import java.util.HashMap;
import java.util.Map;

public interface NativeMethodsHolder {
    public void startAnimationForTag(int tag);
    public void removeConfigForTag(int tag);
    public Map<String, Object> getStyleWhileMounting(int tag, float progress, HashMap<String, Integer> values, int depth);
    public Map<String, Object> getStyleWhileUnmounting(int tag, float progress, HashMap<String, Integer> values, int depth);
}
