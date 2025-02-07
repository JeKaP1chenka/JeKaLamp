import 'package:get_it/get_it.dart';
import 'package:jeka_lamp_app/core/bluetooth/bluetooth_connect.dart';
import 'package:jeka_lamp_app/core/bluetooth/bluetooth_helper.dart';
import 'package:jeka_lamp_app/presentation/home_screen/home_screen_cubit.dart';
import 'package:jeka_lamp_app/presentation/pages/alarm/alarm_cubit.dart';
import 'package:jeka_lamp_app/presentation/pages/effect/effect_cubit.dart';
import 'package:jeka_lamp_app/presentation/pages/network/network_cubit.dart';
import 'package:jeka_lamp_app/presentation/send_data.dart';

final s1 = GetIt.instance;

Future<void> init() async {
  s1.registerLazySingleton(
    () {
      final bluetoothConnect = BluetoothConnect();
      bluetoothConnect.init();
      return bluetoothConnect;
    },
  );

  s1.registerLazySingleton(
    () => BluetoothManager(),
  );

  s1.registerLazySingleton(() => EffectCubit());
  s1.registerLazySingleton(() => AlarmCubit());
  s1.registerLazySingleton(() => NetworkCubit());

  s1.registerLazySingleton(
    () => SendData(
      effectCubit: s1(),
      alarmCubit: s1(),
      networkCubit: s1(),
      bluetoothManager: s1(),
    ),
  );
  
  s1<NetworkCubit>().setSendData(s1<SendData>());

  s1.registerLazySingleton(() => HomeScreenCubit(sendData: s1()));
}
