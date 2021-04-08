export function ReverseAnimation(animation) {
    'worklet'
    return (progress, values, depth, isMounting, isReversed) => {
        'worklet'
        return animation(1-progress, values, depth, isMounting, !isReversed);
    }
}

export function ComposeAnimation(animations) {
    'worklet'
    return (progress, values, depth, isMounting, isReversed) => {
        'worklet'
        return Object.assign.apply(null, animations.map(animation => animation(progress, values, depth, isMounting, isReversed)));
    }
}

export function OpacityAnimation(progress, initial, depth, isMounting, isReversed) {
    'worklet'
    if (depth > 0) {
        return {};
    }
    return {
        opacity: (progress),
    };
}

function slide(direction) {
    'worklet'
    let modX = 0;
    let modY = 0;

    if (direction === 'right') {
        modX = -1;
    }

    if (direction === 'left') {
        modX = 1;
    }

    if (direction === 'up') {
        modY = -1;
    }

    if (direction === 'down') {
        modY = 1;
    }

    return (progress, values, depth, isMounting) => {
        'worklet';
        if (!isMounting) {
            modX *= -1;
            modY *= -1;
        }
        const startX = values.originX + modX * values.windowWidth;
        const startY = values.originY + modY * values.windowHeight;
        return {
            originX: (1-progress) * startX + (progress) * values.originX,
            originY: (1-progress) * startY + (progress) * values.originY, 
        };
    }
}

