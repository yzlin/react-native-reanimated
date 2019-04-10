package android.support.transition;

import android.view.ViewGroup;

import java.util.ArrayList;

public class InteractiveTransition extends TransitionSet {

  @Override
  protected void createAnimators(ViewGroup sceneRoot,
                                 TransitionValuesMaps startValues,
                                 TransitionValuesMaps endValues,
                                 ArrayList<TransitionValues> startValuesList,
                                 ArrayList<TransitionValues> endValuesList) {
    super.createAnimators(sceneRoot, startValues, endValues, startValuesList, endValuesList);
  }

  @Override
  protected void runAnimators() {

    super.runAnimators();
  }
}

