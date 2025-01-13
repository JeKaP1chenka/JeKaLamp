import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:jeka_lamp_app/core/bluetooth/choosing_ble/choosing_ble_devices_state.dart';

class ChoosingBleDevicesCubit extends Cubit<ChoosingBleDevicesState> {
  late StreamSubscription<List<ScanResult>> _scanResultsListener;
  late List<ScanResult> devices = [];
  final StreamController<List<ScanResult>> _scanResultsController =
      StreamController<List<ScanResult>>.broadcast();
  Stream<List<ScanResult>> get scanResultsStream =>
      _scanResultsController.stream;
  BluetoothDevice? device;

  ChoosingBleDevicesCubit() : super(ChoosingBleDevicesState());

  Future<void> scan() async {
    _scanResultsController.add([]);
    // emit(BluetoothControlConnectDeviceState([]));

    emit(CBDLoading());

    _scanResultsListener = FlutterBluePlus.onScanResults.listen(
      (results) {
        devices = results;
        _scanResultsController.add(results);
      },
      onDone: () {
        emit(CBDLoaded());
      },
      onError: (e) => print(e),
    );

    await startScan();
  }

  Future<void> startScan() async {
    devices.clear();
    await FlutterBluePlus.startScan(
      continuousUpdates: true,
      removeIfGone: Duration(seconds: 1),
      // timeout: Duration(seconds: 1),
    );
  }

  void selectDevice(BluetoothDevice d) {
    device = d;
    emit(CBDSelected());
  }

  Future<void> closeDialog(BuildContext context) async {
    await FlutterBluePlus.stopScan();
    _scanResultsController.close();
    Navigator.pop(context, device);
  }

}
