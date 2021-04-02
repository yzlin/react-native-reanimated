import React, { useState } from 'react';
import { StyleSheet, View, Text, TouchableHighlight } from 'react-native';
import Animated, { AnimatedRoot, HeroView } from 'react-native-reanimated';

const loremIpsum = `Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc id nibh risus. Quisque malesuada justo at ex tincidunt, at commodo lacus consequat. Cras magna turpis, malesuada a egestas et, elementum vulputate risus.`;

type ItemData = {
    name: string,
    desc: string,
};

const DATA: Array<ItemData> = [
    {
        name: "ItemA",
        desc: loremIpsum,
    },
    {
        name: "ItemB",
        desc: loremIpsum,
    },
    {
        name: "ItemC",
        desc: loremIpsum,
    },
    {
        name: "ItemD",
        desc: loremIpsum,
    },
];

function Item({asMenuItem, name, desc, choose}) {
    const Wrapper: React.ElementType = (asMenuItem)? TouchableHighlight : View;
    return (
       
            <Wrapper style={Styles.item} onPress={() => {choose(name)}}>
                <View>
                    <Text>{name}</Text>
                    {!asMenuItem && <Text>{desc}</Text>}
                </View>
            </Wrapper>
      
    );
}

export function HeroExample(): React.ReactElement {
    const [items, setItems] = useState(DATA);
    const [chosen, setChosen] = useState<ItemData | null>(null);

    function choose(name) {
        setItems(DATA.filter(i => !(i.name === name)));
        setChosen(DATA.find(i => (i.name === name)) as ItemData);
    }

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
        <View style={{flex:1, paddingTop: 100}}>
            <AnimatedRoot mounting={mounting} unmounting={unmounting}>
                <View style={{flex: 1}}>
                    <View style={Styles.menu}> 
                        {items.map((item) => (
                            <Item asMenuItem={true} name={item.name} desc={item.desc} key={item.name} choose={choose}/>
                        ))}
                    </View>
                    <View style={Styles.chosen}>
                        {chosen && <Item name={chosen.name} desc={chosen.desc}/>}
                    </View>
                </View>
            </AnimatedRoot>
        </View>
    );
}

const Styles = StyleSheet.create({
    menu: {
        width: '100%',
        flexDirection: 'row',
        flex: 1,
        alignItems: 'center',
        justifyContent: 'space-between',
        borderWidth: 1,
        borderColor: 'black',
    },
    chosen: {
        flex: 8,
    },
    item: {
        padding: 5,
        margin: 5,
        borderWidth: 1,
    },
});