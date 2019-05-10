import React, { useState, useRef } from 'react';
import {
  Text,
  Image,
  View,
  StyleSheet,
  Button,
  StatusBar,
  TouchableWithoutFeedback,
} from 'react-native';
import { Transitioning } from 'react-native-reanimated';

function Sequence() {
  let [showText, setShowText] = useState(false);
  const ref = useRef();
  const from = useRef();

  return (
    <View ref={ref} style={styles.centerAll}>
      <Button
        title="show or hide"
        color="#FF5252"
        onPress={() => setShowText(!showText)}
      />
      <Transitioning.View
        ref={from}
        style={{
          width: 80,
          height: 80,
          backgroundColor: 'orange', //showText ? 'red' : 'orange',
          // transform: [{ rotate: showText ? '45deg' : '0deg' }],
          overflow: 'hidden',
        }}>
        <Text>Trololo</Text>
      </Transitioning.View>
      {showText && (
        <Transitioning.View
          transitionFrom={from.current}
          style={{
            position: 'absolute',
            top: 0,
            width: 120,
            height: 120,
            backgroundColor: showText ? 'red' : 'orange',
            borderRadius: 20,
            overflow: 'hidden',
          }}>
          <Text>Trololo</Text>
        </Transitioning.View>
      )}
    </View>
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
  inline: {
    width: 200,
    height: 200,
  },
  float: {
    position: 'absolute',
    width: '100%',
    height: '100%',
  },
});

export default Sequence;
