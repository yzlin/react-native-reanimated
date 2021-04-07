import React, { useState } from 'react';
import { View, Text, Button, StyleSheet } from 'react-native';
import Animated, { useAnimatedStyle, AnimatedLayout, withTiming, withSpring, ReverseAnimation } from 'react-native-reanimated';

function AnimatedView() {

    const style = useAnimatedStyle(() => {
        return {}
    });

    const mounting = (progress: number, targetValues, depth) => {
        'worklet';
        if (depth > 0) return {};

        console.log("targetValues ", targetValues, " progress ", progress);

        return {
            transform: [
               { translateY: targetValues.height/2 },
                { perspective: 500 },
                { rotateX: `${(1-progress) * 90}deg`},
                { translateY: -targetValues.height/2 },
                { translateY: 300 * (1-progress) },
            ],
        }
    }

    const unmounting = (progress: number, initialValues) => {
        'worklet';
        return {
            opacity: 1 - progress,
        }
    }

    const unmounting2 = (progress: number, initialValues) => {
        'worklet';
        return {
            height: (1-progress) * initialValues.height,
        }
    }

    const unmounting3 = (progress: number, initialValues, depth) => {
        'worklet';
        if (depth !== 0) return {};
        return {
           transform: [
               { rotateX: `${(progress) * 90}deg` }
           ],
        };
    }

    return (
        <AnimatedLayout isShallow={false} animation={withTiming(1, {duration: 5000})} mounting={mounting} >
            <Animated.View style={[styles.animatedView, style]} >
                <Text> kk </Text>
            </Animated.View>
        </AnimatedLayout>
    );
}

export function Modal(): React.ReactElement {
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