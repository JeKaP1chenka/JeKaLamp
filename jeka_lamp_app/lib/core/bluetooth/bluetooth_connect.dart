import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:jeka_lamp_app/core/bluetooth/bluetooth_button.dart';
import 'package:jeka_lamp_app/core/bluetooth/bluetooth_connect_state.dart';
import 'package:jeka_lamp_app/core/bluetooth/bluetooth_control_cubit.dart';

class BluetoothConnect {
  BluetoothControlCubit? bluetoothControlCubit;
  BluetoothDevice? device;
  List<BluetoothService>? services;

  BluetoothControlCubit init() {
    bluetoothControlCubit ??= BluetoothControlCubit(this);
    bluetoothControlCubit!.initEvent();
    return bluetoothControlCubit!;
  }

  Widget bluetoothButton() {
    if (bluetoothControlCubit == null) {
      throw Exception(
          "BluetoothControlCubit не инициализирован. Вызовите init() перед использованием bluetoothButton().");
    }

    return BlocProvider<BluetoothControlCubit>(
      create: (context) => bluetoothControlCubit!,
      child: BluetoothButton(),
    );
  }

  Stream<BluetoothConnectState> get connectionStateStream {
    if (bluetoothControlCubit == null) {
      throw Exception(
          "BluetoothControlCubit не инициализирован. Вызовите init() перед использованием connectionStateStream.");
    }
    return bluetoothControlCubit!.connectionStateStream;
  }

  Future<void> writeData(
    List<int> data, {
    required String serviceUuidStr,
    required String characteristicUuidStr,
  }) async {
    if (device == null) {
      throw Exception("Устройство не подключено");
    }
    if (services == null) {
      throw Exception("Устройство не имеет сервисов");
    }

    try {
      BluetoothCharacteristic? writeCharacteristic =
          getCharacteristic(serviceUuidStr, characteristicUuidStr);

      if (writeCharacteristic != null) {
        await writeCharacteristic.write(data);
        print("Данные отправлены: $data");
      } else {
        throw Exception("Не удалось найти характеристику для записи");
      }
    } catch (e) {
      print("Ошибка при отправке данных: $e");
    }
  }

  Future<List<int>> readData({
    required String serviceUuidStr,
    required String characteristicUuidStr,
  }) async {
    if (device == null) {
      throw Exception("Устройство не подключено");
    }
    if (services == null) {
      throw Exception("Устройство не имеет сервисов");
    }

    try {
      BluetoothCharacteristic? characteristic =
          getCharacteristic(serviceUuidStr, characteristicUuidStr);

      if (characteristic != null) {
        var data = await characteristic.read();
        return data;
      } else {
        throw Exception("Не удалось найти характеристику для записи");
      }
    } catch (e) {
      print("Ошибка при получении данных: $e");
    }
    return [];
  }

  Future<void> receiveData(
    void Function(List<int> value)? onData, {
    required String serviceUuidStr,
    required String characteristicUuidStr,
  }) async {
    if (device == null) {
      throw Exception("Устройство не подключено");
    }
    if (services == null) {
      throw Exception("Устройство не имеет сервисов");
    }

    try {
      BluetoothCharacteristic? characteristic =
          getCharacteristic(serviceUuidStr, characteristicUuidStr);

      if (characteristic != null) {
        characteristic.setNotifyValue(true);
        var temp = characteristic.onValueReceived.listen(onData);
        device!.cancelWhenDisconnected(temp);
        characteristic.read();
      } else {
        throw Exception("Не удалось найти характеристику для записи");
      }
    } catch (e) {
      print("Ошибка при получении данных: $e");
    }
  }

  BluetoothCharacteristic? getCharacteristic(
    String serviceUuidStr,
    String characteristicUuidStr,
  ) {
    if (device == null) {
      throw Exception("Устройство не подключено");
    }
    if (services == null) {
      throw Exception("Устройство не имеет сервисов");
    }
    try {
      Guid serviceUuid = Guid(serviceUuidStr);
      Guid characteristicUuid = Guid(characteristicUuidStr);
      BluetoothCharacteristic? res = services!
          .where((service) => service.serviceUuid == serviceUuid)
          .expand((service) => service.characteristics)
          .where((characteristics) =>
              characteristics.characteristicUuid == characteristicUuid)
          .firstOrNull;

      return res;
    } catch (e) {
      print("Ошибка при получении данных: $e");
    }
    return null;
  }
}
