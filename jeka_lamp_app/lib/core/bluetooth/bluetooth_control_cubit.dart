import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'package:jeka_lamp_app/core/bluetooth/bluetooth_control_state.dart';
import 'package:jeka_lamp_app/core/bluetooth/choosing_ble/choosing_ble_devices_cubit.dart';
import 'package:jeka_lamp_app/core/bluetooth/choosing_ble/choosing_ble_devices_state.dart';
import 'package:jeka_lamp_app/core/bluetooth/choosing_ble/choosing_ble_devices_widget.dart';

// это блютуз(определение есть ли блютуз или нет, подключение и проверка статуса подключения), я сделал уже кнопку которая должна в зависимости от state менять и цвет и саму иконку,
// пример если блютуз не включен то иконка серая и специальная иконка, при нажатии будет вылетать уведомление включить блутуз,
// если блютуз включен то иконка белая и вторая иконка(нейтральная) которая покажет что можно выбрать устройство после выбора устройства надо сохранить его имя(адрес) в памяти чтоб при следующем открытии сразу пытаться подключится к последнему устройству
// если устройство подключено то кнопка имеет третью иконку и зеленый цвет (при этом состоянии она дает пользоваться остальными функциями на страницах) и раз в какое то время проверяет есть ли подключение,
// если подключение сорвалось то кнопка меняет иконку на четвертую и меняет цвет на красный, при нажатии(тут я не совсем продумал как лучше сделать но этот state лучше сделать может быть придумаю на него функционал)

class BluetoothControlCubit extends Cubit<BluetoothControlState> {
  BluetoothControlCubit() : super(BluetoothControlStartState());

  late StreamSubscription<BluetoothAdapterState> _bluetoothAdapterListener;
  // late StreamSubscription<List<ScanResult>> _scanResultsListener;
  // final StreamController<List<ScanResult>> _scanResultsController =
  // StreamController<List<ScanResult>>.broadcast();
  // Stream<List<ScanResult>> get scanResultsStream =>
  // _scanResultsController.stream;

  void _adapterListener(BluetoothAdapterState state) {
    print(state);
    if (state == BluetoothAdapterState.on) {
      //! вызвать метод который проверит было ли в прошлом подключение и если было то сразу подключит
      emit(BluetoothControlNoConnectionState());
    } else if (state == BluetoothAdapterState.off) {
      emit(BluetoothControlOffState());
    } else {
      // show an error to the user, etc
    }
  }

  Future<void> initEvent() async {
    emit(BluetoothControlInitializingState());
    if (await FlutterBluePlus.isSupported == false) {
      emit(BluetoothControlDeviceNotSupportedState());
      print("Bluetooth not supported by this device");
      return;
    }
    _bluetoothAdapterListener =
        FlutterBluePlus.adapterState.listen(_adapterListener);
    // _bluetoothAdapterListener.cancel();
    // checkingPreviousConnection();
  }

  Future<void> checkingPreviousConnection() async {
    // проверка было ли уже подключение
    // переход на NoConnection или Connection
  }

  // void cancel() {
  // }

  Future<void> turnOnEvent() async {
    if (Platform.isAndroid) {
      try {
        await FlutterBluePlus.turnOn(timeout: pow(2, 30) as int);
      } on FlutterBluePlusException {
        emit(BluetoothControlTurnItOnState());
      } catch (e) {
        print("Unknown exception: $e");
      }
    } else {
      emit(BluetoothControlTurnItOnState());
    }
  }

  // Future<void> connectDevice() async {
  //   _scanResultsListener = FlutterBluePlus.onScanResults.listen(
  //     scanResults,
  //     onError: (e) => print(e),
  //   );
  //   await FlutterBluePlus.startScan(
  //     // withServices: [Guid("180D")], // match any of the specified services
  //     // withNames: ["Bluno"], // *or* any of the specified names
  //     timeout: Duration(seconds: 15),
  //   );
  // }

  // late bool isScanDevice = false;
  Future<void> connectDevice(BuildContext context) async {
    _bluetoothAdapterListener.pause();
    final choosingBleDevicesCubit = ChoosingBleDevicesCubit()..scan();
    final result = await showDialog<BluetoothDevice?>(
      context: context,
      builder: (context) {
        return BlocProvider(
          create: (context) => choosingBleDevicesCubit,
          child: ChoosingBleDevicesWidget(),
        );
      },
    );

    _bluetoothAdapterListener.resume();

    if (result != null) {
      // Обработка выбранного устройства
      print("Выбрано устройство: ${result.advName}");
      // Сохраните устройство или выполните подключение
    } else {
      // Ничего не выбрано
      print("Устройство не выбрано.");
    }

    print("test alskdj;alskdj;alskjd;laksjd;laksjd");

    // _scanResultsController.add([]);
    // emit(BluetoothControlConnectDeviceState([]));

    // _scanResultsListener = FlutterBluePlus.onScanResults.listen(
    //   (results) {
    //     isScanDevice = true;
    //     _scanResultsController.add(results);
    //   },
    //   onDone: () {
    //     isScanDevice = false;
    //     _bluetoothAdapterListener.resume();
    //   },
    //   onError: (e) => print(e),
    // );

    // await startScanDevice();
  }

  // Future<void> startScanDevice() async {
  //   await FlutterBluePlus.startScan(
  //     continuousUpdates: true,
  //     removeIfGone: Duration(seconds: 1),
  //     timeout: Duration(seconds: 1),
  //   );
  // }

  // Future<void> connectDeviceCancel() async {
  //   _scanResultsListener.cancel();
  // }

  @override
  Future<void> close() {
    _bluetoothAdapterListener.cancel();
    // _scanResultsController.close(); // Закрываем поток при уничтожении Cubit
    return super.close();
  }
}
