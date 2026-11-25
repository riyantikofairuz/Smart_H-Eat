import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'operator/constants/app_colors.dart';
import 'operator/screens/auth/login_screen.dart';
import 'operator/screens/main_navigation_screen.dart';
import 'operator/services/auth_service.dart';
import 'operator/theme/app_theme.dart';
import 'operator/views/operator_main_view.dart';
import 'shared/constants/menu_image_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await MenuImageHelper.init();
  } catch (_) {}

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const OperatorApp());
}

class OperatorApp extends StatelessWidget {
  const OperatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart H-EAT Operator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          surface: AppColors.surface,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.border,
          thickness: 1,
        ),
      ),
      home: const OperatorMainView(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const MainNavigationScreen(),
        '/operator_main': (context) => const OperatorMainView(),
      },
    );
  }
}

typedef MyApp = OperatorApp;

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
        '/operator_main': (context) => const OperatorMainView(),
      },
    );
  }
}
