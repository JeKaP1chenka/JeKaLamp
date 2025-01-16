import 'package:equatable/equatable.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothControlState extends Equatable {
  const BluetoothControlState();

  @override
  List<Object?> get props => [];
}

class BluetoothControlStartState extends BluetoothControlState {}

class BluetoothControlInitializingState extends BluetoothControlState {}

class BluetoothControlDeviceNotSupportedState extends BluetoothControlState {}

class BluetoothControlOffState extends BluetoothControlState {}

class BluetoothControlTurnItOnState extends BluetoothControlState {}

class BluetoothControlNoConnectionState extends BluetoothControlState {}

class BluetoothControlConnectionState extends BluetoothControlState {}
