
import 'package:flutter/material.dart';

class BottomNavigationElement {
  final Widget widget;
  final Icon icon;
  final String label;

  late NavigationDestination item;

  BottomNavigationElement({
    required this.widget,
    required this.icon,
    required this.label,
  }) {
    item = NavigationDestination(
      icon: icon,
      label: label,
    );
  }
}