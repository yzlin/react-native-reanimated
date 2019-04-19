import React, { useState, useRef } from 'react';
import {
  Text,
  View,
  StyleSheet,
  Button,
  StatusBar,
  Keyboard,
  TextInput,
  TouchableWithoutFeedback,
  TouchableHighlight,
} from 'react-native';
import { Transitioning, Transition } from 'react-native-reanimated';
import {} from 'react-native-paper';

function Row({ label, editing, value, onValueChange, startEditing, blur }) {
  return (
    <View style={styles.row}>
      <Text style={styles.label}>{label}</Text>
      <TextInput
        style={[styles.editText, editing ? {} : { color: '#B5B9C0' }]}
        keyboardType="decimal-pad"
        value={value}
        onChangeText={onValueChange}
        onFocus={startEditing}
        onBlur={blur}
      />
    </View>
  );
}

function FancyPants() {
  const [value, changeValue] = useState('10.80');
  const [editing, setEditing] = useState(false);
  const ref = useRef();

  const startEditing = () => {
    ref.current.animateNextTransition();
    setEditing(true);
  };

  const blur = () => {
    ref.current.animateNextTransition();
    setEditing(false);
  };

  const transition2 = (
    <Transition.Sequence>
      <Transition.Out type="fade" />
      <Transition.Change interpolation="easeInOut" />
      <Transition.In type="slide-bottom" interpolation="easeOut" />
    </Transition.Sequence>
  );
  const transition = (
    <Transition.Sequence>
      <Transition.Out type="slide-bottom" />
      <Transition.Change interpolation="easeInOut" />
      <Transition.In type="fade" interpolation="easeOut" />
    </Transition.Sequence>
  );

  return (
    <Transitioning.View ref={ref} transition={transition} style={{ flex: 1 }}>
      <View style={editing ? styles.editor : styles.card}>
        <Row
          label="Food"
          startEditing={startEditing}
          blur={blur}
          editing={editing}
          value={value}
          onValueChange={changeValue}
        />
        <Row label="Coffee" value="150.50" />
        <Row label="Subscriptions" value="39.99" />
        <Row label="Car" value="75.00" />
        <View style={styles.bar} />
        <View style={styles.row}>
          <Text style={styles.summary}>Sum</Text>
          <Text style={styles.editValue}>276.29</Text>
        </View>
        {!editing && (
          <Text style={styles.description}>
            Make sure to check your spendings prior to sending. Once sent, all
            your friends will learn how much you spent on partying and they may
            never want to speak with you again.
          </Text>
        )}
        {editing && (
          <TouchableHighlight
            onPress={Keyboard.dismiss}
            underlayColor="#d7e4fa"
            style={styles.checkButton}>
            <Text style={styles.buttonText}>✓</Text>
          </TouchableHighlight>
        )}
      </View>
      <View style={styles.button}>
        <Text style={styles.buttonText}>Send</Text>
      </View>
    </Transitioning.View>
  );
}

FancyPants.navigationOptions = {
  title: 'Spendings',
};

const styles = StyleSheet.create({
  card: {
    backgroundColor: 'white',
    margin: 20,
    marginTop: 30,
    borderRadius: 3,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.25,
    shadowRadius: 3.84,
    elevation: 5,
    padding: 20,
    // flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  button: {
    backgroundColor: '#C5D8F8',
    alignSelf: 'center',
    height: 40,
    width: 100,
    borderRadius: 20,
    alignItems: 'center',
    justifyContent: 'center',
  },
  checkButton: {
    backgroundColor: '#C5D8F8',
    position: 'absolute',
    right: 10,
    bottom: 310,
    height: 50,
    width: 50,
    borderRadius: 25,
    alignItems: 'center',
    justifyContent: 'center',
  },
  buttonText: {
    fontWeight: 'bold',
    fontFamily: 'Menlo',
    color: '#0E2146',
  },
  editor: {
    backgroundColor: 'white',
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.25,
    shadowRadius: 3.84,
    elevation: 5,
    padding: 20,
    height: '100%',
  },
  row: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    width: '100%',
    fontWeight: 'bold',
    marginBottom: 10,
  },
  editText: {
    color: '#444',
    fontFamily: 'Menlo',
    position: 'absolute',
    right: 0,
  },
  value: {
    color: '#B5B9C0',
    fontFamily: 'Menlo',
    position: 'absolute',
    right: 0,
  },
  description: {
    color: '#B5B9C0',
    fontSize: 12,
    fontFamily: 'Menlo',
    marginTop: 20,
  },
  summary: {
    color: '#B5B9C0',
    fontWeight: 'bold',
    fontFamily: 'Menlo',
  },
  label: {
    fontWeight: 'bold',
    fontFamily: 'Menlo',
    color: '#0E2146',
  },
  editValue: {
    fontFamily: 'Menlo',
    color: '#0E2146',
  },
  bar: {
    height: StyleSheet.hairlineWidth,
    alignSelf: 'stretch',
    marginBottom: 10,
    backgroundColor: '#EDECED',
  },
  text: {
    fontSize: 16,
    margin: 10,
  },
});

// function Sequence() {
//   const transition = (
//     <Transition.Together>
//       <Transition.Out type="scale" durationMs={1500} />
//       <Transition.Change interpolation="easeInOut" />
//       <Transition.In type="fade" />
//     </Transition.Together>
//   );

//   let [showText, setShowText] = useState(true);
//   const ref = useRef();

//   return (
//     <Transitioning.View
//       ref={ref}
//       transition={transition}
//       style={styles.centerAll}>
//       <Button
//         title="show or hide"
//         color="#FF5252"
//         onPress={() => {
//           ref.current.animateNextTransition();
//           setShowText(!showText);
//         }}
//       />
//       {showText && (
//         <View
//           style={{
//             backgroundColor: '#ff5252',
//             margin: 10,
//             padding: 150,
//             paddingHorizontal: 120,
//           }}>
//           <Text style={{ color: 'white' }}>Who</Text>
//           <Text style={{ color: 'white' }}>dis?</Text>
//         </View>
//       )}
//     </Transitioning.View>
//   );
// }

export default FancyPants;
