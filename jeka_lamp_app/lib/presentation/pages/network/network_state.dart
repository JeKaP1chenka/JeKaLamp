import 'package:equatable/equatable.dart';

class NetworkState extends Equatable {
  final String wifiName;
  final String wifiPassword;
  final String connectionLamp;

  const NetworkState({
    required this.wifiName,
    required this.wifiPassword,
    required this.connectionLamp,
  });

  NetworkState copyWith({
    String? wifiName,
    String? wifiPassword,
    String? connectionLamp,
  }) {
    return NetworkState(
      wifiName: wifiName ?? this.wifiName,
      wifiPassword: wifiPassword ?? this.wifiPassword,
      connectionLamp: connectionLamp ?? this.connectionLamp,
    );
  }

  @override
  List<Object?> get props => [
        wifiName,
        wifiPassword,
        connectionLamp,
      ];
}
