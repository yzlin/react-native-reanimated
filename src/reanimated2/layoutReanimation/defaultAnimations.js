export function ReverseAnimation(animation) {
    'worklet'
    return (progress, values, depth) => {
        'worklet'
        return animation(1-progress, values, depth, true);
    }
}

export function ComposeAnimation(animations) {
    'worklet'
    return (progress, values, depth) => {
        'worklet'
        return Object.assign.apply(null, animations.map(animation => animation(progress, values, depth)));
    }
}

export function OpacityAnimation(progress, initial, depth) {
    'worklet'
    if (depth > 0) {
        return {};
    }
    return {
        opacity: (1-progress),
    };
}

