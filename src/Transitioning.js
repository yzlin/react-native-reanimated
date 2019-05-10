import React from 'react';
import { View, findNodeHandle } from 'react-native';
import ReanimatedModule from './ReanimatedModule';

const TransitioningContext = React.createContext();

// function configFromProps(type, props) {
//   const config = { type };
//   if ('durationMs' in props) {
//     config.durationMs = props.durationMs;
//   }
//   if ('interpolation' in props) {
//     config.interpolation = props.interpolation;
//   }
//   if ('type' in props) {
//     config.animation = props.type;
//   }
//   if ('delayMs' in props) {
//     config.delayMs = props.delayMs;
//   }
//   if ('propagation' in props) {
//     config.propagation = props.propagation;
//   }
//   return config;
// }

// class In extends React.Component {
//   static contextType = TransitioningContext;
//   componentDidMount() {
//     this.context.push(configFromProps('in', this.props));
//   }
//   render() {
//     return this.props.children || null;
//   }
// }

// class Change extends React.Component {
//   static contextType = TransitioningContext;
//   componentDidMount() {
//     this.context.push(configFromProps('change', this.props));
//   }
//   render() {
//     return this.props.children || null;
//   }
// }

// class Out extends React.Component {
//   static contextType = TransitioningContext;
//   componentDidMount() {
//     this.context.push(configFromProps('out', this.props));
//   }
//   render() {
//     return this.props.children || null;
//   }
// }

// class Together extends React.Component {
//   static contextType = TransitioningContext;
//   transitions = [];
//   componentDidMount() {
//     const config = configFromProps('group', this.props);
//     config.transitions = this.transitions;
//     this.context.push(config);
//   }
//   render() {
//     return (
//       <TransitioningContext.Provider value={this.transitions}>
//         {this.props.children}
//       </TransitioningContext.Provider>
//     );
//   }
// }

// class Sequence extends React.Component {
//   static contextType = TransitioningContext;
//   transitions = [];
//   componentDidMount() {
//     const config = configFromProps('group', this.props);
//     config.sequence = true;
//     config.transitions = this.transitions;
//     this.context.push(config);
//   }
//   render() {
//     return (
//       <TransitioningContext.Provider value={this.transitions}>
//         {this.props.children}
//       </TransitioningContext.Provider>
//     );
//   }
// }

// function createTransitioningComponent(Component) {
//   class Wrapped extends React.Component {
//     propTypes = Component.propTypes;
//     transitions = [];
//     viewRef = React.createRef();

//     componentDidMount() {
//       if (this.props.animateMount) {
//         this.animateNextTransition();
//       }
//     }

//     setNativeProps(props) {
//       this.viewRef.current.setNativeProps(props);
//     }

//     animateNextTransition() {
//       const viewTag = findNodeHandle(this.viewRef.current);
//       ReanimatedModule.animateNextTransition(viewTag, {
//         transitions: this.transitions,
//       });
//     }

//     render() {
//       const { transition, ...rest } = this.props;
//       return (
//         <React.Fragment>
//           <TransitioningContext.Provider value={this.transitions}>
//             {transition}
//           </TransitioningContext.Provider>
//           <Component {...rest} ref={this.viewRef} collapsable={false} />
//         </React.Fragment>
//       );
//     }
//   }
//   return Wrapped;
// }

import flattenStyle from 'react-native/lib/flattenStyle';

class TransitioningView extends React.Component {
  static contextType = TransitioningContext;
  _viewRef = React.createRef();
  componentDidUpdate(oldProps) {
    const prevStyle = flattenStyle(oldProps.style);
    const nextStyle = flattenStyle(this.props);
    const viewTag = findNodeHandle(this._viewRef.current);
    ReanimatedModule.animateChange(viewTag, {});
  }
  componentDidMount() {
    const viewTag = findNodeHandle(this._viewRef.current);
    const config = {};
    if (this.props.transitionFrom) {
      config.transitionFrom = findNodeHandle(this.props.transitionFrom);
    }
    ReanimatedModule.animateAppear(viewTag, config);
  }
  componentWillUnmount() {
    const viewTag = findNodeHandle(this._viewRef.current);
    const config = {};
    if (this.props.transitionFrom) {
      config.transitionFrom = findNodeHandle(this.props.transitionFrom);
    }
    ReanimatedModule.animateDisappear(viewTag, config);
  }
  render() {
    return <View {...this.props} ref={this._viewRef} />;
  }
}

const Transitioning = {
  View: TransitioningView,
};

export { Transitioning };
