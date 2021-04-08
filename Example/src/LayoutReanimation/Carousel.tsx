import React, { useState } from 'react';
import { View, Text, Button, StyleSheet, Image } from 'react-native';
import Animated, { 
    useAnimatedStyle, 
    AnimatedLayout, 
    withTiming, 
    withSpring, 
    ReverseAnimation,  
    SlideAnimation,
} from 'react-native-reanimated';

const DATA = [
    {
        pokemonName: "Bulbasaur",
        firstType: 'poison',
        secondType: 'grass',
        img: require('./Bulbasaur.png'),
    },
    {
        pokemonName: "Charizard",
        firstType: "Fire",
        secondType: 'flying',
        img: require('./Charizard.png'),
    },
    {
        pokemonName: 'Butterfree',
        firstType: 'Bug',
        secondType: 'flying',
        img: require('./Butterfree.png'),
    },
]

function AnimatedView({pokemon}) {

    return (
        <AnimatedLayout 
        animation={withSpring(1)} 
        mounting={SlideAnimation('right')} 
        unmounting={SlideAnimation('right')} >
            <Animated.View style={[styles.animatedView]} >
                <Image source={pokemon.img} />
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