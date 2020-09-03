import React, {useEffect, useState} from 'react';
import { View, TouchableWithoutFeedback } from 'react-native';
import LoadingView from './Screens';

const Routes = (props) => {
  const [pres, setPres] = useState(true);

  return (
    <View style={{padding: 50}}>
      {pres && <LoadingView />}
      <TouchableWithoutFeedback onPress={() => {setPres(!pres)}}>
        <View style={{ width: 70, height: 70, backgroundColor: 'black' }} />
      </TouchableWithoutFeedback>
    </View>
  );
};

export default Routes;
