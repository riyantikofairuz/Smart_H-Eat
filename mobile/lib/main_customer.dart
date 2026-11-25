import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'customer/providers/cart_provider.dart';
import 'customer/screens/screensaver_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const CustomerApp());
}

class CustomerApp extends StatefulWidget {
  const CustomerApp({super.key});

  @override
  State<CustomerApp> createState() => _CustomerAppState();
}

class _CustomerAppState extends State<CustomerApp> {
  late final CartNotifier _cartNotifier;

  @override
  void initState() {
    super.initState();
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
        title: 'Smart H-EAT',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const ScreensaverScreen(),
      ),
    );
  }
}
