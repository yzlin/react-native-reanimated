import React, {useEffect, useState} from 'react';
import { View, Text, TouchableWithoutFeedback } from 'react-native';
import LoadingView from './Screens';

const Routes = (props) => {
  const [pres, setPres] = useState(true);

  return (
    <View style={{padding: 50}}>
      {pres && <LoadingView />}
      <TouchableWithoutFeedback onPress={() => {setPres(!pres)}}>
        <Text>
          switch
        </Text>
      </TouchableWithoutFeedback>
    </View>
  );
};

export default Routes;
