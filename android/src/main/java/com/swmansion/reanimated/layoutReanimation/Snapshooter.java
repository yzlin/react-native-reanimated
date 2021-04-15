package com.swmansion.reanimated.layoutReanimation;

import android.view.View;
import java.util.ArrayList;
import java.util.HashMap;

public class Snapshooter {
    public Integer tag;
    public ArrayList<View> listOfViews;
    public HashMap<Integer, HashMap<String, Object>> capturedValues;

    Snapshooter(Integer tag) {
        this.tag = tag;
        listOfViews = new ArrayList<>();
    }

    void takeSnapshot(View view) {
        HashMap<String, Object> values = new HashMap<>();

        if (view instanceof AnimatedRoot) {
            ArrayList<View> pathToRootView = new ArrayList<>();
            View current = view;
            do {
                pathToRootView.add(current);
                current = (View)current.getParent();
            } while (current != view.getRootView());
            values.put("pathToRootView", pathToRootView);
        }

        values.put("width", view.getWidth());
        values.put("height", view.getHeight());
        values.put("originX", view.getLeft());
        values.put("originY", view.getTop());

        int[] location = new int[2];
        view.getLocationOnScreen(location);
        values.put("globalOriginX", location[0]);
        values.put("globalOriginY", location[1]);

        values.put("parent", (View)view.getParent());


        listOfViews.add(view);
        capturedValues.put(view.getId(), values);
    }
}
