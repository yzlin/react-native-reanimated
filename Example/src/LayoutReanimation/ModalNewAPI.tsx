import { SlideFromRightIOS } from '@react-navigation/stack/lib/typescript/src/TransitionConfigs/TransitionPresets';
import React, { useState } from 'react';
import { View, Text, Button, StyleSheet, Dimensions } from 'react-native';
import Animated, { AnimatedLayout, withTiming, withStartValue} from 'react-native-reanimated';

const {width, height} = Dimensions.get('window');

function AnimatedView() {

    const entering = (targetValues) => {
        'worklet'
        const animations = {
            originX: withStartValue(-width, withTiming(targetValues.originX, {duration: 3000})),
            opacity: withStartValue(0, withTiming(1, {duration: 2000})),
            borderRadius: withStartValue(10, withTiming(30, { duration: 3000 })),
        };
        const initialValues = {
            originX: -width,
            opacity: 0,
            borderRadius: 10,
        };
        return {
           initialValues,
           animations,
        };
    };

    const exiting = (startingValues) => {
        'worklet'
        console.log("starting Values ", startingValues);
        console.log("width", width);
        const animations = {
            originX: withStartValue(startingValues.originX, withTiming(width, {duration: 3000})),
            opacity: withStartValue(1, withTiming(0.5, {duration: 2000})),
        };
        const initialValues = {
            originX: startingValues.originX,
            opacity: 1,
        };

        return {
           animations,
           initialValues,
        };
    }

    return (
        <Animated.View style={[styles.animatedView]} {...{entering, exiting}} >
            <Text> kk </Text>
        </Animated.View>
    );
}

export function ModalNewAPI(): React.ReactElement {
    const [show, setShow] = useState(false);
    return (
        <View style={{flexDirection: 'column-reverse'}}>
            <AnimatedLayout>
                <Button title="toggle" onPress={() => {setShow((last) => !last)}}/>
                <View style={{height: 400, alignItems: 'center', justifyContent: 'center', borderWidth: 1}}>
                    {show && <AnimatedView />}
                </View>
            </AnimatedLayout>
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