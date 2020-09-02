import React, {useEffect} from 'react';
import {createStackNavigator} from '@react-navigation/stack';
import {FirstScreen, SecondScreen, ThirdScreen, FourthScreen} from './Screens';

const Stack = createStackNavigator();

const FIRST_SCREEN = 'first';
const SECOND_SCREEN = 'second';
const THIRD_SCREEN = 'third';
const FOURTH_SCREEN = 'fourth';

const Routes = (props) => {
  return (
    <Stack.Navigator initialRouteName={FIRST_SCREEN}>
      <Stack.Screen
        name={FIRST_SCREEN}
        component={FirstScreen}
        options={{header: () => null}}
      />
      <Stack.Screen
        name={SECOND_SCREEN}
        component={SecondScreen}
        options={{header: () => null}}
      />
    </Stack.Navigator>
  );
};

export default Routes;
