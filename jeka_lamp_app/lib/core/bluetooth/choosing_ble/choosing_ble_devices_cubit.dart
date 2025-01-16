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
  final StreamController<List<ScanResult>> _scanResultsController =
      StreamController<List<ScanResult>>.broadcast();
  Stream<List<ScanResult>> get scanResultsStream =>
      _scanResultsController.stream;
  BluetoothDevice? device;

  ChoosingBleDevicesCubit() : super(ChoosingBleDevicesState());

  Future<void> scan() async {
    _scanResultsController.add([]);

    emit(CBDLoading());

    _scanResultsListener = FlutterBluePlus.onScanResults.listen(
      (results) {
        _scanResultsController.add(results);
        if (device != null &&
            results
                .where(
                  (element) =>
                      element.device.advName == device!.advName &&
                      element.device.remoteId.str == device!.remoteId.str,
                )
                .isEmpty) {
          device = null;
          emit(CBDLoaded());
        }
      },
      onDone: () {},
      onError: (e) => print(e),
    );

    await startScan();
  }

  Future<void> startScan() async {
    await FlutterBluePlus.startScan(
      withKeywords: [""],
      continuousUpdates: true,
      removeIfGone: Duration(seconds: 1),
    );
  }

  void selectDevice(BluetoothDevice d) {
    device = d;
    emit(CBDSelected());
  }

  Future<void> closeDialogWithDevice(BuildContext context) async {
    Navigator.pop(context, device);
  }

  Future<void> closeDialog(BuildContext context) async {
    Navigator.pop(context, null);
  }

  Future<void> stop() async {
    await FlutterBluePlus.stopScan();
    _scanResultsController.close();
  }
}
