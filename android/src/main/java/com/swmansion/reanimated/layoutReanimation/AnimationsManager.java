package com.swmansion.reanimated.layoutReanimation;

import com.facebook.react.bridge.ReactContext;
import com.facebook.react.uimanager.UIImplementation;
import com.facebook.react.uimanager.UIManagerModule;

import java.util.ArrayList;
import java.util.HashMap;
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
    }

    public void notifyAboutEnd(int tag, boolean b) {
    }

    public void setNativeMethods(NativeMethodsHolder nativeMethods) {
        mNativeMethodsHolder = nativeMethods;
    }
}
