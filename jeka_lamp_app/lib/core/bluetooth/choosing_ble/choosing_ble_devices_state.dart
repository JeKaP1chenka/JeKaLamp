import 'package:equatable/equatable.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ChoosingBleDevicesState extends Equatable {
  const ChoosingBleDevicesState();

  @override
  List<Object?> get props => [];
}

class CBDLoading extends ChoosingBleDevicesState {
  // List<ScanResult> devices;

  // CBDLoading({required this.devices});
}

class CBDLoaded extends ChoosingBleDevicesState {
  // List<ScanResult> devices;

  // CBDLoaded({required this.devices});
}

class CBDSelected extends ChoosingBleDevicesState {}

class CBDError extends ChoosingBleDevicesState {}
