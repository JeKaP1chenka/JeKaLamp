import 'package:flutter/material.dart';
import 'package:jeka_lamp_app/app_theme.dart';
import 'package:jeka_lamp_app/core/bluetooth/bluetooth_connect.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jeka_lamp_app/locator_service.dart' as di;
import 'package:jeka_lamp_app/presentation/pages/effect/effect_cubit.dart';
import 'package:jeka_lamp_app/presentation/pages/effect/effect_state.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class EffectPage extends StatefulWidget {
  const EffectPage({super.key});

  @override
  State<StatefulWidget> createState() => _EffectPageState();
}

class _EffectPageState extends State<EffectPage> {
  final cubit = di.s1<EffectCubit>();
  late EffectState _state;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EffectCubit, EffectState>(
      builder: (context, state) {
        _state = state;
        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [dropdownEffectType()],
              ),
              SizedBox(
                height: 8,
              ),
              sliders(),
            ],
          ),
        );
      },
    );
  }

  sliders() {
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: const <int, TableColumnWidth>{
        0: IntrinsicColumnWidth(),
        1: FlexColumnWidth(),
      },
      children: [
        TableRow(
          children: [
            Text("Brightness", style: AppTheme.sliderTextStyle),
            sliderBrightness(),
          ],
        ),
        TableRow(
          children: [
            Text("Speed", style: AppTheme.sliderTextStyle),
            sliderSpeed(),
          ],
        ),
        TableRow(
          children: [
            Text("Parameter", style: AppTheme.sliderTextStyle),
            sliderParameter(),
          ],
        ),
      ],
    );
  }

  Widget dropdownEffectType() {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<LightingEffect>(
        isExpanded: true,
        items: LightingEffect.values.map<DropdownMenuItem<LightingEffect>>(
          (e) {
            return DropdownMenuItem<LightingEffect>(
              value: e,
              child: Text(
                e.label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            );
          },
        ).toList(),
        value: LightingEffect.values
            .where(
              (element) => element.effectCode == _state.effectType,
            )
            .firstOrNull,
        onChanged: (value) {
          cubit.updateEffectTypeDropdown(value);
        },
        buttonStyleData: ButtonStyleData(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            border: Border.all(
              color: const Color.fromARGB(255, 48, 48, 48),
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16),
          height: 40,
          width: 140,
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            color: const Color.fromARGB(255, 48, 48, 48),
          ),
          scrollbarTheme: ScrollbarThemeData(
            radius: const Radius.circular(40),
            thickness: WidgetStateProperty.all(6),
            thumbVisibility: WidgetStateProperty.all(true),
          ),
        ),
        menuItemStyleData: const MenuItemStyleData(
          height: 40,
        ),
      ),
    );
  }

  Widget sliderBrightness() {
    return Slider(
      max: 255,
      min: 0,
      value: _state.brightness,
      label: _state.brightness.round().toString(),
      divisions: 255,
      onChanged: (value) => cubit.updateBrightnessSlider(value),
    );
  }

  Widget sliderSpeed() {
    return Slider(
      max: 255,
      min: 0,
      value: _state.speed,
      label: _state.speed.round().toString(),
      divisions: 255,
      onChanged: (value) => cubit.updateSpeedSlider(value),
    );
  }

  Widget sliderParameter() {
    return Slider(
      max: 255,
      min: 0,
      value: _state.parameter,
      label: _state.parameter.round().toString(),
      divisions: 255,
      onChanged: (value) => cubit.updateParameterSlider(value),
    );
  }
}
