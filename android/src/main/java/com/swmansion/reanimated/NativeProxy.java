package com.swmansion.reanimated;

import android.os.SystemClock;
import androidx.annotation.Nullable;

import com.facebook.jni.HybridData;
import com.facebook.proguard.annotations.DoNotStrip;
import com.facebook.react.bridge.JSIModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.turbomodule.core.CallInvokerHolderImpl;
import com.facebook.react.turbomodule.core.interfaces.TurboModule;
import com.facebook.react.turbomodule.core.interfaces.TurboModuleRegistry;
import com.facebook.react.uimanager.UIManagerModule;
import com.facebook.react.uimanager.events.RCTEventEmitter;
import com.swmansion.reanimated.layoutReanimation.AnimationsManager;
import com.swmansion.reanimated.layoutReanimation.NativeMethodsHolder;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class NativeProxy {

  static {
    System.loadLibrary("reanimated");
  }

  @DoNotStrip
  public static class AnimationFrameCallback implements NodesManager.OnAnimationFrame {

    @DoNotStrip
    private final HybridData mHybridData;

    @DoNotStrip
    private AnimationFrameCallback(HybridData hybridData) {
      mHybridData = hybridData;
    }

    @Override
    public native void onAnimationFrame(double timestampMs);
  }

  @DoNotStrip
  public static class EventHandler implements RCTEventEmitter {

    @DoNotStrip
    private final HybridData mHybridData;
    private UIManagerModule.CustomEventNamesResolver mCustomEventNamesResolver;

    @DoNotStrip
    private EventHandler(HybridData hybridData) {
      mHybridData = hybridData;
    }

    @Override
    public void receiveEvent(int targetTag, String eventName, @Nullable WritableMap event) {
      String resolvedEventName = mCustomEventNamesResolver.resolveCustomEventName(eventName);
      receiveEvent(targetTag + resolvedEventName, event);
    }

    public native void receiveEvent(String eventKey, @Nullable WritableMap event);

    @Override
    public void receiveTouches(String eventName, WritableArray touches, WritableArray changedIndices) {
      // not interested in processing touch events this way, we process raw events only
    }
  }

  @DoNotStrip
  @SuppressWarnings("unused")
  private final HybridData mHybridData;
  private NodesManager mNodesManager;
  private final WeakReference<ReactApplicationContext> mContext;
  private Scheduler mScheduler = null;

  public NativeProxy(ReactApplicationContext context) {
    CallInvokerHolderImpl holder = (CallInvokerHolderImpl)context.getCatalystInstance().getJSCallInvokerHolder();

    mScheduler = new Scheduler(context);
    mHybridData = initHybrid(context.getJavaScriptContextHolder().get(), holder, mScheduler);
    mContext = new WeakReference<>(context);
    prepare();
  }

  private native HybridData initHybrid(long jsContext, CallInvokerHolderImpl jsCallInvokerHolder, Scheduler scheduler);
  private native void installJSIBindings();

  public native boolean isAnyHandlerWaitingForEvent(String eventName);

  // LayoutReanimation
  public native void startAnimationForTag(int tag);
  public native void removeConfigForTag(int tag);
  public native Map<String, Object> getStyleWhileMounting(int tag, float progress, HashMap<String, Double> values, int depth);
  public native Map<String, Object> getStyleWhileUnmounting(int tag, float progress, HashMap<String, Double> values, int depth);

  private void notifyAboutEnd(int tag, int cancelledInt) {
    ReactApplicationContext context = mContext.get();
    if (context != null) {
      context.getNativeModule(ReanimatedModule.class)
              .getNodesManager()
              .getReactBatchObserver()
              .getAnimationsManager()
              .notifyAboutEnd(tag, (cancelledInt == 0)? false : true);
    }
  }

  private void notifyAboutProgress(double progress, int tag) {
    ReactApplicationContext context = mContext.get();
    if (context != null) {
      context.getNativeModule(ReanimatedModule.class)
              .getNodesManager()
              .getReactBatchObserver()
              .getAnimationsManager()
              .notifyAboutProgress(progress, tag);
    }
  }

  @DoNotStrip
  private void requestRender(AnimationFrameCallback callback) {
    mNodesManager.postOnAnimation(callback);
  }

  @DoNotStrip
  private void updateProps(int viewTag, Map<String, Object> props) {
    mNodesManager.updateProps(viewTag, props);
  }

  @DoNotStrip
  private String obtainProp(int viewTag, String propName) {
     return mNodesManager.obtainProp(viewTag, propName);
  }

  @DoNotStrip
  private void scrollTo(int viewTag, double x, double y, boolean animated) {
    mNodesManager.scrollTo(viewTag, x, y, animated);
  }

  @DoNotStrip
  private String getUpTime() {
    return Long.toString(SystemClock.uptimeMillis());
  }

  @DoNotStrip
  private float[] measure(int viewTag) {
    return mNodesManager.measure(viewTag);
  }

  @DoNotStrip
  private void registerEventHandler(EventHandler handler) {
    handler.mCustomEventNamesResolver = mNodesManager.getEventNameResolver();
    mNodesManager.registerEventHandler(handler);
  }

  public void onCatalystInstanceDestroy() {
    mScheduler.deactivate();
    mHybridData.resetNative();
  }

  public void prepare() {
    mNodesManager = mContext.get().getNativeModule(ReanimatedModule.class).getNodesManager();
    installJSIBindings();
    AnimationsManager animationsManager = mContext.get()
            .getNativeModule(ReanimatedModule.class)
            .getNodesManager()
            .getReactBatchObserver()
            .getAnimationsManager();

    WeakReference<NativeProxy> weakNativeProxy = new WeakReference<>(this);
    animationsManager.setNativeMethods(new NativeMethodsHolder() {
      @Override
      public void startAnimationForTag(int tag) {
        NativeProxy nativeProxy = weakNativeProxy.get();
        if (nativeProxy != null) {
          nativeProxy.startAnimationForTag(tag);
        }
      }

      @Override
      public void removeConfigForTag(int tag) {
        NativeProxy nativeProxy = weakNativeProxy.get();
        if (nativeProxy != null) {
          nativeProxy.removeConfigForTag(tag);
        }
      }

      @Override
      public Map<String, Object> getStyleWhileMounting(int tag, float progress, HashMap<String, Double> values, int depth) {
        NativeProxy nativeProxy = weakNativeProxy.get();
        if (nativeProxy != null) {
          return nativeProxy.getStyleWhileMounting(tag, progress, values, depth);
        }
        return new HashMap<String, Object>();
      }

      @Override
      public Map<String, Object> getStyleWhileUnmounting(int tag, float progress, HashMap<String, Double> values, int depth) {
        NativeProxy nativeProxy = weakNativeProxy.get();
        if (nativeProxy != null) {
          return nativeProxy.getStyleWhileUnmounting(tag, progress, values, depth);
        }
        return new HashMap<String, Object>();
      }
    });
  }
}
