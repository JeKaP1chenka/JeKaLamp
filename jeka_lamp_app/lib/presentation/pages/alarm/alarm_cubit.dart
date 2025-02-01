import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jeka_lamp_app/core/bluetooth/bluetooth_connect.dart';
import 'package:jeka_lamp_app/presentation/pages/alarm/alarm_state.dart';
import 'package:jeka_lamp_app/presentation/pages/effect/effect_state.dart';
import 'package:jeka_lamp_app/locator_service.dart' as di;

enum LightingEffect {
  rainbow('Rainbow', 1),
  pulse('Pulse', 2),
  strobe('Strobe', 3),
  wave('Wave', 4),
  fire('Fire', 5),
  staticColor('Static Color', 6),
  s7('Static Color', 7),
  s8('Static Color', 8),
  s9('Static Color', 9),
  s10('Static Color', 10);

  const LightingEffect(this.label, this.effectCode);
  final String label;
  final int effectCode;
}

class AlarmCubit extends Cubit<AlarmState> {
  AlarmCubit()
      : super(AlarmState(
          alarmState: 0,
          timeBeforeAlarm: 5,
          timeAfterAlarm: 5,
          timeOfDays: List.filled(14, 0).build(),
        ));

  void onValueReceived(List<int> values) {
    emit(state.copyWith(
      alarmState: values[0],
      timeBeforeAlarm: values[1],
      timeAfterAlarm: values[2],
      timeOfDays: values.getRange(3, 17).toBuiltList(),
    ));
  }

  Future<void> updateOnOffAlarm(bool value) async {
    int temp = (1 << 7);
    var newAlarmState =
        value ? state.alarmState | temp : state.alarmState & ~temp;
    emit(state.copyWith(alarmState: newAlarmState));
  }

  Future<void> updateTimeBeforeAlarm(int value) async {
    emit(state.copyWith(timeBeforeAlarm: value));
  }

  Future<void> updateTimeAfterAlarm(int value) async {
    emit(state.copyWith(timeAfterAlarm: value));
  }

  Future<void> updateTimeDay(
      {required int index, required TimeOfDay value}) async {
    var temp = state.timeOfDays.toList();
    temp[index * 2] = value.hour;
    temp[index * 2 + 1] = value.minute;
    emit(state.copyWith(timeOfDays: temp.build()));
  }

  Future<void> updateOnOffDay({required int index, required bool value}) async {
    int temp = (1 << index);
    var newAlarmState =
        value ? state.alarmState | temp : state.alarmState & ~temp;
    emit(state.copyWith(alarmState: newAlarmState));
  }

  Map<String, int> _getTimeDay(int index) {
    int hour = state.timeOfDays[index * 2];
    int minute = state.timeOfDays[index * 2 + 1];

    return {"hour": hour, "minute": minute};
  }

  String getTimeDayString(int index) {
    var time = _getTimeDay(index);
    return "${time["hour"].toString().padLeft(2, '0')}"
        ":"
        "${time["minute"].toString().padLeft(2, '0')}";
  }

  TimeOfDay getTimeDay(int index) {
    var time = _getTimeDay(index);
    return TimeOfDay(hour: time["hour"]!, minute: time["minute"]!);
  }

  bool getOnOffDay(int index) {
    return (state.alarmState >> index & 1) == 0 ? false : true;
  }

  bool getOnOffAlarm() {
    return state.alarmState >> 7 == 0 ? false : true;
  }

  int getTimeBeforeAlarm()  {
    return state.timeBeforeAlarm;
  }

  int getTimeAfterAlarm()  {
    return state.timeAfterAlarm;
  }

  @override
  Future<void> close() async {
    return super.close();
  }
}
