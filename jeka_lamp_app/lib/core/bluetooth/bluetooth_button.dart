import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:jeka_lamp_app/core/bluetooth/bluetooth_control_cubit.dart';
import 'package:jeka_lamp_app/core/bluetooth/bluetooth_control_state.dart';
import 'package:jeka_lamp_app/locator_service.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothButton extends StatelessWidget {
  const BluetoothButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BluetoothControlCubit, BluetoothControlState>(
      builder: (context, state) {
        print("-----------------------BluetoothControlCubit ${state.toString()}");
        if (state is BluetoothControlStartState) {
          return Container();
        } else if (state is BluetoothControlInitializingState) {
          return CircularProgressIndicator();
        } else if (state is BluetoothControlDeviceNotSupportedState) {
          return bluetoothDeviceNotSupported(context);
        } else if (state is BluetoothControlOffState) {
          return bluetoothOff(context);
        } else if (state is BluetoothControlTurnItOnState) {
          return bluetoothTurnItOn(context);
        } else if (state is BluetoothControlNoConnectionState) {
          return bluetoothNoConnection(context);
        } else if (state is BluetoothControlConnectionState) {
          return bluetoothConnection(context);
        } else {
          // error
          return bluetoothError(context);
        }
      },
    );
  }

  Widget bluetoothOff(BuildContext context) {
    return IconButton(
      onPressed: () {
        context.read<BluetoothControlCubit>().turnOnEvent(context);
      },
      color: const Color.fromARGB(255, 255, 56, 56),
      icon: Icon(Icons.bluetooth_disabled),
    );
  }

  Widget bluetoothNoConnection(BuildContext context) {
    return IconButton(
      onPressed: () {
        context.read<BluetoothControlCubit>().chooseDevice(context);
      },
      // color: const Color.fromARGB(255, 240, 43, 43),
      icon: Icon(Icons.bluetooth),
    );
  }

  Widget bluetoothConnection(BuildContext context) {
    return IconButton(
      onPressed: () {
        context.read<BluetoothControlCubit>().disconnect(context);
      },
      color: const Color.fromARGB(255, 58, 245, 34),
      icon: Icon(Icons.bluetooth),
    );
  }

  Widget bluetoothError(BuildContext context) {
    return IconButton(
      onPressed: () {},
      icon: Icon(Icons.error_outline),
    );
  }

  Widget bluetoothTurnItOn(BuildContext context) {
    Future.microtask(
      () => showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Bluetooth выключен"),
            content: Text("Включите его самостоятельно"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Ок"),
              ),
            ],
          );
        },
      ),
    );
    return bluetoothOff(context);
  }

  Widget bluetoothDeviceNotSupported(BuildContext context) {
    Future.microtask(
      () => showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Bluetooth не поддерживается"),
            content: Text(
              "Ваше устройство не поддерживает bluetooth, приложение не может работать без него!",
              maxLines: 3,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Ок"),
              ),
            ],
          );
        },
      ),
    );
    return bluetoothError(context);
  }

  // Widget bluetoothConnectDevice(
  //     BuildContext context, BluetoothControlConnectDeviceState state) {
  //   Future.microtask(
  //     () => showDialog<void>(
  //       context: context,
  //       builder: (context) {
  //         return StreamBuilder<List<ScanResult>>(
  //           stream: context.read<BluetoothControlCubit>().scanResultsStream,
  //           builder: (context, snapshot) {
  //             final results = snapshot.data ?? [];

  //             return AlertDialog(
  //               title: Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceAround,
  //                 children: [
  //                   Text("Выбор устройства"),
  //                   context.read<BluetoothControlCubit>().isScanDevice
  //                       ? CircularProgressIndicator()
  //                       : IconButton(
  //                           onPressed: () {
  //                             context
  //                                 .read<BluetoothControlCubit>()
  //                                 .startScanDevice();
  //                           },
  //                           icon: Icon(Icons.replay),
  //                         ),
  //                 ],
  //               ),
  //               content: SizedBox(
  //                 height: double.maxFinite, // Ограничиваем высоту списка
  //                 width: double.maxFinite,
  //                 child: ListView.builder(
  //                   itemCount: results.length,
  //                   itemBuilder: (context, index) {
  //                     final device = results[index].device;
  //                     return ListTile(
  //                       title: Text(device.advName.isNotEmpty
  //                           ? device.advName
  //                           : "Безымянное устройство"),
  //                       subtitle: Text(device.remoteId.toString()),
  //                       onTap: () {
  //                         print("Выбрано устройство: ${device.remoteId}");
  //                         Navigator.of(context).pop(); // Закрыть диалог
  //                       },
  //                     );
  //                   },
  //                 ),
  //               ),
  //               actions: [
  //                 TextButton(
  //                   onPressed: () {
  //                     Navigator.of(context).pop(); // Закрыть диалог
  //                     context
  //                         .read<BluetoothControlCubit>()
  //                         .connectDeviceCancel();
  //                   },
  //                   child: Text("Отмена"),
  //                 ),
  //                 // Row(
  //                 //   mainAxisSize: MainAxisSize.max,
  //                 //   // crossAxisAlignment: CrossAxisAlignment.stretch,
  //                 //   children: [
  //                 //     TextButton(
  //                 //       onPressed: () {},
  //                 //       child: Text("Обновить"),
  //                 //     ),

  //                 //   ],
  //                 // )
  //               ],
  //             );
  //           },
  //         );
  //       },
  //     ),
  //   );

  //   return CircularProgressIndicator();
  // }
}
