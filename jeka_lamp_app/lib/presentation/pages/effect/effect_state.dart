import 'package:equatable/equatable.dart';



class EffectState extends Equatable {

  final int effectType;
  final double brightness;
  final double speed;
  final double parameter;
  final bool microphone;

  const EffectState({
    required this.effectType,
    required this.brightness,
    required this.speed,
    required this.parameter,
    required this.microphone,
  });

  EffectState copyWith({
    int? effectType,
    double? brightness,
    double? speed,
    double? parameter,
    bool? microphone,
  }) {
    return EffectState(
      effectType: effectType ?? this.effectType,
      brightness: brightness ?? this.brightness,
      speed: speed ?? this.speed,
      parameter: parameter ?? this.parameter,
      microphone: microphone ?? this.microphone,
    );
  }

  @override
  List<Object> get props => [
        effectType,
        brightness,
        speed,
        parameter,
        microphone,
      ];
}
