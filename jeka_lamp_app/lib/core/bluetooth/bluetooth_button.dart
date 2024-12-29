
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:jeka_lamp_app/core/bluetooth/bluetooth_control_cubit.dart';
import 'package:jeka_lamp_app/core/bluetooth/bluetooth_control_state.dart';
import 'package:jeka_lamp_app/locator_service.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothButton extends StatelessWidget {
  BluetoothButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BluetoothControlCubit, BluetoothControlState>(
      builder: (context, state) {
        print("---------------------------- ${state.toString()}");
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
        } else if (state is BluetoothControlConnectDeviceState) {
          return bluetoothConnectDevice(context, state);
        } else if (state is BluetoothControlConnectionState) {
          return bluetoothConnection(context);
        } else if (state is BluetoothControlDisconnectionState) {
          return bluetoothDisconnection(context);
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
        context.read<BluetoothControlCubit>().turnOnEvent();
      },
      icon: Icon(Icons.bluetooth_disabled),
    );
  }

  Widget bluetoothTurnItOn(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              color: Colors.grey,
            ),
            padding: EdgeInsets.only(
              left: 12,
              right: 12,
              bottom: 8,
              top: 8,
            ),
            child: Text("turnItOn"),
          ),
        );
      },
    );
    return bluetoothOff(context);
  }

  Widget bluetoothNoConnection(BuildContext context) {
    return IconButton(
      onPressed: () {
        context.read<BluetoothControlCubit>().connectDevice();
      },
      icon: Icon(Icons.bluetooth),
    );
  }

  Widget bluetoothConnection(BuildContext context) {
    return IconButton(
      onPressed: () {},
      icon: Icon(Icons.bluetooth),
    );
  }

  Widget bluetoothDisconnection(BuildContext context) {
    return IconButton(
      onPressed: () {},
      icon: Icon(Icons.bluetooth),
    );
  }

  Widget bluetoothError(BuildContext context) {
    return IconButton(
      onPressed: () {},
      icon: Icon(Icons.error_outline),
    );
  }

  Widget bluetoothDeviceNotSupported(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              color: Colors.grey,
            ),
            padding: EdgeInsets.only(
              left: 12,
              right: 12,
              bottom: 8,
              top: 8,
            ),
            child: Text("deviceNotSupported"),
          ),
        );
      },
    );
    return bluetoothError(context);
  }

  Widget bluetoothConnectDevice(
      BuildContext context, BluetoothControlConnectDeviceState state) {
    Future.microtask(
      () => showDialog<void>(
        context: context,
        builder: (context) {
          return StreamBuilder<List<ScanResult>>(
            stream: context.read<BluetoothControlCubit>().scanResultsStream,
            builder: (context, snapshot) {
              final results = snapshot.data ?? [];

              return AlertDialog(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text("Выбор устройства"),
                    context.read<BluetoothControlCubit>().isScanDevice
                        ? CircularProgressIndicator()
                        : Icon(Icons.done),
                  ],
                ),
                content: SizedBox(
                  height: double.maxFinite, // Ограничиваем высоту списка
                  width: double.maxFinite,
                  child: ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final device = results[index].device;
                      return ListTile(
                        title: Text(device.advName.isNotEmpty
                            ? device.advName
                            : "Безымянное устройство"),
                        subtitle: Text(device.remoteId.toString()),
                        onTap: () {
                          print("Выбрано устройство: ${device.remoteId}");
                          Navigator.of(context).pop(); // Закрыть диалог
                        },
                      );
                    },
                  ),
                ),
                actions: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      TextButton(
                        onPressed: () {
                          context
                              .read<BluetoothControlCubit>()
                              .startScanDevice();
                        },
                        child: Text("обновить"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Закрыть диалог
                          context
                              .read<BluetoothControlCubit>()
                              .connectDeviceCancel();
                        },
                        child: Text("Отмена"),
                      ),
                    ],
                  )
                ],
              );
            },
          );
        },
      ),
    );

    return CircularProgressIndicator();
  }
}
