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

  late var cubit = context.read<ChoosingBleDevicesCubit>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChoosingBleDevicesCubit, ChoosingBleDevicesState>(
      builder: (context, state) {
        print(
            "-----------------------ChoosingBleDevicesCubit ${state.toString()}");
        return Dialog(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 400,
              minHeight: 200,
              maxWidth: 400,
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
          padding: const EdgeInsets.all(8),
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
    return Expanded(
      flex: 1,
      child: StreamBuilder(
        stream: cubit.scanResultsStream,
        builder: (context, snapshot) {
          final results = snapshot.data ?? [];

          return ListView.builder(
            shrinkWrap: true, // Ограничиваем высоту списка
            itemCount: results.length,
            itemBuilder: (context, index) {
              final device = results[index].device;
              final isSelected = state is CBDSelected && device == cubit.device;
              return ListTile(
                title: Text(device.advName != ""
                    ? device.advName
                    : device.remoteId.str),
                leading: isSelected
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.circle_outlined),
                onTap: () {
                  cubit.selectDevice(device);
                  // setState(() {
                  //   _selectedDevice = device;
                  // });
                },
              );
            },
          );
        },
      ),
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
              cubit.closeDialog(context);
            },
            child: Text("отмена"),
          ),
          TextButton(
            onPressed: state is CBDSelected
                ? () {
                    cubit.closeDialogWithDevice(context);
                  }
                : null,
            child: Text("выбрать"),
          ),
        ],
      ),
    );
  }

  @override
  void deactivate() {
    // cubit.stop();
    super.deactivate();
  }
}