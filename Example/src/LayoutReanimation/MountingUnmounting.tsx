import { isCompletionStatement } from 'babel-types';
import React, { useState } from 'react';
import { View, Text, Button, StyleSheet } from 'react-native';
import Animated, { useAnimatedStyle, AnimatedRoot, withTiming } from 'react-native-reanimated';

type mountingStyle = {
    x?: number,
    y?: number,
    width?: number,
    height?: number,
    opacity?: number,
};

function AnimatedView() {

    const style = useAnimatedStyle(() => {
        return {
            
        }
    });

    const mounting = (progress: number) => {
        'worklet';
        return {
            opacity: progress,
        }
    }

    const unmounting = (progress: number) => {
        'worklet';
        return {
            opacity: 1 - progress,
        }
    }

    return (
        <AnimatedRoot isShallow={true} animation={withTiming(1, {duration: 2000})} mounting={mounting} unmounting={unmounting} >
            <Animated.View style={[styles.animatedView, style]} >
                <Text> kk </Text>
            </Animated.View>
        </AnimatedRoot>
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