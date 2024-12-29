import 'package:get_it/get_it.dart';
import 'package:jeka_lamp_app/core/bluetooth/bluetooth_connect.dart';


final s1 = GetIt.instance;

Future<void> init() async {
  s1.registerLazySingleton(() {
    final bluetoothConnect = BluetoothConnect();
    bluetoothConnect.init(); 
    return bluetoothConnect;
  },);
}
