import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/operator_model.dart';
import '../../services/auth_service.dart';
import '../../services/dummy_data_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/operator_header.dart';
import '../../widgets/smart_heat_logo.dart';
import '../main_navigation_screen.dart';

class LoginScreen extends StatefulWidget {
  final AuthService? authService;
  final ValueChanged<OperatorModel>? onLoginSuccess;

  const LoginScreen({
    super.key,
    this.authService,
    this.onLoginSuccess,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _usernameError;
  String? _passwordError;
  String? _generalError;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Menentukan nama tampilan operator dari input username/email secara dinamis
  String _resolveOperatorName(String username) {
    final trimmed = username.trim();
    if (trimmed.isEmpty) {
      return DummyDataService().operatorGreeting;
    }

    // Jika username spesifik 'kemas' (demo default SKPPL), gunakan 'Pak Kemas'
    if (trimmed.toLowerCase() == 'kemas') {
      return 'Pak Kemas';
    }

    // Jika input berupa email (contoh: user@gmail.com), ekstrak bagian username di depan @
    String cleanName = trimmed;
    if (cleanName.contains('@')) {
      cleanName = cleanName.split('@').first;
    }

    // Ganti separator seperti dot, underscore, atau minus menjadi spasi
    cleanName = cleanName.replaceAll(RegExp(r'[._\-]'), ' ').trim();

    if (cleanName.isEmpty) {
      return DummyDataService().operatorGreeting;
    }

    // Format Title Case tiap kata (misal: "arda" -> "Arda", "budi santoso" -> "Budi Santoso")
    return cleanName
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) => word[0].toUpperCase() + (word.length > 1 ? word.substring(1) : ''))
        .join(' ');
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _usernameError = null;
      _passwordError = null;
      _generalError = null;
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    bool hasError = false;
    if (username.isEmpty) {
      _usernameError = 'Username / email wajib diisi';
      hasError = true;
    }

    if (password.isEmpty) {
      _passwordError = 'Password wajib diisi';
      hasError = true;
    }

    if (hasError) {
      setState(() {});
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // ========================================================================
      // SIMULASI LOGIN LOKAL (FRONTEND DEMO ONLY)
      // ========================================================================
      // PERHATIAN / DISCLAIMER:
      // Alur login di bawah ini HANYA SIMULASI LOKAL sementara untuk keperluan
      // demonstrasi alur antarmuka frontend Flutter Smart H-EAT Operator.
      // Kode ini BUKAN autentikasi sungguhan dan TIDAK memanggil API Laravel
      // atau database MySQL backend.
      //
      // CATATAN INTEGRASI:
      // Ketika backend Laravel dan database telah siap diintegrasikan oleh anggota
      // tim backend, blok simulasi lokal ini harus diganti dengan panggilan REST API
      // autentikasi produksi yang sesungguhnya (misalnya ApiAuthService / POST /api/operator/login).
      // ========================================================================

      OperatorModel? loggedInOperator;

      if (widget.authService != null) {
        final result = await widget.authService!.login(
          username: username,
          password: password,
        );

        if (!result.isSuccess) {
          if (mounted) {
            setState(() {
              _generalError = result.message ?? 'Username atau password salah.';
              _isLoading = false;
            });
          }
          return;
        }

        loggedInOperator = result.operator;
      }

      if (loggedInOperator == null) {
        final displayName = _resolveOperatorName(username);
        loggedInOperator = OperatorModel(
          id: 1,
          name: displayName,
          username: username,
          token: 'simulated_local_token_${DateTime.now().millisecondsSinceEpoch}',
        );
      }

      // Sinkronisasikan sapaan operator pada service dummy
      DummyDataService().updateOperatorGreeting(loggedInOperator.name);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selamat datang, ${loggedInOperator.name}!'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );

      if (widget.onLoginSuccess != null) {
        widget.onLoginSuccess!(loggedInOperator);
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (ctx) => MainNavigationScreen(
              operator: loggedInOperator,
              onLogout: () {
                Navigator.of(ctx).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => LoginScreen(authService: widget.authService),
                  ),
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _generalError = 'Terjadi kesalahan navigasi: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top Left Header
                    const OperatorHeader(
                      topPadding: 16,
                      horizontalPadding: 24,
                    ),

                    // Center Login Card
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 16.0,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 360),
                          child: _buildLoginCard(),
                        ),
                      ),
                    ),

                    // Bottom empty spacer to keep balanced vertical centering
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoginCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.operatorCardGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE2591B).withValues(alpha: 0.35),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo Smart H-EAT
          const SmartHeatLogo(size: 76),

          const SizedBox(height: 18),

          // Title
          const Text(
            'SELAMAT DATANG\nOPERATOR',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.textWhite,
              height: 1.25,
              letterSpacing: 0.3,
            ),
          ),

          const SizedBox(height: 10),

          // Subtitle
          const Text(
            'Silakan autentikasi akun Anda untuk membuka sesi kerja dan monitoring sistem H-EAT.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
              color: AppColors.textWhiteMuted,
              height: 1.45,
            ),
          ),

          const SizedBox(height: 22),

          // General Error Banner (if any)
          if (_generalError != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF7F1D1D).withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade300, width: 1),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _generalError!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Username / Email Field
          CustomTextField(
            controller: _usernameController,
            hintText: 'Masukan username/email',
            prefixIcon: Icons.person_outline_rounded,
            textInputAction: TextInputAction.next,
            errorText: _usernameError,
            onChanged: (_) {
              if (_usernameError != null) {
                setState(() => _usernameError = null);
              }
              if (_generalError != null) {
                setState(() => _generalError = null);
              }
            },
          ),

          const SizedBox(height: 12),

          // Password Field
          CustomTextField(
            controller: _passwordController,
            hintText: 'Masukan Password',
            prefixIcon: Icons.person_outline_rounded,
            isPassword: true,
            showVisibilityToggle: true,
            textInputAction: TextInputAction.done,
            errorText: _passwordError,
            onSubmitted: _handleLogin,
            onChanged: (_) {
              if (_passwordError != null) {
                setState(() => _passwordError = null);
              }
              if (_generalError != null) {
                setState(() => _generalError = null);
              }
            },
          ),

          const SizedBox(height: 20),

          // Button: "Masuk ke Sistem ->]"
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFA7826),
            Color(0xFFEA580C),
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton(
        key: const Key('login_submit_button'),
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          foregroundColor: AppColors.buttonTextDark,
          disabledBackgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          padding: EdgeInsets.zero,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'Masuk ke Sistem',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.buttonTextDark,
                      letterSpacing: 0.2,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.login_rounded,
                    color: AppColors.buttonTextDark,
                    size: 19,
                  ),
                ],
              ),
      ),
    );
  }
}
