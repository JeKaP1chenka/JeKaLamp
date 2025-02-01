import 'package:flutter/material.dart';
import 'package:jeka_lamp_app/app_theme.dart';
import 'package:jeka_lamp_app/core/bluetooth/bluetooth_connect.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jeka_lamp_app/locator_service.dart' as di;
import 'package:jeka_lamp_app/presentation/pages/effect/effect_cubit.dart';
import 'package:jeka_lamp_app/presentation/pages/effect/effect_state.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:wheel_slider/wheel_slider.dart';

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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  dropdownEffectType(),
                  // SizedBox(width: 60),
                  switchMicrophone(),
                ],
              ),
              SizedBox(height: 8),
              sliders(),
            ],
          ),
        );
      },
    );
  }

  switchMicrophone() {
    return Row(
      children: [
        Icon(_state.microphone ? Icons.mic : Icons.mic_none),
        Switch(
          value: _state.microphone,
          onChanged: cubit.updateMicrophoneSwitch,
        )
      ],
    );
  }

  sliders() {
    const listTileContentPadding = EdgeInsets.all(0);
    const leadingWidth = 75.0;
    const textStyle = AppTheme.elementTextStyle;
    //вместо Column можно использовать ListView с установленным shrinkWrap:true
    //разница в том, что ListView имеет встроенную прокрутку элементов внутри контейнера
    return Column(
      spacing: 8,
      children: [
        ListTile(
          contentPadding: listTileContentPadding,
          //если хотим ровно - задаем ширину первой колонки.
          //нужна pixel perfect адаптивность? надо тогда учитывать размер текста и иконки
          //через коэффициент, зависимый от количества точек и их плотности
          leading: Container(
            width: leadingWidth,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Icon(Icons.wb_sunny_outlined),
                Text("Brightness", style: textStyle),
              ],
            ),
          ),
          title: sliderBrightness(),
        ),
        ListTile(
          contentPadding: listTileContentPadding,
          leading: Container(
            width: leadingWidth,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Icon(Icons.speed),
                Text("Speed", style: textStyle),
              ],
            ),
          ),
          title: sliderSpeed(),
        ),
        ListTile(
          contentPadding: listTileContentPadding,
          leading: Container(
            width: leadingWidth,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Icon(Icons.aspect_ratio),
                Text("Parameter", style: textStyle),
              ],
            ),
          ),
          title: sliderParameter(),
        ),
      ],
    );
  }

  // sliders() {
  //   return Table(
  //     defaultVerticalAlignment: TableCellVerticalAlignment.middle,
  //     columnWidths: const <int, TableColumnWidth>{
  //       0: IntrinsicColumnWidth(),
  //       1: FixedColumnWidth(10),
  //       2: FlexColumnWidth(),
  //     },
  //     children: [
  //       TableRow(
  //         children: [
  //           Column(
  //             children: [
  //               Icon(Icons.wb_sunny_outlined),
  //               SizedBox(height: 5),
  //               Text("Brightness", style: AppTheme.sliderTextStyle),
  //             ],
  //           ),
  //           SizedBox(width: 10),
  //           sliderBrightness(),
  //         ],
  //       ),
  //       TableRow(
  //         children: [
  //           Column(
  //             children: [
  //               Icon(Icons.speed),
  //               SizedBox(height: 5),
  //               Text("Speed", style: AppTheme.sliderTextStyle),
  //             ],
  //           ),
  //           SizedBox(width: 10),
  //           sliderSpeed(),
  //         ],
  //       ),
  //       TableRow(
  //         children: [
  //           Column(
  //             children: [
  //               Icon(Icons.aspect_ratio),
  //               SizedBox(height: 5),
  //               Text("Parameter", style: AppTheme.sliderTextStyle),
  //             ],
  //           ),
  //           SizedBox(width: 10),
  //           sliderParameter(),
  //         ],
  //       ),
  //     ],
  //   );
  // }

  Widget dropdownEffectType() {
    return SizedBox(
      width: 200,
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField2<LightingEffect>(
          barrierDismissible: true,
          isExpanded: true,
          items: LightingEffect.values.map<DropdownMenuItem<LightingEffect>>(
            (e) {
              return DropdownMenuItem<LightingEffect>(
                value: e,
                child: Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    e.label,
                    style: AppTheme.elementTextStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
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
          // buttonStyleData: AppTheme.elementButtonStyleData,
          dropdownStyleData: AppTheme.elementDropdownStyleData,
          menuItemStyleData: const MenuItemStyleData(
            padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
            height: 40,
          ),
          decoration: AppTheme.dropdownMenuInputDecoration(text: "Effect"),
        ),
      ),
    );
  }

  // Widget sliderBrightness() {
  //   return
  //     Container(
  //       // width: 100,
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(7),
  //         color: const Color.fromARGB(255, 117, 117, 117),
  //       ),
  //       child:
  //       // Row(
  //         // mainAxisSize: MainAxisSize.min,
  //         // children: [
  //           WheelSlider(
  //             lineColor: Colors.white,
  //             pointerColor: Colors.redAccent,
  //             interval: 1.0,
  //             verticalListWidth: 100,
  //             totalCount: 255,
  //             isInfinite: false,
  //             initValue: 0,
  //             isVibrate: false,
  //             onValueChanged: (val) {
  //               cubit.updateBrightnessSlider(val);
  //               // setState(() {
  //               //   _currentValue = val;
  //               // });
  //             },
  //           ),
  //           // SizedBox(width: 3),
  //           // Expanded(child: Text("${_state.brightness}")),
  //         // ],
  //       // ),
  //     );
  //   // return Slider(
  //   //   max: 255,
  //   //   min: 0,
  //   //   value: _state.brightness,
  //   //   label: _state.brightness.round().toString(),
  //   //   divisions: 255,
  //   //   onChanged: (value) => cubit.updateBrightnessSlider(value),
  //   // );
  // }

  Widget abstractSlider({
    required dynamic Function(dynamic) onValueChanged,
    required double number,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        color: const Color.fromARGB(255, 117, 117, 117),
      ),
      child: Row(
        children: [
          // SizedBox(width: 16),
          //Слайдер ставим на всю ширину, так как он здесь главный
          Expanded(
            child: Slider(
              max: 255,
              min: 0,
              divisions: 255,
              value: number,
              onChanged: onValueChanged,
            ),
            // child: WheelSlider.number(
            //   perspective: 0.005,
            //   // lineColor: Colors.white,
            //   // pointerColor: Colors.redAccent,
            //   // pointerHeight: 35,
            //   interval: 1.0,
            //   verticalListWidth: 100,
            //   totalCount: 255,
            //   isInfinite: false,
            //   // initValue: number,
            //   isVibrate: false,
            //   // squeeze: 2,
            //   onValueChanged: onValueChanged,
            //   currentIndex: number,
            //   initValue: 0,
            // ),
          ),
          // а текст - сколько останется. Если будешь сам дописывать 0 к однозначным
          //значениям, то будет ровно и красиво
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: SizedBox(
              width: 30,
              child: Text(
                style: AppTheme.elementTextStyle,
                "${number.round()}",
                textAlign: TextAlign.center,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget sliderBrightness() {
    return abstractSlider(
      onValueChanged: (value) => cubit.updateBrightnessSlider(value as double),
      number: _state.brightness,
    );
    // return Container(
    //   decoration: BoxDecoration(
    //     borderRadius: BorderRadius.circular(7),
    //     color: const Color.fromARGB(255, 117, 117, 117),
    //   ),
    //   child: Row(
    //     children: [
    //       SizedBox(width: 16),
    //       //Слайдер ставим на всю ширину, так как он здесь главный
    //       Expanded(
    //         child: WheelSlider(
    //           lineColor: Colors.white,
    //           pointerColor: Colors.redAccent,
    //           interval: 1.0,
    //           verticalListWidth: 100,
    //           totalCount: 255,
    //           isInfinite: false,
    //           initValue: 0,
    //           isVibrate: false,
    //           onValueChanged: (val) {
    //             cubit.updateBrightnessSlider(val);
    //           },
    //         ),
    //       ),
    //       // а текст - сколько останется. Если будешь сам дописывать 0 к однозначным
    //       //значениям, то будет ровно и красиво
    //       Padding(
    //         padding: const EdgeInsets.symmetric(horizontal: 16.0),
    //         child: SizedBox(
    //           width: 30,
    //           child: Text(
    //             "${_state.brightness.round()}",
    //             textAlign: TextAlign.center,
    //           ),
    //         ),
    //       )
    //     ],
    //   ),
    // );
  }

  Widget sliderSpeed() {
    return abstractSlider(
      onValueChanged: (value) => cubit.updateSpeedSlider(value as double),
      number: _state.speed,
    );
    // return Slider(
    //   max: 255,
    //   min: 0,
    //   value: _state.speed,
    //   label: _state.speed.round().toString(),
    //   divisions: 255,
    //   onChanged: (value) => cubit.updateSpeedSlider(value),
    // );
  }

  Widget sliderParameter() {
    return abstractSlider(
      onValueChanged: (value) => cubit.updateParameterSlider(value as double),
      number: _state.parameter,
    );
    // return Slider(
    //   max: 255,
    //   min: 0,
    //   value: _state.parameter,
    //   label: _state.parameter.round().toString(),
    //   divisions: 255,
    //   onChanged: (value) => cubit.updateParameterSlider(value),
    // );
  }
}
