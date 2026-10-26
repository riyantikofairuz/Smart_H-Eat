import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../providers/cart_provider.dart';
import 'screensaver_screen.dart';

/// Skenario simulasi pembayaran lokal untuk kebutuhan prototipe dan pengujian frontend.
enum PaymentSimulationScenario {
  /// Perilaku default: layar bertahan pada tampilan QR tanpa batas waktu otomatis
  /// hingga pengguna menekan tombol "Batalkan Pesanan" (memicu layar gagal)
  /// atau mengetuk QR Code (memicu simulasi pembayaran berhasil).
  stayOnQr,

  /// Menjalankan simulasi pembayaran berhasil, menampilkan layar sukses selama 3 detik,
  /// mengosongkan keranjang, lalu otomatis mengarahkan pengguna ke Screensaver (SCR-01).
  simulateSuccess,

  /// Menjalankan simulasi timeout QR pembayaran gagal, menampilkan layar gagal selama 3 detik,
  /// mengosongkan keranjang, lalu otomatis mengarahkan pengguna ke Screensaver (SCR-01).
  simulateFailure,
}

/// Status visual pembayaran pada SCR-05.
enum PaymentState {
  /// SCR-05A — Kondisi menunggu pembayaran dengan QR Code aktif.
  pending,

  /// SCR-05C — Kondisi pembayaran gagal karena batas waktu (timeout) atau pembatalan.
  failed,

  /// SCR-05B — Kondisi pembayaran berhasil dikonfirmasi.
  success,
}

/// SCR-05 — Halaman Pembayaran (Payment Page)
///
/// Target perangkat: Android Tablet (~10 inci portrait, resolusi referensi 720 × 1280).
/// Mengimplementasikan seluruh alur pembayaran SCR-05:
/// - SCR-05A: QR Payment (kode QR dummy, banner total locked tanpa 'Rp', instruksi pindai, tombol Batalkan Pesanan, tap QR untuk simulasi pembayaran berhasil)
/// - SCR-05B: Payment Success (indikator centang hijau, judul "Pembayaran Berhasil", bertahan 3 detik, kosongkan keranjang, navigasi ke Screensaver)
/// - SCR-05C: Payment Failed (indikator silang merah, judul "Pembayaran Gagal", bertahan 3 detik, kosongkan keranjang, navigasi ke Screensaver)
/// - Pembatalan: Tekan "Batalkan Pesanan", batalkan timer simulasi, tampilkan layar Pembayaran Gagal selama 3 detik, kosongkan keranjang, lalu navigasi ke Screensaver (SCR-01)
class PaymentPage extends StatefulWidget {
  /// Skenario simulasi untuk kebutuhan pengujian internal.
  /// Jika null, membaca dari [globalScenario], lalu environment variable `PAYMENT_SCENARIO`,
  /// atau default ke [PaymentSimulationScenario.stayOnQr].
  final PaymentSimulationScenario? scenario;

  /// Jeda waktu sebelum simulasi [PaymentSimulationScenario.simulateSuccess] dipicu.
  /// Default: 3 detik.
  final Duration simulationDelay;

  /// Durasi timeout QR sebelum [PaymentSimulationScenario.simulateFailure] dipicu.
  /// Default: 5 detik.
  final Duration qrTimeout;

  /// Durasi penahanan tampilan layar hasil (gagal / berhasil) sebelum navigasi otomatis ke Screensaver.
  /// Sesuai spesifikasi: tepat 3 detik.
  final Duration resultDisplayDuration;

  /// Override nominal tagihan awal (opsional, jika tidak ingin membaca dari CartProvider).
  final int? initialTotal;

  /// Konfigurasi global skenario simulasi yang dapat diatur saat runtime untuk pengujian.
  static PaymentSimulationScenario? globalScenario;

  const PaymentPage({
    super.key,
    this.scenario,
    this.simulationDelay = const Duration(seconds: 3),
    this.qrTimeout = const Duration(seconds: 5),
    this.resultDisplayDuration = const Duration(seconds: 3),
    this.initialTotal,
  });

  /// Membaca konfigurasi default skenario dari environment (--dart-define=PAYMENT_SCENARIO=...).
  static PaymentSimulationScenario get defaultScenarioFromEnvironment {
    const env = String.fromEnvironment(
      'PAYMENT_SCENARIO',
      defaultValue: 'stayOnQr',
    );
    switch (env) {
      case 'simulateSuccess':
      case 'success':
        return PaymentSimulationScenario.simulateSuccess;
      case 'simulateFailure':
      case 'failure':
        return PaymentSimulationScenario.simulateFailure;
      case 'stayOnQr':
      default:
        return PaymentSimulationScenario.stayOnQr;
    }
  }

