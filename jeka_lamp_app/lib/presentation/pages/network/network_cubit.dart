import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jeka_lamp_app/core/bluetooth/bluetooth_connect.dart';
import 'package:jeka_lamp_app/presentation/pages/effect/effect_state.dart';
import 'package:jeka_lamp_app/locator_service.dart' as di;
import 'package:jeka_lamp_app/presentation/pages/network/network_state.dart';
import 'package:jeka_lamp_app/presentation/send_data.dart';

class NetworkCubit extends Cubit<NetworkState> {
  TextEditingController wifiNameController = TextEditingController();
  TextEditingController wifiPasswordController = TextEditingController();
  TextEditingController connectionLampController = TextEditingController();

  SendData? _sendData;

  NetworkCubit()
      : super(const NetworkState(
          wifiName: "",
          wifiPassword: "",
          connectionLamp: "",
        ));
  void onValueReceived(List<int> values) {
    String result = String.fromCharCodes(values);

    List<String> parts = result.split('|');

    String wifiName = parts.isNotEmpty ? parts[0] : "";
    String wifiPassword = parts.length > 1 ? parts[1] : "";

    emit(state.copyWith(
      wifiName: wifiName,
      wifiPassword: wifiPassword,
    ));
    wifiNameController.text = wifiName;
    wifiPasswordController.text = wifiPassword;
  }

  void onValueReceivedConnectionLamp(List<int> values) {
    String result = String.fromCharCodes(values);

    emit(state.copyWith(connectionLamp: result));
    connectionLampController.text = result;
  }

  void updateWifiName(String value) {
    // emit(state.copyWith(wifiName: value));
    // wifiNameController.text = value;
  }

  void updateWifiPassword(String value) {
    // emit(state.copyWith(wifiPassword: value));
    // wifiPasswordController.text = value;
  }

  void updateConnectionLamp(String value) {
    // emit(state.copyWith(connectionLamp: value));
    // connectionLampController.text = value;
  }

  void sendData() {
    // wifiNameController.text = "Xiaomi";
    // wifiPasswordController.text = "300stas111";
    emit(state.copyWith(
      wifiName: wifiNameController.text,
      wifiPassword: wifiPasswordController.text,
    ));
    _sendData?.sendNetworkSettings();
  }

  void sendConnectionLamp() {
    emit(state.copyWith(
      connectionLamp: connectionLampController.text
    ));
    _sendData?.sendConnectionLamp();
  }

  void setSendData(SendData sendData) {
    _sendData = sendData;
  }
}
