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
import { Transitioning, Transition } from 'react-native-reanimated';

function Sequence() {
  const transition = (
    <Transition.Together>
      <Transition.Out type="fade" />
      <Transition.Change />
      <Transition.In type="fade" />
    </Transition.Together>
  );

  let [showText, setShowText] = useState(false);
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
      {/* {showText && (
        <View style={[StyleSheet.absoluteFill, { backgroundColor: 'black' }]} />
      )} */}
      <View
        style={{
          width: 80,
          height: 80,
          backgroundColor: showText ? 'red' : 'orange',
        }}
      />
      {/* <TouchableWithoutFeedback
        onPress={() => {
          ref.current.animateNextTransition();
          setShowText(!showText);
        }}>
        <Image
          style={showText ? styles.float : styles.inline}
          source={{
            uri:
              'https://assets1.ignimgs.com/2013/09/23/chewbacca-1280jpg-e94c97_1280w.jpg',
          }}
          resizeMode="contain"
        />
      </TouchableWithoutFeedback> */}
      {/* {showText && (
        <View
          style={{
            backgroundColor: '#ff5252',
            margin: 10,
            padding: 150,
            borderRadius: showText ? 10 : 30,
            paddingHorizontal: 120,
          }}
        />
      )} */}
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
