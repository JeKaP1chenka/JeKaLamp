import 'package:flutter/material.dart';
import 'package:jeka_lamp_app/app_theme.dart';
import 'package:jeka_lamp_app/core/bluetooth/bluetooth_connect.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jeka_lamp_app/locator_service.dart' as di;
import 'package:jeka_lamp_app/presentation/pages/effect/effect_cubit.dart';
import 'package:jeka_lamp_app/presentation/pages/effect/effect_state.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:jeka_lamp_app/presentation/pages/network/network_cubit.dart';
import 'package:jeka_lamp_app/presentation/pages/network/network_state.dart';
import 'package:wheel_slider/wheel_slider.dart';

class NetworkPage extends StatefulWidget {
  const NetworkPage({super.key});

  @override
  State<StatefulWidget> createState() => _NetworkState();
}

class _NetworkState extends State<NetworkPage> {
  final cubit = di.s1<NetworkCubit>();
  late NetworkState _state;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NetworkCubit, NetworkState>(
      builder: (context, state) {
        _state = state;
        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              wifiInputs(),
              SizedBox(height: 20),
              connectionLamp(),
            ],
          ),
        );
      },
    );
  }

  wifiInputs() {
    return Column(
      children: [
        SizedBox(height: 10),
        TextField(
          controller: cubit.wifiNameController,
          decoration: InputDecoration(
            labelText: 'WiFi Name',
            border: OutlineInputBorder(),
          ),
          onSubmitted: cubit.updateWifiName,
        ),
        SizedBox(height: 10),
        TextField(
          controller: cubit.wifiPasswordController,
          decoration: InputDecoration(
            labelText: 'WiFi Password',
            border: OutlineInputBorder(),
          ),
          onSubmitted: cubit.updateWifiPassword,
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              style: AppTheme.buttonStyle,
              onPressed: () {
                cubit.wifiNameController.text = "JeKa";
                cubit.wifiPasswordController.text = "12345678";
              },
              child: Text('t1'),
            ),
            ElevatedButton(
              style: AppTheme.buttonStyle,
              onPressed: () {
                cubit.wifiNameController.text = "ELTX-2.4GHz_WiFi_E028";
                cubit.wifiPasswordController.text = "GP2F062530";
              },
              child: Text('t2'),
            ),
            ElevatedButton(
              style: AppTheme.buttonStyle,
              onPressed: () {
                cubit.wifiNameController.text = "SAD8 K2";
                cubit.wifiPasswordController.text = "green1158490";
              },
              child: Text('t3'),
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("WiFi state: " + _state.wiFiStateString),
            ElevatedButton(
              style: AppTheme.buttonStyle.copyWith(
                fixedSize: WidgetStateProperty.all<Size>(Size(81, 40)),
              ),
              onPressed: _state.wiFiConnecting
                  ? null
                  : () {
                      cubit.sendData();
                    },
              child: _state.wiFiConnecting
                  ? SizedBox(
                      height: 25,
                      width: 25,
                      child: CircularProgressIndicator(),
                    )
                  : Text('Send'),
            )
          ],
        ),
        // Align(
        //   alignment: Alignment.centerRight, // Размещение справа
        //   child: ElevatedButton(
        //     style: AppTheme.buttonStyle,
        //     onPressed: () {
        //       cubit.sendData();
        //     },
        //     child: Text('Send'),
        //   ),
        // ),
      ],
    );
  }

  connectionLamp() {
    return Column(
      children: [
        TextField(
          controller: cubit.connectionLampController,
          decoration: InputDecoration(
            labelText: 'Connection Lamp',
            border: OutlineInputBorder(),
          ),
          onSubmitted: cubit.updateConnectionLamp,
        ),
        SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight, // Размещение справа
          child: ElevatedButton(
            style: AppTheme.buttonStyle,
            onPressed: () {
              cubit.sendData();
            },
            child: Text('Send'),
          ),
        ),
      ],
    );
  }
}
