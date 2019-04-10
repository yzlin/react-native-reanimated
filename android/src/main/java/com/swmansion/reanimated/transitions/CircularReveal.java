package com.swmansion.reanimated.transitions;

import android.animation.Animator;
import android.os.Build;
import android.os.Handler;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.annotation.RequiresApi;
import android.support.transition.Transition;
import android.support.transition.TransitionManager;
import android.support.transition.TransitionValues;
import android.support.transition.Visibility;
import android.view.View;
import android.view.ViewAnimationUtils;
import android.view.ViewGroup;

import com.facebook.react.bridge.UiThreadUtil;

public class CircularReveal extends Visibility {

  public CircularReveal() {
    setMode(Visibility.MODE_IN);
  }

  @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
  @Override
  public Animator onAppear(ViewGroup sceneRoot,
                           View view,
                           TransitionValues startValues,
                           TransitionValues endValues) {
    int x = 0; //sceneRoot.getRight();
    int y = 0; //sceneRoot.getBottom();
//    Transition.

    int startRadius = 0;
    int endRadius = (int) Math.hypot(view.getWidth(), view.getHeight());

    Animator animator = ViewAnimationUtils.createCircularReveal(view, x, y, startRadius, endRadius);
    animator.setDuration(1500);
    return animator;
  }

  @Nullable
  @Override
  public Animator createAnimator(@NonNull ViewGroup sceneRoot, @Nullable TransitionValues startValues, @Nullable TransitionValues endValues) {
    final Animator animator = super.createAnimator(sceneRoot, startValues, endValues);
    if (animator != null) {
//      new Handler().postDelayed(new Runnable() {
//        @Override
//        public void run() {
//          animator.pause();
//        }
//      }, 500);
    }
    return animator;
  }
}
