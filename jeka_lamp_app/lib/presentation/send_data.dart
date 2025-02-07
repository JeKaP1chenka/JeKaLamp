// todo: перенести и декомпозировать в чистую архитектуру
// пока что пусть будет так как логика здесь простая и пока что засорятся не будет

import 'dart:async';
import 'dart:ffi';

import 'package:jeka_lamp_app/core/bluetooth/bluetooth_connect.dart';
import 'package:jeka_lamp_app/core/bluetooth/bluetooth_helper.dart';
import 'package:jeka_lamp_app/presentation/home_screen/home_screen_cubit.dart';
import 'package:jeka_lamp_app/presentation/home_screen/home_screen_state.dart';
import 'package:jeka_lamp_app/presentation/pages/alarm/alarm_cubit.dart';
import 'package:jeka_lamp_app/presentation/pages/alarm/alarm_state.dart';
import 'package:jeka_lamp_app/presentation/pages/effect/effect_cubit.dart';
import 'package:jeka_lamp_app/locator_service.dart' as di;
import 'package:jeka_lamp_app/presentation/pages/effect/effect_state.dart';
import 'package:jeka_lamp_app/presentation/pages/network/network_cubit.dart';

class SendData {
  Timer? _timer;
  final EffectCubit _effectCubit;
  late EffectState _lastSendEffectState;
  final AlarmCubit _alarmCubit;
  final NetworkCubit _networkCubit;
  late AlarmState _lastSendAlarmState;

  // final HomeScreenCubit _homeScreenCubit;
  // late HomeScreenState _homeScreenState;
  final BluetoothConnect _bluetoothConnect = di.s1<BluetoothConnect>();
  late bool autoSendData = false;
  final BluetoothManager _bluetoothManager;

  set autoMode(bool a) {
    autoSendData = a;
  }

  SendData({
    required EffectCubit effectCubit,
    required AlarmCubit alarmCubit,
    required NetworkCubit networkCubit,
    required BluetoothManager bluetoothManager,
  })  : _effectCubit = effectCubit,
        _alarmCubit = alarmCubit,
        _networkCubit = networkCubit,
        _bluetoothManager = bluetoothManager {
    _lastSendEffectState = _effectCubit.state;
    _lastSendAlarmState = _alarmCubit.state;
    _timer = Timer.periodic(
      const Duration(milliseconds: 400),
      (timer) {
        if (autoSendData) {
          _sendData();
        }
      },
    );
  }

  void call() {
    if (!autoSendData) {
      _sendData();
    }
  }

  void _sendData() {
    _sendDataEffectPage();
    _sendDataAlarmPage();
  }

  void _sendDataEffectPage() {
    var effectStateTemp = _effectCubit.state;
    if (_lastSendEffectState != effectStateTemp) {
      _lastSendEffectState = effectStateTemp;
      var s = _bluetoothManager.getService("LampState");
      var ch = s?.getCharacteristic("parameters");
      if (s != null && ch != null) {
        _bluetoothConnect.writeData(
          [
            effectStateTemp.effectType,
            effectStateTemp.brightness.round(),
            effectStateTemp.speed.round(),
            effectStateTemp.parameter.round(),
            effectStateTemp.microphone ? 1 : 0,
          ],
          serviceUuidStr: s.uuid,
          characteristicUuidStr: ch.uuid,
        );
      }
    }
  }

  void _sendDataAlarmPage() {
    var alarmStateTemp = _alarmCubit.state;
    if (_lastSendAlarmState != alarmStateTemp) {
      _lastSendAlarmState = alarmStateTemp;
      var s = _bluetoothManager.getService("LampState");
      var ch = s?.getCharacteristic("alarm");
      // List<int> temp = List.filled(14, 0);
      // for (var i = 0; i < alarmStateTemp.timeOfDays.length; i++) {
      //   temp[i * 2] = alarmStateTemp.timeOfDays[i] >> 8;
      //   temp[i * 2 + 1] = alarmStateTemp.timeOfDays[i] & ~(~0 << 8);
      // }
      List<int> temp2 = [
        alarmStateTemp.alarmState,
        alarmStateTemp.timeBeforeAlarm,
        alarmStateTemp.timeAfterAlarm,
        ...alarmStateTemp.timeOfDays,
      ];
      for (var element in temp2) {
        print(element.toRadixString(16));
      }
      // print(temp2.map(
      //   (e) {
      //     e.toRadixString(16);
      //   },
      // ).toString());
      if (s != null && ch != null) {
        _bluetoothConnect.writeData(
          temp2,
          serviceUuidStr: s.uuid,
          characteristicUuidStr: ch.uuid,
        );
      }
    }
  }

  void sendLampState(bool value) {
    var s = _bluetoothManager.getService("LampState");
    var ch = s?.getCharacteristic("on/off");
    if (s != null && ch != null) {
      _bluetoothConnect.writeData(
        [value ? 1 : 0],
        serviceUuidStr: s.uuid,
        characteristicUuidStr: ch.uuid,
      );
    }
  }

  void sendNetworkSettings() {
    var s = _bluetoothManager.getService("LampState");
    var ch = s?.getCharacteristic("network");
    if (s != null && ch != null) {
      _bluetoothConnect.writeData(
        // ("${_networkCubit.state.wifiName}|${_networkCubit.state.wifiPassword}|${_networkCubit.state.connectionLamp}")
        "${_networkCubit.state.wifiName}|${_networkCubit.state.wifiPassword}"
            .codeUnits,
        serviceUuidStr: s.uuid,
        characteristicUuidStr: ch.uuid,
      );
    }
  }

  void sendConnectionLamp() {
    var s = _bluetoothManager.getService("LampState");
    var ch = s?.getCharacteristic("connectionLamp");
    if (s != null && ch != null) {
      _bluetoothConnect.writeData(
        // ("${_networkCubit.state.wifiName}|${_networkCubit.state.wifiPassword}|${_networkCubit.state.connectionLamp}")
        _networkCubit.state.connectionLamp.codeUnits,
        serviceUuidStr: s.uuid,
        characteristicUuidStr: ch.uuid,
      );
    }
  }

  void sendTime() {}
}
