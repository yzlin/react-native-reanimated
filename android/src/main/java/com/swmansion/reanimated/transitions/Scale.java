package com.swmansion.reanimated.transitions;

import android.animation.Animator;
import android.animation.AnimatorSet;
import android.animation.ObjectAnimator;
import android.animation.TimeAnimator;
import android.animation.ValueAnimator;
import android.os.Handler;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.transition.Transition;
import android.support.transition.TransitionListenerAdapter;
import android.support.transition.TransitionValues;
import android.support.transition.Visibility;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;

public class Scale extends Visibility {

  static final String PROPNAME_SCALE_X = "scale:scaleX";
  static final String PROPNAME_SCALE_Y = "scale:scaleY";

  @Override
  public void captureStartValues(TransitionValues transitionValues) {
    super.captureStartValues(transitionValues);
    transitionValues.values.put(PROPNAME_SCALE_X, transitionValues.view.getScaleX());
    transitionValues.values.put(PROPNAME_SCALE_Y, transitionValues.view.getScaleY());
  }

  public Scale setDisappearedScale(float disappearedScale) {
    if (disappearedScale < 0f) {
      throw new IllegalArgumentException("disappearedScale cannot be negative!");
    }
    return this;
  }


  private Animator createAnimation(final View view, float startScale, float endScale, TransitionValues values) {
    final float initialScaleX = view.getScaleX();
    final float initialScaleY = view.getScaleY();
    float startScaleX = initialScaleX * startScale;
    float endScaleX = initialScaleX * endScale;
    float startScaleY = initialScaleY * startScale;
    float endScaleY = initialScaleY * endScale;

    if (values != null) {
      Float savedScaleX = (Float) values.values.get(PROPNAME_SCALE_X);
      Float savedScaleY = (Float) values.values.get(PROPNAME_SCALE_Y);
      // if saved value is not equal initial value it means that previous
      // transition was interrupted and in the onTransitionEnd
      // we've applied endScale. we should apply proper value to
      // continue animation from the interrupted state
      if (savedScaleX != null && savedScaleX != initialScaleX) {
        startScaleX = savedScaleX;
      }
      if (savedScaleY != null && savedScaleY != initialScaleY) {
        startScaleY = savedScaleY;
      }
    }

    view.setScaleX(startScaleX);
//    view.setScaleY(startScaleY);

//    AnimatorSet animator = new AnimatorSet();
//    animator.playTogether(
//            ObjectAnimator.ofFloat(view, View.SCALE_X, startScaleX, endScaleX),
//            ObjectAnimator.ofFloat(view, View.SCALE_Y, startScaleY, endScaleY));
//    addListener(new TransitionListenerAdapter() {
//      @Override
//      public void onTransitionEnd(Transition transition) {
//        view.setScaleX(initialScaleX);
//        view.setScaleY(initialScaleY);
//        transition.removeListener(this);
//      }
//    });
//    return animator;
    return ObjectAnimator.ofFloat(view, View.SCALE_X, startScaleX, endScaleX);
  }

  @Override
  public Animator onAppear(ViewGroup sceneRoot, View view, TransitionValues startValues, TransitionValues endValues) {
    return createAnimation(view, 0f, 1f, startValues);
  }

  @Override
  public Animator onDisappear(ViewGroup sceneRoot, View view, TransitionValues startValues, TransitionValues endValues) {
    return createAnimation(view, 1f, 0f, startValues);
  }

  @Nullable
  @Override
  public Animator createAnimator(@NonNull ViewGroup sceneRoot, @Nullable TransitionValues startValues, @Nullable TransitionValues endValues) {
    Animator animator = super.createAnimator(sceneRoot, startValues, endValues);
    if (animator != null && animator instanceof ValueAnimator) {
      final ValueAnimator valueAnimator = (ValueAnimator) animator;
      new Handler().postDelayed(new Runnable() {
        @Override
        public void run() {
          valueAnimator.pause();
        }
      }, 1000);
      new Handler().postDelayed(new Runnable() {
        @Override
        public void run() {
          valueAnimator.resume();
          valueAnimator.setCurrentPlayTime(800);
          valueAnimator.pause();
        }
      }, 2500);
      new Handler().postDelayed(new Runnable() {
        @Override
        public void run() {
          valueAnimator.resume();
        }
      }, 5000);
    }
    return animator;
  }
}
