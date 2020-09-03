/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 * @flow strict-local
 */

import React from 'react';
import {SafeAreaView, StyleSheet, View} from 'react-native';
import Routes from './Routes';
import {SafeAreaProvider} from 'react-native-safe-area-context';

const App: () => React$Node = () => {
  return (
    <SafeAreaProvider>
      <View style={styles.mainWrapper}>
          <Routes />
      </View>
    </SafeAreaProvider>
  );
};

const styles = StyleSheet.create({
  mainWrapper: {
    flex: 1,
    backgroundColor: 'red',
  },
});

export default App;
