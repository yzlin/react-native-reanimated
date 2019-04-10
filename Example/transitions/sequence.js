import React, { useState, useRef } from 'react';
import { Text, View, StyleSheet, Button, StatusBar } from 'react-native';
import { Transitioning, Transition } from 'react-native-reanimated';

function Sequence() {
  const transition = (
    <Transition.Together>
      <Transition.Out type="scale" durationMs={1500} />
      <Transition.Change interpolation="easeInOut" />
      <Transition.In type="circle" />
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
      {showText && (
        <View
          style={{
            backgroundColor: '#ff5252',
            margin: 10,
            padding: 150,
            paddingHorizontal: 120,
          }}>
          <Text style={{ color: 'white' }}>Who</Text>
          <Text style={{ color: 'white' }}>dis?</Text>
        </View>
      )}
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
