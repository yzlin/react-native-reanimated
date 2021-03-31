import { NavigationContainer } from '@react-navigation/native';
import React, { useState } from 'react';
import { View, Text, Button, StyleSheet } from 'react-native';
import { createStackNavigator } from '@react-navigation/stack';
import { Home, SpringLayoutAnimation, MountingUnmounting, SwipeableList } from './LayoutReanimation';

const Stack = createStackNavigator();

const Screens = [
  {
    name: 'Spring Layout Animation',
    screen: SpringLayoutAnimation,
  },
  {
    name: 'Mounting Unmounting',
    screen: MountingUnmounting,
  },
  {
    name: 'Swipeable list',
    screen: SwipeableList,
  }
];

export default function App(): React.ReactElement {
  return (
    <NavigationContainer>
      <Stack.Navigator initialRouteName="Home">
        <Stack.Screen name="Home" >
          {props => <Home {...props} screens={Screens}/>}
        </Stack.Screen>
         { Screens.map(screen => (
           <Stack.Screen name={screen.name} component={screen.screen}/>
         )) }
      </Stack.Navigator>
    </NavigationContainer>
  );
}