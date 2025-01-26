import 'package:equatable/equatable.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

abstract class BluetoothConnectState extends Equatable {
  const BluetoothConnectState();

  @override
  List<Object?> get props => [];
}

class BCOffState extends BluetoothConnectState {
  @override
  List<Object?> get props => [];
}

class BCConnectedState extends BluetoothConnectState {
  // final BluetoothDevice device;

  // const BCConnectedState(this.device);

  @override
  List<Object?> get props => [];
  // List<Object?> get props => [device];
}
