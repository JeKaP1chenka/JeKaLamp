import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:built_collection/built_collection.dart';

class AlarmState extends Equatable {
  final int alarmState;
  final int timeBeforeAlarm;
  final int timeAfterAlarm;
  final BuiltList<int> timeOfDays;

  // final int mondayTime;
  // final int tuesdayTime;
  // final int wednesdayTime;
  // final int thursdayTime;
  // final int fridayTime;
  // final int saturdayTime;
  // final int sundayTime;


  const AlarmState({
    required this.alarmState,
    required this.timeBeforeAlarm,
    required this.timeAfterAlarm,
    required this.timeOfDays,
    // required this.mondayTime,
    // required this.tuesdayTime,
    // required this.wednesdayTime,
    // required this.thursdayTime,
    // required this.fridayTime,
    // required this.saturdayTime,
    // required this.sundayTime,
  });

  AlarmState copyWith({
    int? alarmState,
    int? timeBeforeAlarm,
    int? timeAfterAlarm,
    BuiltList<int>? timeOfDays,
    // int? mondayTime,
    // int? tuesdayTime,
    // int? wednesdayTime,
    // int? thursdayTime,
    // int? fridayTime,
    // int? saturdayTime,
    // int? sundayTime,
  }) {
    return AlarmState(
      alarmState: alarmState ?? this.alarmState,
      timeBeforeAlarm: timeBeforeAlarm ?? this.timeBeforeAlarm,
      timeAfterAlarm: timeAfterAlarm ?? this.timeAfterAlarm,
      timeOfDays: timeOfDays ?? this.timeOfDays,
      // mondayTime: mondayTime ?? this.mondayTime,
      // tuesdayTime: tuesdayTime ?? this.tuesdayTime,
      // wednesdayTime: wednesdayTime ?? this.wednesdayTime,
      // thursdayTime: thursdayTime ?? this.thursdayTime,
      // fridayTime: fridayTime ?? this.fridayTime,
      // saturdayTime: saturdayTime ?? this.saturdayTime,
      // sundayTime: sundayTime ?? this.sundayTime,
    );
  }



  @override
  List<Object> get props => [
        alarmState,
        timeBeforeAlarm,
        timeAfterAlarm,
        ...timeOfDays,
        // mondayTime,
        // tuesdayTime,
        // wednesdayTime,
        // thursdayTime,
        // fridayTime,
        // saturdayTime,
        // sundayTime,
      ];
}
