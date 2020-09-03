import React, {useEffect, useState} from 'react';
import {StyleSheet, View, Text, TouchableHighlight} from 'react-native';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withTiming,
  useDerivedValue,
} from 'react-native-reanimated';

const initialAppearDuration = 5600;
const smallerDotMax = 110;

const LoadingView = ({onPress, name}) => {
  const smalledDotValue = useSharedValue(0);

  useEffect(() => {
    console.log(name, 'withTiming');
    smalledDotValue.value = withTiming(smallerDotMax, {
      duration: initialAppearDuration,
    })
  }, []);

  useDerivedValue(() => {
    return {
      width: smalledDotValue.value,
      height: smalledDotValue.value,
      borderRadius: smalledDotValue.value / 2,
    };
  }, []);

  return (
    <View style={styles.container}>
        <Text>{name}</Text>
      {/*<Animated.View style={[styles.dot, smallDotStyle]} />*/}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: 'red',
  },
  dot: {
    position: 'absolute',
    backgroundColor: '#ffffff',
    height: 200,
    width: 200,
    opacity: 0.6,
  },
});


export default LoadingView;


