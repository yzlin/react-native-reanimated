import React, { useEffect } from 'react';
import Animated, { useSharedValue, useAnimatedStyle, withTiming, } from '../src/';
import { withReanimatedTimer, advanceAnimationByTime, } from '../src/reanimated2/jestUtils';
import { mount } from '@quilted/react-testing';

const PinCircle = ({filled = false}) => {
  const animatedValue = useSharedValue(0);
  useEffect(() => {
    animatedValue.value = withTiming(filled ? 0 : 1, {duration: 50});
  }, [animatedValue, filled]);

  const animatedStyle = useAnimatedStyle(() => {
    const scale = animatedValue.value;
    return { transform: [{scale}] };
  });

  return (
    <Animated.View
      testID="PinCircle/InnerCircle"
      style={animatedStyle}
    />
  );
}

it('filled prop is true', () => {
  withReanimatedTimer(() => {
    const wrapper = mount(<PinCircle filled={true} />);
    advanceAnimationByTime(50);
    const InnerView = wrapper.find(Animated.View, {testID: 'PinCircle/InnerCircle'});
    expect(InnerView).toHaveAnimatedStyle({transform: [{scale: 0}]});
  });
});

it('filled prop is false', () => {
  withReanimatedTimer(() => {
    const wrapper = mount(<PinCircle filled={false} />);
    advanceAnimationByTime(50);
    const InnerViewAfter = wrapper.find(Animated.View, {testID: 'PinCircle/InnerCircle'});
    expect(InnerViewAfter).toHaveAnimatedStyle({transform: [{scale: 1}]});
  });
});