  /// Memformat angka nominal menjadi string dengan tanda titik (.) pemisah ribuan tanpa awalan 'Rp'.
  /// Contoh: 28000 -> "28.000", 50000 -> "50.000", 112000 -> "112.000".
  static String formatNominal(int amount) {
    final s = amount.toString();
    final buf = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      buf.write(s[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buf.write('.');
      }
    }
    return buf.toString().split('').reversed.join('');
  }

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

/// Alias untuk keselarasan penamaan dengan Screen lain di project.
typedef PaymentScreen = PaymentPage;

class _PaymentPageState extends State<PaymentPage> {
  // Palet warna kurasi sesuai spesifikasi dan identitas brand
  static const Color _brandPrimary = Color(0xFFAB2F00);
  static const Color _bannerGradientStart = Color(0xFF8B2500);
  static const Color _bannerGradientEnd = Color(0xFFFF6D00);
  static const Color _scaffoldBg = Color(0xFFF7F7F8);
  static const Color _textDark = Color(0xFF1E1E1E);
  static const Color _statusRed = Color(0xFFE53935);
  static const Color _statusGreen = Color(0xFF22C55E);

  PaymentState _paymentState = PaymentState.pending;
  int _lockedNominal = 0;
  bool _nominalInitialized = false;

  Timer? _simulationTimer;
  Timer? _autoNavigateTimer;
  bool _isNavigating = false;

  PaymentSimulationScenario get _activeScenario {
    return widget.scenario ??
        PaymentPage.globalScenario ??
        PaymentPage.defaultScenarioFromEnvironment;
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialTotal != null) {
      _lockedNominal = widget.initialTotal!;
      _nominalInitialized = true;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_nominalInitialized) {
      final cart = CartProvider.maybeOf(context, listen: false);
      final grandTotal =
          cart?.items.fold(0, (sum, item) => sum + item.totalPrice) ?? 0;
      _lockedNominal = grandTotal;
      _nominalInitialized = true;
    }

    // Memulai timer simulasi sesuai skenario jika belum berjalan
    _initiateSimulationIfNeeded();
  }

  void _initiateSimulationIfNeeded() {
    if (_paymentState != PaymentState.pending) return;
    if (_simulationTimer != null) return;

    final scenario = _activeScenario;
    if (scenario == PaymentSimulationScenario.simulateFailure) {
      _simulationTimer = Timer(widget.qrTimeout, _triggerFailure);
    } else if (scenario == PaymentSimulationScenario.simulateSuccess) {
      _simulationTimer = Timer(widget.simulationDelay, _triggerSuccess);
    }
    // stayOnQr: tidak membuat timer transisi otomatis (tetap berada di halaman QR)
  }

  void _cancelAllTimers() {
    _simulationTimer?.cancel();
    _simulationTimer = null;
    _autoNavigateTimer?.cancel();
    _autoNavigateTimer = null;
  }

  @override
  void dispose() {
    _cancelAllTimers();
    super.dispose();
  }

  /// Pemicu simulasi pembayaran gagal (timeout atau pembatalan pesanan).
  void _triggerFailure() {
    if (!mounted || _paymentState != PaymentState.pending) return;
    _cancelAllTimers();

    setState(() {
      _paymentState = PaymentState.failed;
    });

    // Menahan tampilan selama tepat 3 detik, lalu mengosongkan keranjang dan kembali ke Screensaver
    _autoNavigateTimer = Timer(widget.resultDisplayDuration, () {
      if (!mounted) return;
      final cart = CartProvider.maybeOf(context, listen: false);
      cart?.clear();
      _navigateToScreensaver();
    });
  }

  /// Pemicu simulasi pembayaran berhasil.
  void _triggerSuccess() {
    if (!mounted || _paymentState != PaymentState.pending) return;
    _cancelAllTimers();

    setState(() {
      _paymentState = PaymentState.success;
    });

    // Menahan tampilan selama tepat 3 detik, lalu mengosongkan keranjang dan kembali ke Screensaver
    _autoNavigateTimer = Timer(widget.resultDisplayDuration, () {
      if (!mounted) return;
      final cart = CartProvider.maybeOf(context, listen: false);
      cart?.clear();
      _navigateToScreensaver();
    });
  }

  /// Pemicu simulasi sukses saat pengguna mengetuk area QR Code.
  void _handleQrTapped() {
    if (!mounted || _paymentState != PaymentState.pending) return;
    _triggerSuccess();
  }

