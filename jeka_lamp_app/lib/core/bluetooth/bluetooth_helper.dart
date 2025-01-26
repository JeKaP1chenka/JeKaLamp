import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothCharacteristic {
  String uuid; // UUID характеристики

  BluetoothCharacteristic({required this.uuid});
}

class BluetoothService {
  String uuid; // UUID сервиса
  Map<String, BluetoothCharacteristic> characteristics; // Словарь характеристик по имени

  BluetoothService({required this.uuid, required this.characteristics});

  // Получение характеристики по имени
  BluetoothCharacteristic? getCharacteristic(String name) {
    return characteristics[name];
  }
}

class BluetoothManager {
  // Словарь сервисов по имени
  final Map<String, BluetoothService> services = {
    "LampState": BluetoothService(
      uuid: "1234",
      characteristics: {
        "on/off": BluetoothCharacteristic(uuid: "1234"),
        "parameters": BluetoothCharacteristic(uuid: "1235"),
      },
    ),
    // "EffectState": BluetoothService(
    //   uuid: "1235",
    //   characteristics: {
    //   },
    // ),
  };

  // Метод для получения сервиса по имени
  BluetoothService? getService(String serviceName) {
    return services[serviceName];
  }
}
