import { isCompletionStatement } from 'babel-types';
import React, { useState } from 'react';
import { View, Text, Button, StyleSheet } from 'react-native';
import Animated, { AnimatedLayout } from 'react-native-reanimated';

const AnimatedText = Animated.createAnimatedComponent(Text);

function AnimatedView() {

    return (
        <Animated.View>
            <Animated.View style={styles.left} />
            <Animated.View style={styles.top} />
            <Animated.View style={styles.animatedView} >
                <AnimatedText> kk </AnimatedText>
            </Animated.View>
        </Animated.View>
    );
}

export function MountingUnmounting(): React.ReactElement {
    const [show, setShow] = useState(false);
    return (
        <View style={{flexDirection: 'column-reverse'}}>
            <AnimatedLayout>
                <Button title="toggle" onPress={() => {setShow((last) => !last)}}/>
                <View style={{height: 400, alignItems: 'center', justifyContent: 'center'}}>
                    {show && <AnimatedView />}
                </View>
            </AnimatedLayout>
        </View>
    );
}

const styles = StyleSheet.create({
    animatedView: {
        height: 100,
        width: 200,
        borderWidth: 3,
        borderColor: '#001a72',
        alignItems: 'center',
        justifyContent: 'center',
    },
    left: {
        height: 100,
        width: 50,
        borderWidth: 3,
        borderColor: '#001a72',
        borderRightWidth: 0,
        transform:[
            {translateX: -50},
            {translateY: 100},
            { skewY: 15},
            {translateY: 32},
        ],
    },
    top: {
        height: 50,
        width: 200,
        borderWidth: 3,
        borderColor: '#001a72',
        borderBottomWidth: 0,
        transform:[
            { skewX: 15},
            {translateX: -16},
        ],
    }
});