  /// Penanganan tombol pembatalan "Batalkan Pesanan".
  /// 1. Tampilkan layar Pembayaran Gagal.
  /// 2. Layar Pembayaran Gagal bertahan selama 3 detik.
  /// 3. Setelah 3 detik, kosongkan seluruh keranjang dan state transaksi terkait.
  /// 4. Navigasikan pengguna ke Screensaver (SCR-01), bukan ke Menu.
  void _handleCancelOrder() {
    if (!mounted || _paymentState != PaymentState.pending) return;
    _triggerFailure();
  }

  void _navigateToScreensaver() {
    if (_isNavigating) return;
    _isNavigating = true;
    _cancelAllTimers();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const ScreensaverScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPending = _paymentState == PaymentState.pending;

    // PopScope dinonaktifkan (canPop: false) agar pengguna hanya dapat membatalkan
    // melalui tombol Batalkan Pesanan.
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: _scaffoldBg,
        body: SafeArea(
          child: Column(
            children: [
              // ── Header Bar (Hanya tampil pada Pending / QR State) ─────────
              if (isPending) _buildHeaderBar(),

              // ── Area Tengah (Main Payment Card) ──────────────────────────
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: _buildMainPaymentCard(),
                    ),
                  ),
                ),
              ),

              // ── Panel Bawah (Hanya tampil pada Pending / QR State) ────────
              if (isPending) _buildBottomPanel(),
            ],
          ),
        ),
      ),
    );
  }

  /// Header Bar statis: 2 baris teks tanpa tombol navigasi kembali.
  Widget _buildHeaderBar() {
    return Container(
      key: const ValueKey('payment_header_bar'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'SMART H-EAT',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: _brandPrimary,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 2),
          Text(
            'Pembayaran',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _textDark,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  /// Main Payment Card vertikal dengan sudut membulat dan drop shadow tegas.
  Widget _buildMainPaymentCard() {
    return Container(
      key: const ValueKey('main_payment_card'),
      constraints: const BoxConstraints(maxWidth: 480),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Nominal Header Banner ──────────────────────────────────────
            _buildNominalHeaderBanner(),

            // ── Area Isi Bagian Bawah Kartu ────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Center(child: _buildCardContent()),
            ),
          ],
        ),
      ),
    );
  }

  /// Nominal Header Banner dengan gradasi horizontal dan nominal besar di tengah.
  /// Nominal tidak memiliki awalan 'Rp'.
  Widget _buildNominalHeaderBanner() {
    final formatted = PaymentPage.formatNominal(_lockedNominal);

    return Container(
      key: const ValueKey('nominal_header_banner'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [_bannerGradientStart, _bannerGradientEnd],
        ),
      ),
      child: Center(
        child: Text(
          formatted,
          style: const TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  /// Konten di dalam Main Payment Card yang berganti sesuai state:
  /// - Pending: QR Code Container + Instruksi Pindai
  /// - Failed: Failed Status Box
  /// - Success: Success Status Box
  Widget _buildCardContent() {
    switch (_paymentState) {
      case PaymentState.pending:
        return _buildQrCodeContainer();
      case PaymentState.failed:
        return _buildFailedStatusBox();
      case PaymentState.success:
        return _buildSuccessStatusBox();
    }
  }

  /// Kotak Kode QR bergaris tepi hitam tebal disertai instruksi pemindaian.
  /// Area QR Code dapat diketuk untuk memicu simulasi pembayaran berhasil secara lokal.
  Widget _buildQrCodeContainer() {
    final canTap = _paymentState == PaymentState.pending;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            key: const ValueKey('qr_code_container'),
            onTap: canTap ? _handleQrTapped : null,
            borderRadius: BorderRadius.circular(16),
            splashColor: _brandPrimary.withValues(alpha: 0.12),
            highlightColor: _brandPrimary.withValues(alpha: 0.06),
            child: Ink(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black, width: 3.5),
              ),
              padding: const EdgeInsets.all(14),
              child: const _QrCodeDisplay(),
            ),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Pindai kode QR untuk melakukan pembayaran',
          key: ValueKey('qr_scan_instruction'),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF666666),
          ),
        ),
      ],
    );
  }

  /// Kotak Status Pembayaran Gagal berbingkai merah tipis.
  Widget _buildFailedStatusBox() {
    return Container(
      key: const ValueKey('failed_status_box'),
      width: 260,
      height: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _statusRed, width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Pembayaran Gagal',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: _textDark,
              letterSpacing: -0.2,
            ),
          ),
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: _statusRed,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Icon(Icons.close_rounded, color: Colors.white, size: 42),
            ),
          ),
          const Text(
            'Pembayaran tidak berhasil dan sesi pesanan telah berakhir.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _textDark,
              letterSpacing: 0.2,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  /// Kotak Status Pembayaran Berhasil berbingkai hijau terang tipis.
  Widget _buildSuccessStatusBox() {
    return Container(
      key: const ValueKey('success_status_box'),
      width: 260,
      height: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _statusGreen, width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Pembayaran Berhasil',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: _textDark,
              letterSpacing: -0.2,
            ),
          ),
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: _statusGreen,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Icon(Icons.check_rounded, color: Colors.white, size: 42),
            ),
          ),
          const Text(
            'Pesanan Anda berhasil diproses dan akan segera disiapkan.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _textDark,
              letterSpacing: 0.2,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  /// Fixed Bottom Action Panel dengan tombol "Batalkan Pesanan".
  Widget _buildBottomPanel() {
    return Container(
      key: const ValueKey('payment_bottom_panel'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            offset: const Offset(0, -2),
            blurRadius: 4,
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          key: const ValueKey('cancel_order_button'),
          onPressed: _handleCancelOrder,
          style: ElevatedButton.styleFrom(
            backgroundColor: _brandPrimary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Batalkan Pesanan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget penggambaran QR Code hitam-putih presisi dan realistis menggunakan CustomPainter.
class _QrCodeDisplay extends StatelessWidget {
  const _QrCodeDisplay();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _QrPainter(), child: const SizedBox.expand());
  }
}

class _QrPainter extends CustomPainter {
  static const int _gridSize = 25;
  static final List<List<bool>> _matrix = _generateDeterministicMatrix();

  static List<List<bool>> _generateDeterministicMatrix() {
    final matrix = List.generate(
      _gridSize,
      (_) => List.generate(_gridSize, (_) => false),
    );

    // 1. Tiga Finder Patterns (Sudut Kiri-Atas, Kanan-Atas, Kiri-Bawah)
    void drawFinderPattern(int startRow, int startCol) {
      for (int r = 0; r < 7; r++) {
        for (int c = 0; c < 7; c++) {
          final isOuter = r == 0 || r == 6 || c == 0 || c == 6;
          final isInner = r >= 2 && r <= 4 && c >= 2 && c <= 4;
          matrix[startRow + r][startCol + c] = isOuter || isInner;
        }
      }
    }

    drawFinderPattern(0, 0);
    drawFinderPattern(0, _gridSize - 7);
    drawFinderPattern(_gridSize - 7, 0);

    // 2. Timing Patterns (baris 6 dan kolom 6)
    for (int i = 7; i < _gridSize - 7; i++) {
      final val = i.isEven;
      matrix[6][i] = val;
      matrix[i][6] = val;
    }

    // 3. Alignment Pattern dekat kanan-bawah
    const alignRow = _gridSize - 7;
    const alignCol = _gridSize - 7;
    for (int r = -2; r <= 2; r++) {
      for (int c = -2; c <= 2; c++) {
        final isBorder = r.abs() == 2 || c.abs() == 2;
        final isCenter = r == 0 && c == 0;
        matrix[alignRow + r][alignCol + c] = isBorder || isCenter;
      }
    }

    // 4. Modul Data Dummy Berpola Deterministik (Seed Tetap)
    final random = Random(42);
    for (int r = 0; r < _gridSize; r++) {
      for (int c = 0; c < _gridSize; c++) {
        // Jangan timpa Finder Patterns & Separator (7x7 + 1 margin)
        final inTopLeft = r <= 7 && c <= 7;
        final inTopRight = r <= 7 && c >= _gridSize - 8;
        final inBottomLeft = r >= _gridSize - 8 && c <= 7;
        final inTiming =
            (r == 6 && c >= 7 && c < _gridSize - 7) ||
            (c == 6 && r >= 7 && r < _gridSize - 7);
        final inAlignment =
            (r - alignRow).abs() <= 2 && (c - alignCol).abs() <= 2;

        if (inTopLeft ||
            inTopRight ||
            inBottomLeft ||
            inTiming ||
            inAlignment) {
          continue;
        }

        matrix[r][c] = random.nextBool();
      }
    }

    return matrix;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final moduleWidth = size.width / _gridSize;
    final moduleHeight = size.height / _gridSize;

    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    for (int r = 0; r < _gridSize; r++) {
      for (int c = 0; c < _gridSize; c++) {
        if (_matrix[r][c]) {
          canvas.drawRect(
            Rect.fromLTWH(
              c * moduleWidth,
              r * moduleHeight,
              moduleWidth,
              moduleHeight,
            ),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
