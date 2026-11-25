import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'main_customer.dart';
import 'main_operator.dart';
import 'operator/constants/app_colors.dart';
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
  runApp(const SmartHeatModeSelectorApp());
}

enum _AppLaunchMode { selector, customer, operator }

class SmartHeatModeSelectorApp extends StatefulWidget {
  const SmartHeatModeSelectorApp({super.key});

  @override
  State<SmartHeatModeSelectorApp> createState() =>
      _SmartHeatModeSelectorAppState();
}

class _SmartHeatModeSelectorAppState extends State<SmartHeatModeSelectorApp> {
  _AppLaunchMode _mode = _AppLaunchMode.selector;

  @override
  Widget build(BuildContext context) {
    switch (_mode) {
      case _AppLaunchMode.customer:
        return const CustomerApp();
      case _AppLaunchMode.operator:
        return const OperatorApp();
      case _AppLaunchMode.selector:
        return MaterialApp(
          title: 'Smart H-EAT',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: AppColors.darkbackground,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              primary: AppColors.primary,
            ),
          ),
          home: Scaffold(
            body: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Image.asset(
                          'assets/images/smart_heat_logo.png',
                          height: 72,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.local_fire_department_rounded,
                            size: 64,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'SMART H-EAT',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const SizedBox(height: 28),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() => _mode = _AppLaunchMode.customer);
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          label: const Text(
                            'Mode Customer (Kiosk)',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() => _mode = _AppLaunchMode.operator);
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          label: const Text(
                            'Mode Operator',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
    }
  }
}
