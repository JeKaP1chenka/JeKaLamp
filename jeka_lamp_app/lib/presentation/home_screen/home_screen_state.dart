import 'package:equatable/equatable.dart';
import 'package:jeka_lamp_app/core/utils/bottom_navigation_element.dart';

class HomeScreenState extends Equatable {
  final bool autoSendData;
  final bool uiBloc;
  final bool isOn;


  const HomeScreenState({
    required this.autoSendData,
    required this.uiBloc,
    required this.isOn,
  });

  HomeScreenState copyWith({
    bool? autoSendData,
    bool? uiBloc,
    bool? isOn,
  }) {
    return HomeScreenState(
      autoSendData: autoSendData ?? this.autoSendData,
      uiBloc: uiBloc ?? this.uiBloc,
      isOn: isOn ?? this.isOn,
    );
  }

  @override
  List<Object> get props => [autoSendData, uiBloc, isOn];
}
