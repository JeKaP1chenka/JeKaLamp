// todo: перенести и декомпозировать в чистую архитектуру
// пока что пусть будет так как логика здесь простая и пока что засорятся не будет

import 'dart:async';
import 'dart:ffi';

import 'package:jeka_lamp_app/core/bluetooth/bluetooth_connect.dart';
import 'package:jeka_lamp_app/core/bluetooth/bluetooth_helper.dart';
import 'package:jeka_lamp_app/presentation/home_screen/home_screen_cubit.dart';
import 'package:jeka_lamp_app/presentation/home_screen/home_screen_state.dart';
import 'package:jeka_lamp_app/presentation/pages/effect/effect_cubit.dart';
import 'package:jeka_lamp_app/locator_service.dart' as di;
import 'package:jeka_lamp_app/presentation/pages/effect/effect_state.dart';

class SendData {
  Timer? _timer;
  final EffectCubit _effectCubit;
  late EffectState _lastSendEffectState;
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
    required BluetoothManager bluetoothManager,
  })  : _effectCubit = effectCubit,
        _bluetoothManager = bluetoothManager {
    _lastSendEffectState = _effectCubit.state;
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
    _sendDataEffectScreen();
  }

  void _sendDataEffectScreen() {
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
            effectStateTemp.microphone,
          ],
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
}
