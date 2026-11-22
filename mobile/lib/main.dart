import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'providers/cart_provider.dart';
import 'screens/screensaver_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final CartNotifier _cartNotifier;

  @override
  void initState() {
    super.initState();
    // Inisialisasi CartNotifier satu kali untuk seluruh sesi aplikasi
    _cartNotifier = CartNotifier();
  }

  @override
  void dispose() {
    _cartNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CartProvider(
      notifier: _cartNotifier,
      child: MaterialApp(
        title: 'Smart Heat',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const ScreensaverScreen(),
      ),
    );
  }
}
