import 'package:equatable/equatable.dart';

class NetworkState extends Equatable {
  final String wifiName;
  final String wifiPassword;
  final String connectionLamp;
  final String wiFiStateString;
  final bool wiFiConnecting;

  const NetworkState({
    required this.wifiName,
    required this.wifiPassword,
    required this.connectionLamp,
    required this.wiFiStateString,
    required this.wiFiConnecting,
  });

  NetworkState copyWith({
    String? wifiName,
    String? wifiPassword,
    String? connectionLamp,
    String? wiFiStateString,
    bool? wiFiConnecting,
  }) {
    return NetworkState(
      wifiName: wifiName ?? this.wifiName,
      wifiPassword: wifiPassword ?? this.wifiPassword,
      connectionLamp: connectionLamp ?? this.connectionLamp,
      wiFiStateString: wiFiStateString ?? this.wiFiStateString,
      wiFiConnecting: wiFiConnecting ?? this.wiFiConnecting,
    );
  }

  @override
  List<Object?> get props => [
        wifiName,
        wifiPassword,
        connectionLamp,
        wiFiStateString,
        wiFiConnecting,
      ];
}
