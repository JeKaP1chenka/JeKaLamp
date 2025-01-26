import 'package:flutter/material.dart';
import 'package:jeka_lamp_app/core/bluetooth/bluetooth_connect.dart';
import 'package:jeka_lamp_app/core/utils/bottom_navigation_element.dart';
import 'package:jeka_lamp_app/presentation/home_screen/home_screen_cubit.dart';
import 'package:jeka_lamp_app/presentation/home_screen/home_screen_state.dart';
import 'package:jeka_lamp_app/presentation/pages/effect/effect_page.dart';
import 'package:jeka_lamp_app/locator_service.dart' as di;
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool autoSendData = false;
  final WidgetStateProperty<Icon> thumbIcon = WidgetStateProperty<Icon>.fromMap(
    <WidgetStatesConstraint, Icon>{
      WidgetState.selected: Icon(Icons.check),
      WidgetState.any: Icon(Icons.close),
    },
  );

  final List<BottomNavigationElement> _navigationElements = [
    BottomNavigationElement(
      widget: EffectPage(),
      icon: Icon(Icons.home_outlined),
      label: "Effect",
    ),
    BottomNavigationElement(
      widget: Center(child: Text("alarm")),
      icon: Icon(Icons.alarm),
      label: "Alarm",
    ),
    BottomNavigationElement(
      widget: Center(child: Text("network")),
      icon: Icon(Icons.network_wifi),
      label: "Network",
    ),
  ];

  var _selectedIndex = 0;

  void _onNavigationItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final cubit = di.s1<HomeScreenCubit>();
  late HomeScreenState _state;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeScreenCubit, HomeScreenState>(
      builder: (context, state) {
        // final cubit = context.read<HomeScreenCubit>();
        _state = state;
        return Scaffold(
          appBar: buildAppBar(),
          body: _blocked(
            blocked: state.uiBloc,
            child: _navigationElements.elementAt(_selectedIndex).widget,
          ),
          bottomNavigationBar: NavigationBar(
            onDestinationSelected: _onNavigationItemTapped,
            selectedIndex: _selectedIndex,
            destinations: <NavigationDestination>[
              for (var i in _navigationElements) i.item
            ],
          ),
          floatingActionButton: state.uiBloc || state.autoSendData
              ? null
              : FloatingActionButton(
                  onPressed: () {
                    cubit.uploadData();
                  },
                  child: Icon(Icons.upload),
                ),
        );
      },
    );
  }

  Widget _blocked({required bool blocked, required Widget child}) {
    return Stack(
      children: [
        AbsorbPointer(
          absorbing: blocked,
          child: child,
        ),
        if (blocked)
          Container(
            color: Colors.black.withValues(alpha: 0.7),
          ),
      ],
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      title: Text("JeKaLampApp"),
      actions: [
        Row(
          children: [
            Text("Auto\nMode", maxLines: 2),
            SizedBox(width: 2),
            IgnorePointer(
              ignoring: _state.uiBloc,
              child: Row(
                children: [
                  Switch(
                    thumbIcon: thumbIcon,
                    value: _state.autoSendData,
                    onChanged: _state.uiBloc
                        ? null
                        : (value) {
                            cubit.autoSendDataChange(value);
                          },
                  ),
                  SizedBox(width: 2),
                  IconButton(
                    onPressed: _state.uiBloc
                        ? null
                        : () {
                            cubit.onOff();
                          },
                    icon: Icon(
                      _state.isOn ? Icons.lightbulb : Icons.lightbulb_outline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        // SizedBox(width: 4),
        di.s1<BluetoothConnect>().bluetoothButton(),
        SizedBox(width: 4),
      ],
    );
  }
}
