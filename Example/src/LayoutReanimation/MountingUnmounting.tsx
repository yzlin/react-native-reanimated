import { isCompletionStatement } from 'babel-types';
import React, { useState } from 'react';
import { View, Text, Button, StyleSheet } from 'react-native';
import Animated, { AnimatedLayout, SlideInRight, SlideOutRight, SlideInDown, SlideOutUp, OpacityIn, OpacityOut, SlideOutLeft, SlideInLeft } from 'react-native-reanimated';

const AnimatedText = Animated.createAnimatedComponent(Text);

function AnimatedView() {

    return (
        <Animated.View>
            <Animated.View collapsable={false} key="left" entering={SlideInRight.delay(300)} exiting={SlideOutLeft.delay(300)} style={styles.left} />
            <Animated.View collapsable={false} key="top"  entering={SlideInDown} exiting={SlideOutUp} style={styles.top} />
            <Animated.View collapsable={false} key="center" entering={SlideInLeft} exiting={SlideOutRight} style={styles.animatedView} >
                <AnimatedText entering={OpacityIn.delay(600).duration(3000)} exiting={OpacityOut.duration(3000)}> SWM </AnimatedText>
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
                    {show && <AnimatedView key={Math.random().toString()}/>}
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
            { skewY: '45deg'},
            {translateY: 25},
        ],
    },
    top: {
        height: 50,
        width: 200,
        borderWidth: 3,
        borderColor: '#001a72',
        borderBottomWidth: 0,
        borderLeftWidth: 0,
        transform:[
            { skewX: '45deg'},
            {translateX: -25},
        ],
    }
});