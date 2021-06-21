import Animated, {
  useSharedValue,
  withTiming,
  useAnimatedStyle,
  Easing,
  withRepeat,
} from 'react-native-reanimated';
import { View, Button } from 'react-native';
import Icon from 'react-native-vector-icons/Feather';
import { createStackNavigator } from '@react-navigation/stack';
import { createNativeStackNavigator } from 'react-native-screens/native-stack';
import React from 'react';
import { enableScreens } from 'react-native-screens';

enableScreens(true);

const AnimatedIcon = Animated.createAnimatedComponent(Icon);

export function ActivityIcon() {
  const rotation = useSharedValue(0);

  React.useEffect(() => {
    rotation.value = withRepeat(withTiming(360, { duration: 750, easing: Easing.linear }), 0);
  }, []);

  const animatedStyle = useAnimatedStyle(() => {
    return { transform: [{ rotate: `${rotation.value}deg` }] };
  });

  return (
    <View style={{height: 300, width: 300,}}>
      <AnimatedIcon color="black" name="loader" size={16} style={animatedStyle} />
    </View>
  );
}

function AnimatedStyleUpdateExample({navigation}: any): React.ReactElement {
  return (
    <View
      style={{
        flex: 1,
        flexDirection: 'column',
      }}>
      <Button title="next screen" onPress={() => {navigation.push('Home')} } />
      <ActivityIcon />
      <ActivityIcon />
      <ActivityIcon />
      
    </View>
  );
}

const Stack = createNativeStackNavigator();//;createStackNavigator();

export default function Screens() {
  return (
    <Stack.Navigator screenOptions={{stackAnimation:"none"}} >
      <Stack.Screen name="Home" component={AnimatedStyleUpdateExample} />
    </Stack.Navigator>
  );
};
