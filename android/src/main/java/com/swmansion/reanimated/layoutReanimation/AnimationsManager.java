package com.swmansion.reanimated.layoutReanimation;

import android.util.DisplayMetrics;
import android.util.Log;
import android.view.View;

import androidx.annotation.Dimension;

import com.facebook.react.bridge.ReactContext;
import com.facebook.react.uimanager.UIImplementation;
import com.facebook.react.uimanager.UIManagerModule;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;

public class AnimationsManager {

    private ReactContext mContext;
    private UIImplementation mUIImplementation;
    private UIManagerModule mUIManager;
    private NativeMethodsHolder mNativeMethodsHolder;
    private HashMap<Integer, ArrayList<Runnable>> mBlocksForTags;
    private HashMap<Integer, Snapshooter> mFirstSnapshots;
    private HashMap<Integer, Snapshooter> mSecondSnapshots;

    AnimationsManager(ReactContext context, UIImplementation uiImplementation, UIManagerModule uiManagerModule) {
        mContext = context;
        mUIImplementation = uiImplementation;
        mUIManager = uiManagerModule;
        mBlocksForTags = new HashMap<>();
        mFirstSnapshots = new HashMap<>();
        mSecondSnapshots = new HashMap<>();
    }

    public void onCatalystInstanceDestroy() {
        mNativeMethodsHolder = null;
        mContext = null;
        mUIImplementation = null;
        mUIManager = null;
        mBlocksForTags = null;
    }

    public void startAnimationWithFirstSnapshot(Snapshooter snapshooter) {
        mFirstSnapshots.put(snapshooter.tag, snapshooter);
        mSecondSnapshots.remove(snapshooter.tag);
        mNativeMethodsHolder.startAnimationForTag(snapshooter.tag);
    }

    public void addSecondSnapshot(Snapshooter snapshooter) {
        mSecondSnapshots.put(snapshooter.tag, snapshooter);
        if (snapshooter.capturedValues.size() == 0) { // Root config should be removed on next unmounting animation
            addOnAnimationRunnable(snapshooter.tag, () -> {
               mNativeMethodsHolder.removeConfigForTag(snapshooter.tag);
            });
        }
    }

    private void addOnAnimationRunnable(Integer tag, Runnable runnable) {
        if (mBlocksForTags.get(tag) == null) {
            mBlocksForTags.put(tag, new ArrayList<>());
        }
        mBlocksForTags.get(tag).add(runnable);
    }

    public void notifyAboutProgress(double progress, Integer tag) {
        Log.i("LayoutReanimation", "progress: " + progress);
        Snapshooter first = mFirstSnapshots.get(tag);
        Snapshooter second = mSecondSnapshots.get(tag);
        if (first == null || second == null) { // animation is not ready
            return;
        }

        HashSet<Integer> processed = new HashSet<>();
        ArrayList<View> allViews = new ArrayList<>();
        for (View view : first.listOfViews) {
            allViews.add(view);
            processed.add(view.getId());
        }
        for (View view : second.listOfViews) {
            if (!processed.contains(view.getId())) {
                allViews.add(view);
            }
        }

        for (View view : allViews) {
            HashMap<String, Object> startValues = first.capturedValues.get(view.getId());
            HashMap<String, Object> targetValues = second.capturedValues.get(view.getId());

            if (startValues != null && targetValues != null) { //interpolate
                double currentWidth = ((Double)targetValues.get("width")) * progress + ((Double)startValues.get("width"))  * (1.0 - progress);
                double currentHeight = ((Double)targetValues.get("height")) * progress + ((Double)startValues.get("height")) * (1.0 - progress);

                double currentX = ((Double)targetValues.get("originX")) * progress + ((Double)startValues.get("originX")) * (1.0 - progress);
                double currentY = ((Double)targetValues.get("originY")) * progress + ((Double)startValues.get("originY")) * (1.0 - progress);

                // TODO how to update view properly
            }

            if (startValues == null && targetValues != null) { // appearing
                //TODO
            }

            if (startValues != null && targetValues == null) { // disappearing
                //TODO
            }
        }
    }

    public void notifyAboutEnd(int tag, boolean cancelled) {
        if (mBlocksForTags.get(tag) != null) {
            for (Runnable runnable : mBlocksForTags.get(tag)) {
                runnable.run();
            }
        }
        
        if (!cancelled) {
            mFirstSnapshots.remove(tag);
            mSecondSnapshots.remove(tag);
        }
    }
    
    public HashMap<String, Double> prepareDataForAnimationWorklet(HashMap<String, Object> values) {
        HashMap<String, Double> preparedValues = new HashMap<>();
        ArrayList<String> keys = (ArrayList<String>) Arrays.asList("width", "height", "originX", "originY",
                "globalOriginX", "globalOriginY");
        for (String key : keys) {
            preparedValues.put(key, (Double)values.get(key));
        }

        DisplayMetrics displaymetrics = new DisplayMetrics();
        mContext.getCurrentActivity().getWindowManager().getDefaultDisplay().getMetrics(displaymetrics);
        int height = displaymetrics.heightPixels;
        int width = displaymetrics.widthPixels;
        preparedValues.put("windowWidth", (double)width);
        preparedValues.put("windowHeight", (double)height);
        return preparedValues;
    }

    public void setNativeMethods(NativeMethodsHolder nativeMethods) {
        mNativeMethodsHolder = nativeMethods;
    }
}
