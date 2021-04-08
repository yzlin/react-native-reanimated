import React, { useState } from 'react';
import { View, Text, Button, StyleSheet, Image } from 'react-native';
import Animated, { useAnimatedStyle, AnimatedLayout, withTiming, withSpring, ReverseAnimation } from 'react-native-reanimated';

const DATA = [
    {
        pokemonName: "Bulbasaur",
        firstType: 'poison',
        secondType: 'grass',
    },
    {
        pokemonName: "Charizard",
        firstType: "Fire",
        secondType: 'flying',
    },
    {
        pokemonName: 'Butterfree',
        firstType: 'Bug',
        secondType: 'flying',
    },
]

function AnimatedView({pokemon}) {

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

    return (
        <AnimatedLayout isShallow={false} animation={withTiming(1, {duration: 2000})} mounting={mounting} >
            <Animated.View style={[styles.animatedView]} >
                <Image source={`./${pokemon.pokemonName}.png`} />
                <View>
                    <Text> { pokemon.firstType } </Text>
                    <Text> { pokemon.secondType }</Text>
                </View>
            </Animated.View>
        </AnimatedLayout>
    );
}



export function Carousel(): React.ReactElement {
    const [currentIndex, incrementIndex] = useState(0);
    return (
        <View style={{flexDirection: 'column-reverse'}}>
            <Button title="toggle" onPress={() => { incrementIndex((prev) => ((prev+1) % DATA.length))}}/>
            <View style={{height: 400, alignItems: 'center', justifyContent: 'center', borderWidth: 1}}>
                <AnimatedView key={currentIndex} pokemon={DATA[currentIndex]} />
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