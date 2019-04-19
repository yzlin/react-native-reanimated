import React, { useState, useRef } from 'react';
import { Text, View, StyleSheet, Button, StatusBar } from 'react-native';
import { Transitioning, Transition } from 'react-native-reanimated';

function Sequence() {
  const transition = (
    <Transition.Together>
      <Transition.Change interpolation="easeInOut" />
    </Transition.Together>
  );

  let [showText, setShowText] = useState(true);
  const ref = useRef();

  return (
    <Transitioning.View
      ref={ref}
      transition={transition}
      style={styles.centerAll}>
      <Button
        title="show or hide"
        color="#FF5252"
        onPress={() => {
          ref.current.animateNextTransition();
          setShowText(!showText);
        }}
      />
      <View
        style={{
          backgroundColor: '#ff5252',
          margin: 10,
          padding: 150,
          borderRadius: showText ? 10 : 30,
          paddingHorizontal: 120,
        }}
      />
    </Transitioning.View>
  );
}

const styles = StyleSheet.create({
  centerAll: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  text: {
    fontSize: 16,
    margin: 10,
  },
});

export default Sequence;
