import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jeka_lamp_app/core/bluetooth/bluetooth_connect.dart';
import 'package:jeka_lamp_app/core/bluetooth/bluetooth_connect_state.dart';
import 'package:jeka_lamp_app/core/utils/bottom_navigation_element.dart';
import 'package:jeka_lamp_app/presentation/home_screen/home_screen_state.dart';
import 'package:jeka_lamp_app/presentation/pages/alarm/alarm_cubit.dart';
import 'package:jeka_lamp_app/presentation/pages/effect/effect_cubit.dart';
import 'package:jeka_lamp_app/presentation/pages/effect/effect_page.dart';
import 'package:jeka_lamp_app/presentation/pages/effect/effect_state.dart';
import 'package:jeka_lamp_app/locator_service.dart' as di;
import 'package:jeka_lamp_app/presentation/send_data.dart';

class HomeScreenCubit extends Cubit<HomeScreenState> {
  final SendData _sendData;

  HomeScreenCubit({required SendData sendData})
      : _sendData = sendData,
        super(
          const HomeScreenState(
            autoSendData: false,
            uiBloc: false,
            isOn: false,
          ),
        ) {
    di.s1<BluetoothConnect>().connectionStateStream.listen(
      (results) {
        if (results is BCOffState) {
          emit(state.copyWith(uiBloc: true));
        } else if (results is BCConnectedState) {

          di.s1<BluetoothConnect>().receiveData(
                onValueReceived,
                serviceUuidStr: "1234",
                characteristicUuidStr: "1234",
              );
          di.s1<BluetoothConnect>().receiveData(
                di.s1<EffectCubit>().onValueReceived,
                serviceUuidStr: "1234",
                characteristicUuidStr: "1235",
              );
          di.s1<BluetoothConnect>().receiveData(
                di.s1<AlarmCubit>().onValueReceived,
                serviceUuidStr: "1234",
                characteristicUuidStr: "1236",
              );

          // di.s1<BluetoothConnect>().readData(
          //       serviceUuidStr: "1234",
          //       characteristicUuidStr: "1234",
          //     );
              
          // di.s1<BluetoothConnect>().readData(
          //       serviceUuidStr: "1234",
          //       characteristicUuidStr: "1235",
          //     );
          emit(state.copyWith(uiBloc: false));

        }
      },
      onDone: () {},
      onError: (e) => print(e),
    );
  }

  void onValueReceived(List<int> values) {
    emit(state.copyWith(isOn: values[0] == 0 ? false : true));
  }

  Future<void> onOff() async {
    var temp = !state.isOn;
    var s = state;
    var s1 = s.copyWith(isOn: temp);
    emit(s1);
    _sendData.sendLampState(temp);
  }

  void autoSendDataChange(bool value) {
    emit(state.copyWith(autoSendData: value));
    _sendData.autoMode = value;
  }

  void uploadData() {
    _sendData();
  }
}
