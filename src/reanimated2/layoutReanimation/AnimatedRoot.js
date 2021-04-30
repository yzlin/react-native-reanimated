import { requireNativeComponent, findNodeHandle, unstable_enableLogBox } from 'react-native';
import React from 'react';
import { runOnUI, makeMutable } from '../core';
import { withTiming, withStyleAnimation } from '../animations';
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
        let {mounting, unmounting} = this.props;
    
        const config = {
            mountingAnimation: mounting,
            unmountingAnimation: unmounting,
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
            startAnimationForTag(tag, isMounting, yogaValues, depth) { 
                // TODO use previous animation values like velocity
                // probably we need to store a vector as we don't know a direction
                if (configs[tag] == null) {
                    console.log("dupa", tag);
                    return; // :(
                }

                console.log("animation will be started", tag, JSON.stringify(yogaValues));

                const key = isMounting ? 'mountingAnimation' : 'unmountingAnimation';

                if (typeof configs[tag][key] != 'function') {
                    console.error(`${key} animation for a tag: ${tag} it not a function!`);
                }

                const animation = withStyleAnimation(configs[tag][key], yogaValues, 0);// it should be an animation factory as it has been created on RN side
                console.log("animationObjectKeys", Object.keys(animation));
                const sv = configs[tag].sv;
                const originalCallback = animation.callback;

                animation.callback = (finished) => {
                    _stopObservingProgress(tag, finished);

                    if (originalCallback) {
                        originalCallback(finished);
                    }
                }
                console.log("animation has been started", tag, JSON.stringify(yogaValues));
                configs[tag].sv.value = animation;
                _startObservingProgress(tag, sv);
            },
        };  
    }
)();