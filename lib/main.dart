import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'controllers/sensor_controller.dart';
import 'controllers/mqtt_controller.dart';
import 'views/view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'ttn.env');

  final sensorController = SensorController();
  final mqttController = MqttController(sensorController);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => sensorController),
        ChangeNotifierProvider(create: (_) => mqttController),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Home Station',
      home: DashboardView(),
    );
  }
}