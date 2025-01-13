import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:jeka_lamp_app/core/bluetooth/bluetooth_control_cubit.dart';
import 'package:jeka_lamp_app/core/bluetooth/bluetooth_control_state.dart';
import 'package:jeka_lamp_app/core/bluetooth/choosing_ble/choosing_ble_devices_cubit.dart';
import 'package:jeka_lamp_app/core/bluetooth/choosing_ble/choosing_ble_devices_state.dart';
import 'package:jeka_lamp_app/locator_service.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ChoosingBleDevicesWidget extends StatefulWidget {
  const ChoosingBleDevicesWidget({Key? key}) : super(key: key);

  @override
  State<ChoosingBleDevicesWidget> createState() =>
      _ChoosingBleDevicesWidgetState();
}

class _ChoosingBleDevicesWidgetState extends State<ChoosingBleDevicesWidget> {
  // BluetoothDevice? _selectedDevice;
  // bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChoosingBleDevicesCubit, ChoosingBleDevicesState>(
      builder: (context, state) {
        print(
            "-----------------------ChoosingBleDevicesCubit ${state.toString()}");
        if (state is CBDLoaded) {
        } else if (state is CBDLoading) {
        } else if (state is CBDSelected) {}
        return Dialog(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 400, // Максимальная высота для диалога
              minHeight: 200, // Минимальная высота для диалога
              maxWidth: 400, // Максимальная ширина
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _dialogTitle(context, state),
                  _devicesList(context, state),
                  _dialogBottom(context, state),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _dialogTitle(BuildContext context, ChoosingBleDevicesState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // SizedBox(height: 1,),
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Text(
            "Выбор устройства",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        // state is CBDLoading
        //     ? CircularProgressIndicator()
        //     : IconButton(
        //         onPressed: () {},
        //         icon: Icon(Icons.replay),
        //       ),
      ],
    );
  }

  _devicesList(BuildContext context, ChoosingBleDevicesState state) {
    // var s = state as CBDLoaded;
    return StreamBuilder(
      stream: context.read<ChoosingBleDevicesCubit>().scanResultsStream,
      builder: (context, snapshot) {
        final results = snapshot.data ?? [];

        return ListView.builder(
          shrinkWrap: true, // Ограничиваем высоту списка
          itemCount: results.length,
          itemBuilder: (context, index) {
            final device = results[index].device;
            final isSelected = state is CBDSelected &&
                device == context.read<ChoosingBleDevicesCubit>().device;
            return ListTile(
              title: Text(
                  device.advName != "" ? device.advName : device.remoteId.str),
              leading: isSelected
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : const Icon(Icons.circle_outlined),
              onTap: () {
                context.read<ChoosingBleDevicesCubit>().selectDevice(device);
                // setState(() {
                //   _selectedDevice = device;
                // });
              },
            );
          },
        );
      },
    );
  }

  _dialogBottom(BuildContext context, ChoosingBleDevicesState state) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () {
              closeDialog(context);
            },
            child: Text("отмена"),
          ),
          TextButton(
            onPressed: state is CBDSelected
                ? () {
                    closeDialog(context);
                    
                  }
                : null,
            child: Text("выбрать"),
          ),
        ],
      ),
    );
  }

  closeDialog(BuildContext context) {
    context.read<ChoosingBleDevicesCubit>().closeDialog(context);
  }

  // Future.microtask(
  //   () => showDialog<void>(
  //     context: context,
  //     builder: (context) {
  //       return StreamBuilder<List<ScanResult>>(
  //         stream: context.read<BluetoothControlCubit>().scanResultsStream,
  //         builder: (context, snapshot) {
  //           final results = snapshot.data ?? [];

  //           return AlertDialog(
  //             title: Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceAround,
  //               children: [
  //                 Text("Выбор устройства"),
  //                 context.read<BluetoothControlCubit>().isScanDevice
  //                     ? CircularProgressIndicator()
  //                     : IconButton(
  //                         onPressed: () {
  //                           context
  //                               .read<BluetoothControlCubit>()
  //                               .startScanDevice();
  //                         },
  //                         icon: Icon(Icons.replay),
  //                       ),
  //               ],
  //             ),
  //             content: SizedBox(
  //               height: double.maxFinite, // Ограничиваем высоту списка
  //               width: double.maxFinite,
  //               child: ListView.builder(
  //                 itemCount: results.length,
  //                 itemBuilder: (context, index) {
  //                   final device = results[index].device;
  //                   return ListTile(
  //                     title: Text(device.advName.isNotEmpty
  //                         ? device.advName
  //                         : "Безымянное устройство"),
  //                     subtitle: Text(device.remoteId.toString()),
  //                     onTap: () {
  //                       print("Выбрано устройство: ${device.remoteId}");
  //                       Navigator.of(context).pop(); // Закрыть диалог
  //                     },
  //                   );
  //                 },
  //               ),
  //             ),
  //             actions: [
  //               TextButton(
  //                 onPressed: () {
  //                   Navigator.of(context).pop(); // Закрыть диалог
  //                   context
  //                       .read<BluetoothControlCubit>()
  //                       .connectDeviceCancel();
  //                 },
  //                 child: Text("Отмена"),
  //               ),
  //               // Row(
  //               //   mainAxisSize: MainAxisSize.max,
  //               //   // crossAxisAlignment: CrossAxisAlignment.stretch,
  //               //   children: [
  //               //     TextButton(
  //               //       onPressed: () {},
  //               //       child: Text("Обновить"),
  //               //     ),

  //               //   ],
  //               // )
  //             ],
  //           );
  //         },
  //       );
  //     },
  //   ),
  // );
  // }
}




/**
 *   @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Заголовок с кнопкой/индикатором
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Выбор устройства',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                _isLoading
                    ? const CircularProgressIndicator() // Индикация загрузки
                    : IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                          });
                          context
                              .read<ChoosingBleDevicesCubit>()
                              .reloadDevices();
                        },
                      ),
              ],
            ),
            const SizedBox(height: 10),

            // Список устройств
            BlocBuilder<ChoosingBleDevicesCubit, ChoosingBleDevicesState>(
              builder: (context, state) {
                if (state is ChoosingBleDevicesLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ChoosingBleDevicesLoaded) {
                  if (state.devices.isEmpty) {
                    return const Center(
                      child: Text('Устройства не найдены.'),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true, // Ограничиваем высоту списка
                    itemCount: state.devices.length,
                    itemBuilder: (context, index) {
                      final device = state.devices[index];
                      final isSelected = device == _selectedDevice;

                      return ListTile(
                        title: Text(device),
                        leading: isSelected
                            ? const Icon(Icons.check_circle,
                                color: Colors.green)
                            : const Icon(Icons.circle_outlined),
                        onTap: () {
                          setState(() {
                            _selectedDevice = device;
                          });
                        },
                      );
                    },
                  );
                } else {
                  return const Center(
                    child: Text('Произошла ошибка при загрузке устройств.'),
                  );
                }
              },
            ),
            const SizedBox(height: 10),

            // Кнопки внизу
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Кнопка "Отмена"
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, null); // Возвращаем null
                  },
                  child: const Text('Отмена'),
                ),

                // Кнопка "Выбрать"
                ElevatedButton(
                  onPressed: _selectedDevice != null
                      ? () {
                          Navigator.pop(context, _selectedDevice);
                        }
                      : null, // Кнопка активна только если выбрано устройство
                  child: const Text('Выбрать'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

 */