import 'package:flutter/material.dart';
import 'package:jeka_lamp_app/app_theme.dart';
import 'package:jeka_lamp_app/core/bluetooth/bluetooth_connect.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jeka_lamp_app/locator_service.dart' as di;
import 'package:jeka_lamp_app/presentation/pages/alarm/alarm_cubit.dart';
import 'package:jeka_lamp_app/presentation/pages/alarm/alarm_state.dart';
import 'package:jeka_lamp_app/presentation/pages/effect/effect_cubit.dart';
import 'package:jeka_lamp_app/presentation/pages/effect/effect_state.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:wheel_slider/wheel_slider.dart';

class AlarmPage extends StatefulWidget {
  const AlarmPage({super.key});

  @override
  State<StatefulWidget> createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  final cubit = di.s1<AlarmCubit>();
  late AlarmState _state;

  var days = {
    "Monday": 0,
    "Tuesday": 1,
    "Wednesday": 2,
    "Thursday": 3,
    "Friday": 4,
    "Saturday": 5,
    "Sunday": 6,
  };
  var duration = [for (int i = 0; i <= 60; i += 5) i];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlarmCubit, AlarmState>(
      builder: (context, state) {
        _state = state;
        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              alarmControl(),
              SizedBox(height: 10),
              alarmDaysControl(),
            ],
          ),
        );
      },
    );
  }

  alarmControl() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          spacing: 6,
          children: [
            Text(
              "Duration",
              style: AppTheme.elementTextStyle,
            ),
            buttonChoiceDuration(
              text: "Before",
              value: cubit.getTimeBeforeAlarm(),
              onChanged: (value) {
                if (value != null) {
                  cubit.updateTimeBeforeAlarm(value);
                }
              },
            ),
            buttonChoiceDuration(
              text: "After",
              value: cubit.getTimeAfterAlarm(),
              onChanged: (value) {
                if (value != null) {
                  cubit.updateTimeAfterAlarm(value);
                }
              },
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.alarm),
            Switch(
              value: cubit.getOnOffAlarm(),
              onChanged: cubit.updateOnOffAlarm,
            ),
          ],
        ),
      ],
    );
  }

  buttonChoiceDuration(
      {required String text, required int? value, required void Function(int?)? onChanged}) {
    return SizedBox(
      width: 80,
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField2(
          isExpanded: true,
          items: duration.map(
            (e) {
              return DropdownMenuItem(
                value: e,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                  child: Text(
                    "$e",
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            },
          ).toList(),
          value: value,
          onChanged: onChanged,
          // value: duration.indexOf(element),
          dropdownStyleData: AppTheme.elementDropdownStyleData,
          buttonStyleData: ButtonStyleData(
            width: 100,
          ),
          menuItemStyleData: const MenuItemStyleData(
            padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
            height: 40,
          ),
          decoration: AppTheme.dropdownMenuInputDecoration(text: text),
        ),
      ),
    );
  }

  alarmDaysControl() {
    return Column(
      children: [
        for (var element in days.keys)
          dayElement(element: element, index: days[element])
      ],
    );
  }

  dayElement({required String element, int? index}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            element,
            style: AppTheme.elementTextStyle,
          ),
        ),
        Switch(
          value: cubit.getOnOffDay(index!),
          onChanged: (value) => cubit.updateOnOffDay(
            index: index,
            value: value,
          ),
        ),
        SizedBox(width: 7),
        TextButton(
          style: AppTheme.buttonStyle,
          onPressed: () async {
            TimeOfDay? pickedTime = await showTimePicker(
                context: context, initialTime: cubit.getTimeDay(index));
            if (pickedTime != null) {
              cubit.updateTimeDay(index: index, value: pickedTime);
            }
          },
          child: Text(
            cubit.getTimeDayString(index),
            style: AppTheme.elementTextStyle,
          ),
        ),
      ],
    );
  }
}
