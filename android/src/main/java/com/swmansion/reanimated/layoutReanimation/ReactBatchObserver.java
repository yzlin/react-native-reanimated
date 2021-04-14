package com.swmansion.reanimated.layoutReanimation;

import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.UIManager;
import com.facebook.react.bridge.UIManagerListener;
import com.facebook.react.uimanager.LayoutShadowNode;
import com.facebook.react.uimanager.NativeViewHierarchyManager;
import com.facebook.react.uimanager.ReactShadowNode;
import com.facebook.react.uimanager.ShadowNodeRegistry;
import com.facebook.react.uimanager.UIBlock;
import com.facebook.react.uimanager.UIImplementation;
import com.facebook.react.uimanager.UIManagerModule;
import com.swmansion.reanimated.NodesManager;

import java.lang.reflect.Field;
import java.util.Arrays;
import java.util.HashSet;


public class ReactBatchObserver implements UIManagerListener {

    static HashSet<Integer> animatedRoots = new HashSet<Integer>();

    private ReactContext mContext;
    private UIManagerModule mUIManager;
    private UIImplementation mUIImplementation;
    private NodesManager mNodesManager;
    private HashSet<Integer> mAffectedAnimatedRoots = new HashSet<Integer>();

    public ReactBatchObserver(ReactContext context, UIManagerModule uiManager, UIImplementation uiImplementation, NodesManager nodesManager) {
        mContext = context;
        mUIImplementation = uiImplementation;
        mUIManager = uiManager;
        mNodesManager = nodesManager;

        try {
            Class clazz = mUIImplementation.getClass();
            Field shadowRegistry = clazz.getDeclaredField("mShadowNodeRegistry");
            shadowRegistry.setAccessible(true);
            ShadowNodeRegistry shadowNodeRegistry = (ShadowNodeRegistry)shadowRegistry.get(mUIImplementation);
            shadowNodeRegistry.addRootNode(new FakeFirstRootShadowNode());
            shadowNodeRegistry.addRootNode(new FakeLastRootShadowNode());
        } catch (NoSuchFieldException | IllegalAccessException e) {
            e.printStackTrace();
        }

    }

    private void findAffected() {
    }

    @Override
    public void willDispatchViewUpdates(UIManager uiManager) {

    }

    @Override
    public void didDispatchMountItems(UIManager uiManager) {

    }

    @Override
    public void didScheduleMountItems(UIManager uiManager) {

    }

    public void onCatalystInstanceDestroy() {
        mContext = null;
        mUIManager = null;
        mUIImplementation.removeLayoutUpdateListener();
        mUIImplementation = null;
        mNodesManager = null;
    }

    class FakeFirstRootShadowNode extends LayoutShadowNode {
        FakeFirstRootShadowNode() {
            super();
            this.setReactTag(-5);
        }

        @Override
        public void calculateLayout(float width, float height) {
            mAffectedAnimatedRoots = new HashSet<>();
            HashSet<Integer> tags = new HashSet<>(ReactBatchObserver.animatedRoots);
            for (Integer tag : tags) {
                if (mUIImplementation.resolveShadowNode(tag) != null) {
                    ReactShadowNode sn = mUIImplementation.resolveShadowNode(tag);
                    if (sn.hasUpdates()) {
                        mAffectedAnimatedRoots.add(tag);
                    }
                } else {
                    mAffectedAnimatedRoots.add(tag);
                    ReactBatchObserver.animatedRoots.remove(tag);
                }
            }
        }
    }

    class FakeLastRootShadowNode extends LayoutShadowNode {
        FakeLastRootShadowNode() {
            super();
            this.setReactTag(51); // % 10 == 1
        }

        @Override
        public void calculateLayout(float width, float height) {
            HashSet<Integer> affectedTags = new HashSet<>(mAffectedAnimatedRoots);
            mAffectedAnimatedRoots = new HashSet<>();

            mUIManager.prependUIBlock(new UIBlock() {
                @Override
                public void execute(NativeViewHierarchyManager nativeViewHierarchyManager) {
                    // TODO
                }
            });

            mUIManager.addUIBlock(new UIBlock() {
                @Override
                public void execute(NativeViewHierarchyManager nativeViewHierarchyManager) {
                    // TODO
                }
            });


        }
    }

}


