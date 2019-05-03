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

function Record({ label, value }) {
  return (
    <View style={styles.row}>
      <Text style={[styles.label, { color: '#071225' }]}>{label}</Text>
      <Text style={[styles.editText, { color: '#616161' }]}>{value}</Text>
    </View>
  );
}

function Row({ label, value, transitioningRef }) {
  const [expanded, setExpanded] = useState(false);

  const flip = () => {
    transitioningRef.current.animateNextTransition();
    setExpanded(!expanded);
  };

  return (
    <TouchableHighlight
      onPress={flip}
      style={[
        expanded ? styles.expandedRow : styles.rowBtn,
        transitioningRef ? { zIndex: 200 } : {},
      ]}
      underlayColor="#eee">
      <View>
        {expanded && (
          <>
            <Record label="Five Barrel" value="79.20" />
            <Record label="Philipz" value="55.10" />
            <Record label="Moonbucks" value="16.20" />
            <View style={styles.bar} />
          </>
        )}
        <View style={styles.row}>
          <Text style={styles.label}>{label}</Text>
          <TextInput
            style={[styles.editText, { color: '#B5B9C0' }]}
            keyboardType="decimal-pad"
            value={value}
          />
        </View>
      </View>
    </TouchableHighlight>
  );
}

function FancyPants() {
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

  const transition = (
    <Transition.Sequence>
      <Transition.Out type="fade" />
      <Transition.Change interpolation="easeInOut" />
      <Transition.In type="circle-clip" interpolation="easeOut" />
    </Transition.Sequence>
  );

  return (
    <Transitioning.View ref={ref} transition={transition} style={{ flex: 1 }}>
      <View style={styles.card}>
        <Row label="Food" value="10.80" />
        <Row label="Coffee" value="150.50" transitioningRef={ref} />
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
  rowBtn: {
    alignSelf: 'stretch',
    marginHorizontal: -20,
    paddingHorizontal: 20,
    backgroundColor: 'white',
    // shadowColor: '#000',
    // shadowOffset: {
    //   width: 0,
    //   height: 2,
    // },
    // shadowOpacity: 0.25,
    // shadowRadius: 3.84,
    // elevation: 5,
  },
  expandedRow: {
    // zIndex: 200,
    alignSelf: 'stretch',
    marginHorizontal: -30,
    padding: 20,
    backgroundColor: 'white',
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.25,
    shadowRadius: 3.84,
    elevation: 5,
  },
  row: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    width: '100%',
    fontWeight: 'bold',
    marginVertical: 10,
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
