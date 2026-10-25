import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/constants/menu_image_helper.dart';
import 'core/theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MenuImageHelper.init();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const SmartHeatApp());
}

class SmartHeatApp extends StatelessWidget {
  final AuthService? authService;

  const SmartHeatApp({
    super.key,
    this.authService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart H-EAT Operator',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: LoginScreen(authService: authService),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const MainNavigationScreen(),
      },
    );
  }
}
