import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zedbeemodbus/fields/colors.dart';
import 'package:zedbeemodbus/fields/theme.dart';
import 'package:zedbeemodbus/services_class/provider_services.dart';
import 'package:provider/provider.dart';
import 'package:zedbeemodbus/view_Pages/splash_screen.dart';

final ThemeNotifier themeNotifier = ThemeNotifier(); //instance for theme..

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // For Landscape mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProviderServices()),
        // ChangeNotifierProvider(
        //   create: (_) => ProviderServicesClass(),
        // ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentTheme, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          themeMode: currentTheme,
          theme: ThemeData.light().copyWith(
            appBarTheme: AppBarTheme(
              backgroundColor: AppColors.darkblue,
              iconTheme: IconThemeData(color: Colors.white),
            ),
          ),
          darkTheme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: Colors.grey[900],
            appBarTheme: AppBarTheme(color: Colors.grey[900]),
            iconTheme: IconThemeData(color: Colors.white),
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}
