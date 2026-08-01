import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'controllers/sensor_controller.dart';
import 'controllers/connection_controller.dart';
import 'views/dashboard_view.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  final sensorController = SensorController();
  final connectionController = ConnectionController(sensorController);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => sensorController),
        ChangeNotifierProvider(create: (_) => connectionController),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      title: 'Home Station',
      home: DashboardView(),
    );
  }
}