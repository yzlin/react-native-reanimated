package com.swmansion.reanimated.layoutReanimation;

import android.util.DisplayMetrics;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewParent;
import com.facebook.react.bridge.JavaOnlyMap;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.uimanager.IViewManagerWithChildren;
import com.facebook.react.uimanager.IllegalViewOperationException;
import com.facebook.react.uimanager.ReactStylesDiffMap;
import com.facebook.react.uimanager.RootView;
import com.facebook.react.uimanager.UIImplementation;
import com.facebook.react.uimanager.UIManagerModule;
import com.facebook.react.uimanager.ViewManager;

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
            addOnAnimationEndRunnable(snapshooter.tag, () -> {
               mNativeMethodsHolder.removeConfigForTag(snapshooter.tag);
            });
        }
    }

    private void addOnAnimationEndRunnable(Integer tag, Runnable runnable) {
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
                double currentWidth = ((Double)targetValues.get(Snapshooter.width)) * progress + ((Double)startValues.get(Snapshooter.width))  * (1.0 - progress);
                double currentHeight = ((Double)targetValues.get(Snapshooter.height)) * progress + ((Double)startValues.get(Snapshooter.height)) * (1.0 - progress);

                double currentX = ((Double)targetValues.get(Snapshooter.originX)) * progress + ((Double)startValues.get(Snapshooter.originX)) * (1.0 - progress);
                double currentY = ((Double)targetValues.get(Snapshooter.originY)) * progress + ((Double)startValues.get(Snapshooter.originY)) * (1.0 - progress);

                HashMap<String, Object> props = new HashMap<>();
                props.put(Snapshooter.width, currentWidth);
                props.put(Snapshooter.height, currentHeight);
                props.put(Snapshooter.originX, currentX);
                props.put(Snapshooter.originY, currentY);
                ViewManager viewManager = (ViewManager) targetValues.get(Snapshooter.viewManager);
                ViewManager parentViewManager = (ViewManager) targetValues.get(Snapshooter.parentViewManager);
                View parentView = (View) targetValues.get(Snapshooter.parent);
                setNewProps(props, view, viewManager, parentViewManager, parentView.getId());
            }

            if (startValues == null && targetValues != null) { // appearing
                int depth = 0; // distance to deepest appearing ancestor or AnimatedRoot
                if (targetValues.get("depth") == null) {
                    View deepestView = view;
                    while ((!(deepestView instanceof AnimatedRoot)) && first.capturedValues.get(((View)deepestView.getParent()).getId()) == null) {
                        deepestView = (View)deepestView.getParent();
                        depth++;
                    }
                    targetValues.put("depth", depth);
                }
                depth = (Integer)targetValues.get("depth");
                HashMap<String, Integer> data = prepareDataForAnimationWorklet(targetValues);
                Map<String, Object> newProps = mNativeMethodsHolder.getStyleWhileMounting(tag, (float)progress, data, depth);
                ViewManager viewManager = (ViewManager) targetValues.get(Snapshooter.viewManager);
                ViewManager parentViewManager = (ViewManager) targetValues.get(Snapshooter.parentViewManager);
                View parentView = (View) targetValues.get(Snapshooter.parent);
                setNewProps(newProps, view, viewManager, parentViewManager, parentView.getId());
            }

            if (startValues != null && targetValues == null) { // disappearing
                int depth = 0;
                if (startValues.get("depth") == null) {
                    View deepestView = view;
                    // TODO get rid of that disaster
                    while ((!(deepestView instanceof AnimatedRoot)) && second.capturedValues.get(((View)(first.capturedValues.get(deepestView.getId()).get(Snapshooter.parent))).getId()) == null) {
                        deepestView = (View)(first.capturedValues.get(deepestView.getId()).get(Snapshooter.parent));
                        depth++;
                    }
                    startValues.put("depth", depth);

                    if ((view instanceof AnimatedRoot)) {
                        // If I'm the root
                        ArrayList<View> pathToRoot = (ArrayList<View>)startValues.get(Snapshooter.pathToTheRootView);
                        for (int i = 1; i < pathToRoot.size(); ++i) {
                            ViewGroup parent = (ViewGroup)pathToRoot.get(i);
                            View currentView = pathToRoot.get(i-1);
                            if (currentView.getParent() == null) {
                                parent.addView(currentView);
                                addOnAnimationEndRunnable(tag, () -> {
                                    parent.removeView(currentView);
                                });
                            }
                        }
                    } else {
                        if (view.getParent() == null) {
                            ViewGroup parentView = (ViewGroup)startValues.get(Snapshooter.parent);
                            parentView.addView(view);
                            addOnAnimationEndRunnable(tag, () -> {
                                parentView.removeView(view);
                            });
                        }
                    }
                }
                depth = (Integer)startValues.get("depth");
                HashMap<String, Integer> data = prepareDataForAnimationWorklet(startValues);
                Map<String, Object> newProps = mNativeMethodsHolder.getStyleWhileUnmounting(tag, (float)progress, data, depth);
                ViewManager viewManager = (ViewManager) startValues.get(Snapshooter.viewManager);
                ViewManager parentViewManager = (ViewManager) startValues.get(Snapshooter.parentViewManager);
                View parentView = (View) startValues.get(Snapshooter.parent);
                setNewProps(newProps, view, viewManager, parentViewManager, parentView.getId());
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
    
    public HashMap<String, Integer> prepareDataForAnimationWorklet(HashMap<String, Object> values) {
        HashMap<String, Integer> preparedValues = new HashMap<>();
        ArrayList<String> keys = (ArrayList<String>) Arrays.asList(Snapshooter.width, Snapshooter.height, Snapshooter.originX,
                Snapshooter.originY, Snapshooter.globalOriginX, Snapshooter.globalOriginY);
        for (String key : keys) {
            preparedValues.put(key, (int)values.get(key));
        }

        DisplayMetrics displaymetrics = new DisplayMetrics();
        mContext.getCurrentActivity().getWindowManager().getDefaultDisplay().getMetrics(displaymetrics);
        int height = displaymetrics.heightPixels;
        int width = displaymetrics.widthPixels;
        preparedValues.put("windowWidth", width);
        preparedValues.put("windowHeight", height);
        return preparedValues;
    }

    public void setNativeMethods(NativeMethodsHolder nativeMethods) {
        mNativeMethodsHolder = nativeMethods;
    }

    public void setNewProps(Map<String, Object> props,
                            View view,
                            ViewManager viewManager,
                            ViewManager parentViewManager,
                            Integer parentTag) {
        int x = (Integer)props.get(Snapshooter.originX);
        int y = (Integer)props.get(Snapshooter.originY);
        int width = (Integer)props.get(Snapshooter.width);
        int height = (Integer)props.get(Snapshooter.height);
        updateLayout(view, parentViewManager, parentTag, view.getId(), x, y, width, height);
        props.remove(Snapshooter.originX);
        props.remove(Snapshooter.originY);
        props.remove(Snapshooter.width);
        props.remove(Snapshooter.height);

        if (props.size() == 0) {
            return;
        }

        JavaOnlyMap javaOnlyMap = new JavaOnlyMap();
        for (String key : props.keySet()) {
            addProp(javaOnlyMap, key, props.get(key));
        }

        viewManager.updateProperties(view, new ReactStylesDiffMap(javaOnlyMap));
    }

    private static void addProp(WritableMap propMap, String key, Object value) {
        if (value == null) {
            propMap.putNull(key);
        } else if (value instanceof Double) {
            propMap.putDouble(key, (Double) value);
        } else if (value instanceof Integer) {
            propMap.putInt(key, (Integer) value);
        } else if (value instanceof Number) {
            propMap.putDouble(key, ((Number) value).doubleValue());
        } else if (value instanceof Boolean) {
            propMap.putBoolean(key, (Boolean) value);
        } else if (value instanceof String) {
            propMap.putString(key, (String) value);
        } else if (value instanceof ReadableArray) {
            propMap.putArray(key, (ReadableArray) value);
        } else if (value instanceof ReadableMap) {
            propMap.putMap(key, (ReadableMap) value);
        } else {
            throw new IllegalStateException("Unknown type of animated value [Layout Aniamtions]");
        }
    }

    public void updateLayout(View viewToUpdate, ViewManager parentViewManager,
            int parentTag, int tag, int x, int y, int width, int height) {


        // Even though we have exact dimensions, we still call measure because some platform views
        // (e.g.
        // Switch) assume that method will always be called before onLayout and onDraw. They use it to
        // calculate and cache information used in the draw pass. For most views, onMeasure can be
        // stubbed out to only call setMeasuredDimensions. For ViewGroups, onLayout should be stubbed
        // out to not recursively call layout on its children: React Native already handles doing
        // that.
        //
        // Also, note measure and layout need to be called *after* all View properties have been
        // updated
        // because of caching and calculation that may occur in onMeasure and onLayout. Layout
        // operations should also follow the native view hierarchy and go top to bottom for
        // consistency
        // with standard layout passes (some views may depend on this).

        viewToUpdate.measure(
                View.MeasureSpec.makeMeasureSpec(width, View.MeasureSpec.EXACTLY),
                View.MeasureSpec.makeMeasureSpec(height, View.MeasureSpec.EXACTLY));

        // We update the layout of the ReactRootView when there is a change in the layout of its
        // child.
        // This is required to re-measure the size of the native View container (usually a
        // FrameLayout) that is configured with layout_height = WRAP_CONTENT or layout_width =
        // WRAP_CONTENT
        //
        // This code is going to be executed ONLY when there is a change in the size of the Root
        // View defined in the js side. Changes in the layout of inner views will not trigger an
        // update
        // on the layout of the Root View.
        ViewParent parent = viewToUpdate.getParent();
        if (parent instanceof RootView) {
            parent.requestLayout();
        }

        // Check if the parent of the view has to layout the view, or the child has to lay itself out.
        if (parentTag % 10 == 1) { // ParentIsARoot
            IViewManagerWithChildren parentViewManagerWithChildren;
            if (parentViewManager instanceof IViewManagerWithChildren) {
                parentViewManagerWithChildren = (IViewManagerWithChildren) parentViewManager;
            } else {
                throw new IllegalViewOperationException(
                        "Trying to use view with tag "
                                + parentTag
                                + " as a parent, but its Manager doesn't implement IViewManagerWithChildren");
            }
            if (parentViewManagerWithChildren != null
                    && !parentViewManagerWithChildren.needsCustomLayoutForChildren()) {
                viewToUpdate.layout(x, y, x + width, y + height);
            }
        } else {
            viewToUpdate.layout(x, y, x + width, y + height);
        }

    }
}
