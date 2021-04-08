import { requireNativeComponent, findNodeHandle } from 'react-native';
import React from 'react';
import { runOnUI, makeMutable } from '../core';
import { withTiming } from '../animations';
import { OpacityAnimation, ReverseAnimation } from './defaultAnimations';

const REALayoutView = requireNativeComponent('REALayoutView');
export class AnimatedLayout extends React.Component {
    constructor(props, context) {
        super(props, context);
        this.sv = makeMutable(0);
        this.alreadyConfigured = false;
    }

    setRef(ref) {
        const tag = findNodeHandle(ref);
        if (tag == null || this.alreadyConfigured) return;
        this.alreadyConfigured = true;
        console.log("config For a tag", tag);
        let {animation, mounting, unmounting} = this.props;
        if (animation == null) {
            animation = withTiming(1);
        }
        if (mounting == null) {
            mounting = OpacityAnimation;
        }
        if (unmounting == null) {
            unmounting = ReverseAnimation(mounting);
        }

        const config = {
            animation,
            mounting,
            unmounting,
            sv: this.sv,
        }
        runOnUI(() => {
            'worklet'
            global.LayoutAnimationRepository.registerConfig(tag, config);
        })();
    }

    render() {
        return (
            <REALayoutView {...this.props} animated={true && !(this.props.animated === 'false')} ref={this.setRef.bind(this)} />
        );
    }

    componentWillUnmount() {
        this.sv = null;
    }

}

// Register LayoutAnimationRepository

runOnUI(
    () => {
        'worklet';

        const configs = {};

        global.LayoutAnimationRepository = {
            configs,
            registerConfig(tag, config) {
                configs[tag] = config;
            },
            removeConfig(tag) {
                configs[tag].sv.value = 0;
                delete configs[tag];
            },
            startAnimationForTag(tag) { 
                // TODO use previous animation values like velocity
                // probably we need to store a vector as we don't know a direction
                if (configs[tag] == null) {
                    return; // :(
                }

                if (typeof configs[tag].animation != 'function') {
                    console.error(`Animation for a tag: ${tag} it not a function!`);
                }
                const animation = (configs[tag].animation)(); // it should be an animation factory as it has been created on RN side
                const sv = configs[tag].sv;
                animation.callback = (finished) => {
                    if (finished) {
                        _stopObservingProgress(tag);
                        sv.value = 0;
                    }
                }
                _startObservingProgress(tag, sv);
                sv.value = 0;
                configs[tag].sv.value = animation;
                
            },
            getMountingStyle(tag, progress, targetData, depth) {
                if (configs[tag] == null) {
                    return {}; // :(
                }
                
                return configs[tag].mounting(progress, targetData, depth, true);
            },
            getUnmountingStyle(tag, progress, initialData, depth) {
                if (configs[tag] == null) {
                    return {}; // :(
                }
                return configs[tag].unmounting(progress, initialData, depth, false);
            },
        };  
    }
)();

/*

    <AnimatedRoot animation={withTiming(1)} >
    </AnimatedRoot>
*/