export const DefaultEntering = (targetValues) => {
    'worklet'
    return {
        initialValues = {
            originX: targetValues.originX,
            originY: targetValues.originY,
            width: targetValues.width,
            height: targetValues.height,
        },
        animations: {},
    }
};

export const DefaultLayout = (values) => {
    'worklet'
    return {
        initialValues = {},
        animations: {},
    }
};

export const DefaultExiting = (startValues) => {
    'worklet'
    return {
        initialValues = {
            originX: startValues.originX,
            originY: startValues.originY,
            width: startValues.width,
            height: startValues.height,
        },
        animations: {},
    }
};

export const 

export const Layout = (values) => {
    'worklet'
    return {
        initialValues = {
            originX: values.boriginX,
            originY: values.boriginY,
            width: values.bwidth,
            height: values.bheight,
        },
        animations: {
            originX: withStartValue(values.boriginX, withTiming(values.originX)),
            originY: withStartValue(values.boriginY, withTiming(values.originY)),
            width: withStartValue(values.bwidth, withTiming(values.width)),
            height: withStartValue(values.bheight, withTiming(values.height)),
        },
    }
}

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

export function SlideAnimation(direction) {
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

    return (progrezz, values, depth, isMounting, isReversed) => {
        'worklet';
        let progress = progrezz;
        let mutableModX = modX;
        let mutableModY = modY;
        console.log("values", values);
        if (depth > 0) return {};
        if (!isMounting) {
            if (!isReversed) {
                progress = 1 - progress;
            }
            mutableModX *= -1;
            mutableModY *= -1;
        }
        const startX = values.originX + mutableModX * values.windowWidth;
        const startY = values.originY + mutableModY * values.windowHeight;
        return {
            originX: (1-progress) * startX + (progress) * values.originX,
            originY: (1-progress) * startY + (progress) * values.originY, 
        };
    }
}

