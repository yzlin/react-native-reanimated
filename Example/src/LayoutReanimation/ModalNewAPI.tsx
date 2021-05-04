import React, { useState } from 'react';
import { View, Text, Button, StyleSheet, Dimensions } from 'react-native';
import Animated, { useAnimatedStyle, withTiming, withStartValue} from 'react-native-reanimated';

const {width, height} = Dimensions.get('window');

function AnimatedView() {

    const style = useAnimatedStyle({
        entering: (targetValues) => {
            'worklet'
            return {
                originX: withStartValue(-width, withTiming(targetValues.originX, {duration: 2000})),
                opacity: withStartValue(0, withTiming(1, {duration: 1500})),
            };
        }, 
        steady : () => {
            'worklet'
            return {
            };
        },
        exiting: (startingValues) => {
            'worklet'
            console.log("starting Values ", startingValues);
            console.log("width", width);
            return {
                originX: withStartValue(startingValues.originX, withTiming(width, {duration: 3000})),
                opacity: withStartValue(1, withTiming(0.5, {duration: 2000})),
            };
        }
    });

    return (
        <Animated.View style={[styles.animatedView, style]} >
            <Text> kk </Text>
        </Animated.View>
    );
}

export function ModalNewAPI(): React.ReactElement {
    const [show, setShow] = useState(false);
    return (
        <View style={{flexDirection: 'column-reverse'}}>
            <Button title="toggle" onPress={() => {setShow((last) => !last)}}/>
            <View style={{height: 400, alignItems: 'center', justifyContent: 'center', borderWidth: 1}}>
                {show && <AnimatedView />}
            </View>
        </View>
    );
}

const styles = StyleSheet.create({
    animatedView: {
        height: 300,
        width: 200,
        borderWidth: 1,
        borderColor: 'black',
        alignItems: 'center',
        justifyContent: 'center',
        backgroundColor: "red",
    },
});