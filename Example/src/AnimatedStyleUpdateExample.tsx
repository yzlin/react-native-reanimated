import Animated, {
  useSharedValue,
  withTiming,
  useAnimatedStyle,
  Easing,
} from 'react-native-reanimated';
import { View, Button } from 'react-native';
import React from 'react';

function AnimatedStyleUpdateExample(): React.ReactElement {
  const randomWidth = useSharedValue(10);

  const config = {
    duration: 500,
    easing: Easing.bezier(0.5, 0.01, 0, 1),
  };

  const worklet = () => {
    'worklet';
    throw 'EXCEPTION_IN_WORKLET';
  }

  const style = useAnimatedStyle(() => {
    if(_WORKLET) { // on UI thread context
      try {
        worklet();
      }
      catch (e) {
        console.log("SUCCESS");
      }
    }

    return {
      width: withTiming(randomWidth.value, config),
    };
  });

  return (
    <View
      style={{
        flex: 1,
        flexDirection: 'column',
      }}>
      <Animated.View
        style={[
          { width: 100, height: 80, backgroundColor: 'black', margin: 30 },
          style,
        ]}
      />
      <Button
        title="CLICK TO TRIGGER EXCEPTION"
        onPress={() => {
          randomWidth.value = Math.random() * 350;
        }}
      />
    </View>
  );
}

export default AnimatedStyleUpdateExample;
