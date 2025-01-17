import 'package:flutter/material.dart';
import 'package:jeka_lamp_app/core/bluetooth/bluetooth_connect.dart';
import 'package:jeka_lamp_app/core/utils/bottom_navigation_element.dart';
import 'package:jeka_lamp_app/presentation/pages/effect_page.dart';
import 'package:jeka_lamp_app/locator_service.dart' as di;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool autoSwitch = false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: IgnorePointer(
        ignoring: false,
        child: _navigationElements.elementAt(_selectedIndex).widget,
      ),
      bottomNavigationBar: IgnorePointer(
        ignoring: false,
        child: NavigationBar(
          onDestinationSelected: _onNavigationItemTapped,
          selectedIndex: _selectedIndex,
          destinations: <NavigationDestination>[
            for (var i in _navigationElements) i.item
          ],
        ),
      ),
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
            Switch(
              thumbIcon: thumbIcon,
              value: autoSwitch,
              onChanged: (value) {
                setState(() {
                  autoSwitch = value;
                });
              },
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
