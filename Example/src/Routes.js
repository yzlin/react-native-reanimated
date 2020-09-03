import React, {useEffect, useState} from 'react';
import { View, TouchableOpacity, Text } from 'react-native';
import LoadingView from './Screens';

const Routes = (props) => {
  const [pres, setPres] = useState(true);

  return (
    <View style={{padding: 50}}>
      {pres && <LoadingView />}
      <TouchableOpacity onPress={() => {setPres(!pres)}}>
        <Text>
          switch
        </Text>
      </TouchableOpacity>
    </View>
  );
};

export default Routes;
