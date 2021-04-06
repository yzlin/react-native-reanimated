import React, { useState } from 'react';
import { StyleSheet, View, Text, TouchableOpacity } from 'react-native';
import Animated, { AnimatedRoot, HeroView, withTiming } from 'react-native-reanimated';

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
    const Wrapper: React.ElementType = (asMenuItem)? TouchableOpacity : View;

    function mounting(progress, target) {
        'worklet'
        return {
            height: progress * target.height,
            width: progress * target.width,
        }
    }

    return (
        <HeroView heroId={name} style={Styles.item}>
            <Wrapper onPress={() => {choose(name)}}>
                <View>
                    <Text>{name}</Text>
                    {!asMenuItem && <Text>{desc}</Text>}
                </View>
            </Wrapper>
        </HeroView>
    );
}

export function HeroExample(): React.ReactElement {
    const [items, setItems] = useState(DATA);
    const [chosen, setChosen] = useState<ItemData | null>(null);

    function choose(name) {
        setItems(DATA.filter(i => !(i.name === name)));
        setChosen(DATA.find(i => (i.name === name)) as ItemData);
    }

    return (
        <View style={{flex:1}}>
            <AnimatedRoot animation={withTiming(1, {duration: 3000})} style={{flex:1}} >
                <View style={{flex: 1}}>
                    <View style={Styles.menu}> 
                        {items.map((item) => (
                            <Item asMenuItem={true} name={item.name} desc={item.desc} key={item.name} choose={choose}/>
                        ))}
                    </View>
                    <View style={Styles.chosen}>
                        {chosen && <Item key={chosen.name} name={chosen.name} desc={chosen.desc}/>}
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
        flexDirection: 'column-reverse'
    },
    item: {
        padding: 5,
        margin: 5,
        borderWidth: 1,
    },
});