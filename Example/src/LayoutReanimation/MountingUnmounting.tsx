import { isCompletionStatement } from 'babel-types';
import React, { useState } from 'react';
import { View, Text, Button, StyleSheet } from 'react-native';
import Animated, { useAnimatedStyle, AnimatedLayout, withTiming, withSpring } from 'react-native-reanimated';

function AnimatedView() {

    const style = useAnimatedStyle(() => {
        return {}
    });

    const mounting = (progress: number, targetValues, depth) => {
        'worklet';
        if (depth >= 1) return {};
        return {
            opacity: progress,
            originX: targetValues.originX * progress + (1-progress) * (-300),
            transform: [
                {rotate: `${(Math.max(progress, 1) - 1) * 90}deg`},
            ],
        }
    }

    const unmounting = (progress: number, initialValues) => {
        'worklet';
        return {
            opacity: 1 - progress,
            originX: initialValues.originX * (1-progress) + progress * (1000),
        }
    }

    return (
        <AnimatedLayout isShallow={false} animation={withSpring(1)} mounting={mounting} unmounting={unmounting} >
            <Animated.View style={[styles.animatedView, style]} >
                <Text> kk </Text>
            </Animated.View>
        </AnimatedLayout>
    );
}

export function MountingUnmounting(): React.ReactElement {
    const [show, setShow] = useState(false);
    return (
        <View style={{flexDirection: 'column-reverse'}}>
            <Button title="toggle" onPress={() => {setShow((last) => !last)}}/>
            <View style={{height: 400, alignItems: 'center', justifyContent: 'center'}}>
                {show && <AnimatedView />}
            </View>
        </View>
    );
}

const styles = StyleSheet.create({
    animatedView: {
        height: 200,
        width: 100,
        borderWidth: 1,
        borderColor: 'black',
        alignItems: 'center',
        justifyContent: 'center',
        opacity: 0.5,
    },
});