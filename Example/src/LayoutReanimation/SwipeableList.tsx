import React, { useState } from 'react';
import {View, Button, Text, ScrollView, StyleSheet } from 'react-native';
import { AnimatedRoot, withTiming, withSpring } from 'react-native-reanimated';

function unmounting(progress, initialValues, depth) {
    'worklet'
    return {
        height: (1-progress) * initialValues.height,
    }
}

const FRUITS = [
    'banana',
    'strawberry',
    'apple',
    'kiwi',
    'orange',
    'blueberry',
]

export function SwipeableList() {
    const [fruits, setFruits] = useState(FRUITS);
    return (
        <View>
            <View>
                <AnimatedRoot animation={withTiming(1)} unmounting={unmounting}>
                    { 
                        fruits.map(value => {
                           return (
                                <View key={value} style={[Styles.item, {backgroundColor: value==='kiwi'? 'green' : 'yellow'}]} >
                                    <Text> { value } </Text>
                                    <Button title="remove" onPress={
                                        () => {
                                            setFruits(fruits.filter(i => (i !== value)));
                                        }
                                    } />
                                </View>
                            )
                        })
                    }
                </AnimatedRoot>
            </View>
        </View>
    );
}

const Styles = StyleSheet.create({
    item: {
        height: 50,
        width: '100%',
        alignItems: 'center',
        justifyContent: 'center',
        borderWidth: 1,
        borderBottomWidth: 0,
        borderColor: 'black',
        flexDirection: 'row',
    }
});