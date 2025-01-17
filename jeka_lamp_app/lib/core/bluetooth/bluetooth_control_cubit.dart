import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:jeka_lamp_app/core/bluetooth/bluetooth_connect.dart';

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
  BluetoothControlCubit(this._bluetoothConnect)
      : super(BluetoothControlStartState());
  final BluetoothConnect _bluetoothConnect;
  late StreamSubscription<BluetoothAdapterState> _bluetoothAdapterListener;
  Stream<BluetoothConnectionState>? _bluetoothConnectionStream;
  StreamSubscription<BluetoothConnectionState>? _bluetoothConnectionListener;
  BluetoothDevice? device;

  void _connectionListener(BluetoothConnectionState state) {
    debugPrint(state.toString());
    if (state == BluetoothConnectionState.connected) {
      emit(BluetoothControlConnectionState());
    } else if (state == BluetoothConnectionState.disconnected) {
      emit(BluetoothControlNoConnectionState());
    }
  }

  void _adapterListener(BluetoothAdapterState state) async {
    debugPrint(state.toString());
    if (state == BluetoothAdapterState.on) {
      //! вызвать метод который проверит было ли в прошлом подключение и если было то сразу подключит
      emit(BluetoothControlNoConnectionState());
    } else if (state == BluetoothAdapterState.off) {
      await _bluetoothConnectionListener?.cancel();
      _bluetoothConnectionListener = null;
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
  }

  Future<void> checkingPreviousConnection() async {
    // проверка было ли уже подключение
    // переход на NoConnection или Connection
  }

  void turnOnEvent(BuildContext context) async {
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
    chooseDevice(context);
  }

  Future<void> chooseDevice(BuildContext context) async {
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
      print("Выбрано устройство: ${result.advName}");
      // connectAndSendMessage(result);
      device = result;
      connectDevice();
    } else {
      print("Устройство не выбрано.");
    }
  }

  Future<void> connectDevice() async {
    try {
      if (device != null) {
        await device!.connect();
        _bluetoothConnectionStream = device!.connectionState;
        _bluetoothConnectionListener = _bluetoothConnectionStream!.listen(
          _connectionListener,
          onDone: () {},
          onError: (error) {},
        );
      }
    } catch (e) {
      print("Ошибка при подключении или отправке данных: $e");
    }
  }

  Future<void> disconnect(BuildContext context) async {
    try {
      if (device != null) {
        await device!.disconnect();
        _bluetoothConnectionStream = null;
        _bluetoothConnectionListener = null;
      }
    } catch (e) {
      print("Ошибка при подключении или отправке данных: $e");
    }
  }

  Future<void> connectAndSendMessage(BluetoothDevice device) async {
    try {
      // Подключаемся к устройству
      await device.connect();
      print("Подключено к устройству: ${device.advName}");

      // Получаем характеристики устройства
      List<BluetoothService> services = await device.discoverServices();
      // Ищем характеристику, в которую можно записать данные
      BluetoothCharacteristic? writeCharacteristic =
          services[2].characteristics[0];
      // for (BluetoothService service in services) {
      //   for (BluetoothCharacteristic characteristic
      //       in service.characteristics) {
      //     if (characteristic.properties.write) {
      //       writeCharacteristic = characteristic;
      //       break;
      //     }
      //   }
      //   if (writeCharacteristic != null) {
      //     break;
      //   }
      // }

      if (writeCharacteristic == null) {
        print("Не удалось найти подходящую характеристику для записи.");
        return;
      }

      // Отправляем тестовое сообщение
      List<int> message = [72, 101, 108, 108, 111]; // "Hello" в виде байтов
      await writeCharacteristic.write(message);
      print("Сообщение отправлено: Hello");

      // После отправки отключаемся от устройства
      await device.disconnect();
      print("Отключено от устройства: ${device.advName}");
    } catch (e) {
      print("Ошибка при подключении или отправке данных: $e");
    }
  }

  @override
  Future<void> close() async {
    await _bluetoothAdapterListener.cancel();
    await _bluetoothConnectionListener?.cancel();
    return super.close();
  }
}
