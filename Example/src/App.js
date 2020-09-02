/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 * @flow strict-local
 */

import React from 'react';
import {SafeAreaView, StyleSheet, StatusBar, View, Text} from 'react-native';
import {NavigationContainer} from '@react-navigation/native';
import Routes from './Routes';
import {SafeAreaProvider} from 'react-native-safe-area-context';

const App: () => React$Node = () => {
  return (
    <SafeAreaProvider>
      <StatusBar barStyle="light-content" />
      <View style={styles.mainWrapper}>
        <NavigationContainer
          theme={{
            dark: true,
            colors: {
              background: '#000000',
              primary: 'red',
              border: 'red',
              text: 'red',
              notification: 'red',
              background: 'red',
            },
          }}>
          <Routes />
        </NavigationContainer>
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
