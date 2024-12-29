import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jeka_lamp_app/core/bluetooth/bluetooth_button.dart';
import 'package:jeka_lamp_app/core/bluetooth/bluetooth_control_cubit.dart';

class BluetoothConnect {
  BluetoothControlCubit? bluetoothControlCubit;

  BluetoothControlCubit init() {
    bluetoothControlCubit ??= BluetoothControlCubit();
    bluetoothControlCubit?.initEvent();
    return bluetoothControlCubit!;
    
  }

  Widget bluetoothButton(){
    if (bluetoothControlCubit == null){
      throw Exception("BluetoothControlCubit не инициализирован. Вызовите init() перед использованием bluetoothButton().");
    }
    return BlocProvider.value(
      value: bluetoothControlCubit!,
      child: BluetoothButton(),
    );
  }
}
