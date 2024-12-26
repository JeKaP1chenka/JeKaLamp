import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jeka_lamp_app/core/bluetooth/bluetooth_control_cubit.dart';
import 'package:jeka_lamp_app/core/widgets/bluetooth_button.dart';

class BluetoothConnect {
  BluetoothControlCubit? bluetoothControlCubit;

  BluetoothControlCubit init() {
    bluetoothControlCubit = BluetoothControlCubit();
    return bluetoothControlCubit!;
  }

  Widget bluetoothButton(BuildContext context){
    if (bluetoothControlCubit == null){
      throw Exception("хуй кота");
    }
    return BluetoothButton(bluetoothControlCubit);
  }
}
