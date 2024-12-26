import 'package:equatable/equatable.dart';

class BluetoothControlState extends Equatable {
  const BluetoothControlState();

  @override
  List<Object?> get props => [];
}

class BluetoothControlStartState extends BluetoothControlState {}

class BluetoothControlInitState extends BluetoothControlState {}

class BluetoothControlOffState extends BluetoothControlState {}

class BluetoothControlNoConnectionState extends BluetoothControlState {}

class BluetoothControlConnectionState extends BluetoothControlState {}

class BluetoothControlDisconnectionState extends BluetoothControlState {}
