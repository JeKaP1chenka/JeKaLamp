import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter/material.dart';
import 'package:jeka_lamp_app/core/bluetooth/bluetooth_control_cubit.dart';



class BluetoothButton extends StatelessWidget {
  const BluetoothButton(BluetoothControlCubit? bluetoothControlCubit, {super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      builder: (context, state) {
        
      },
    );
  }
}
