import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jeka_lamp_app/core/bluetooth/bluetooth_connect.dart';
import 'package:jeka_lamp_app/presentation/pages/effect/effect_state.dart';
import 'package:jeka_lamp_app/locator_service.dart' as di;

enum LightingEffect {
  staticColor('Static Color', 1),
  dynamicColor("Dynamic Color", 2),
  fire('Fire', 3),
  pulse('Pulse', 4),
  
  wave('Wave', 5),
  rainbow('Rainbow', 6),
  strobe('Strobe', 7),
  s7('Static Color', 8),
  s8('Static Color', 9),
  s9('Static Color', 10),
  s10('Static Color', 11);

  const LightingEffect(this.label, this.effectCode);
  final String label;
  final int effectCode;
}

class EffectCubit extends Cubit<EffectState> {
  EffectCubit()
      : super(const EffectState(
          effectType: 0,
          brightness: 0.0,
          speed: 0.0,
          parameter: 0.0,
          microphone: false,
        ));

  void onValueReceived(List<int> values) {
    emit(state.copyWith(
      effectType: values[0],
      brightness: values[1].toDouble(),
      speed: values[2].toDouble(),
      parameter: values[3].toDouble(),
      microphone: values[4] == 0 ? true : false,
    ));
  }

  Future<void> updateEffectTypeDropdown(LightingEffect? value) async {
    emit(state.copyWith(effectType: value?.effectCode));
  }

  Future<void> updateBrightnessSlider(double value) async {
    emit(state.copyWith(brightness: value));
  }

  Future<void> updateSpeedSlider(double value) async {
    emit(state.copyWith(speed: value));
  }

  Future<void> updateParameterSlider(double value) async {
    emit(state.copyWith(parameter: value));
  }

  Future<void> updateMicrophoneSwitch(bool value) async {
    emit(state.copyWith(microphone: value));
  }

  @override
  Future<void> close() async {
    return super.close();
  }
}
