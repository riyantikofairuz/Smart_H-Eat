import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';

import 'menu_screen.dart';

class ScreensaverScreen extends StatefulWidget {
  const ScreensaverScreen({super.key});

  @override
  State<ScreensaverScreen> createState() => _ScreensaverScreenState();
}

class _ScreensaverScreenState extends State<ScreensaverScreen>
    with TickerProviderStateMixin {
  late VideoPlayerController _videoController;

  // Slogan: slow, breathing glow — 3.8 seconds cycle
  late AnimationController _sloganController;
  late Animation<double> _sloganFade;

  // CTA: slightly faster pulse — 2.4 seconds cycle, offset from slogan
  late AnimationController _ctaController;
  late Animation<double> _ctaFade;

  // Fade-to-black overlay controller — drives the SCR-01 exit animation.
  // This is what was missing: without fading OUT the current screen first,
  // the incoming FadeTransition had nothing to transition FROM (black → black
  // = invisible).
  late AnimationController _exitOverlayController;
  late Animation<double> _exitOverlayOpacity;

  bool _isVideoInitialized = false;

  // Guard against double-tap triggering multiple navigations
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();

    // Force portrait mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Initialize video — local looping promotional video
    _videoController =
        VideoPlayerController.asset(
            'assets/gemini_generated_video_c5b99b1c.mp4',
          )
          ..initialize()
              .then((_) {
                if (!mounted) return;
                setState(() {
                  _isVideoInitialized = true;
                });
                _videoController.setLooping(true);
                _videoController.play();
              })
              .catchError((error) {
                debugPrint('Video initialization failed: $error');
              });

    // --- Slogan animation: slow cinematic breath ---
    // Range 0.75–1.0: slogan never fully disappears, stays prominent.
    _sloganController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    )..repeat(reverse: true);

    _sloganFade = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(parent: _sloganController, curve: Curves.easeInOut),
    );

    // --- CTA animation: slightly faster, offset so both never dim simultaneously ---
    // Range 0.35–0.9: CTA has wider swing to feel inviting without competing with slogan.
    _ctaController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _ctaFade = Tween<double>(
      begin: 0.35,
      end: 0.9,
    ).animate(CurvedAnimation(parent: _ctaController, curve: Curves.easeInOut));

    // --- Exit overlay: starts fully transparent, animates to fully black ---
    // This is the key fix: by making SCR-01 fade to black BEFORE pushReplacement,
    // the user sees a visible, smooth "video → black" transition. The incoming
    // MenuScreen then fades in from black, creating a complete cinematic arc.
    _exitOverlayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _exitOverlayOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _exitOverlayController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _videoController.dispose();
    _sloganController.dispose();
    _ctaController.dispose();
    _exitOverlayController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    // Prevent double-tap / re-entry
    if (_isNavigating) return;
    _isNavigating = true;

    // Stop cinematic animations so they don't fight the exit fade
    _sloganController.stop();
    _ctaController.stop();

    // Phase 1 — Fade current screen to black (SCR-01 exit)
    // The overlay animates over the existing video frame: video fades away visibly.
    await _exitOverlayController.forward();

    // Guard: if widget was disposed during the async wait, abort navigation
    if (!mounted) return;

    // Phase 2 — Navigate to MenuScreen with a fade-in (SCR-02 entry)
    // At this point the overlay is fully black, so MenuScreen fading in from
    // opacity 0 → 1 is clearly visible against the solid black background.
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        // Duration slightly shorter than Phase 1 so the combined arc feels
        // balanced rather than sluggish.
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MenuScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Video Layer ──────────────────────────────────────────────────
            if (_isVideoInitialized && _videoController.value.isInitialized)
              SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _videoController.value.size.width > 0
                        ? _videoController.value.size.width
                        : 16,
                    height: _videoController.value.size.height > 0
                        ? _videoController.value.size.height
                        : 9,
                    child: VideoPlayer(_videoController),
                  ),
                ),
              ),

            // ── Cinematic bottom gradient ────────────────────────────────────
            // Subtle warm vignette ensures text legibility across all video frames
            // without hiding the food footage.
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.45, 0.75, 1.0],
                    colors: [
                      Colors.black.withValues(alpha: 0.0),
                      Colors.black.withValues(alpha: 0.0),
                      Colors.black.withValues(alpha: 0.45),
                      Colors.black.withValues(alpha: 0.80),
                    ],
                  ),
                ),
              ),
            ),

            // ── Text Layer ───────────────────────────────────────────────────
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Spacer(),

                  // Slogan — premium typography with layered shadows
                  FadeTransition(
                    opacity: _sloganFade,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        'CITA RASA AUTENTIK\nDI SETIAP SUAPAN.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.5,
                          height: 1.35,
                          shadows: [
                            // Deep anchor shadow for contrast
                            Shadow(
                              color: Color(0xCC000000),
                              blurRadius: 18,
                              offset: Offset(0, 3),
                            ),
                            // Warm amber glow — subtle Smart Heat brand warmth
                            Shadow(
                              color: Color(0x55E85827),
                              blurRadius: 32,
                              offset: Offset(0, 0),
                            ),
                            // Second pass for depth
                            Shadow(
                              color: Color(0x88000000),
                              blurRadius: 6,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // CTA — slightly smaller, clearly subordinate to slogan
                  FadeTransition(
                    opacity: _ctaFade,
                    child: const Text(
                      'tap everywhare to start',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(
                          0xFFE0C9B0,
                        ), // Warm cream — readable, not harsh white
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1.8,
                        shadows: [
                          Shadow(
                            color: Color(0xAA000000),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),
                ],
              ),
            ),

            // ── Exit Fade-to-Black Overlay ───────────────────────────────────
            // KEY FIX: This overlay sits above all content. When _handleTap is
            // called, it animates from fully transparent (invisible) to fully
            // opaque black. The user sees the video frame fade to black BEFORE
            // Navigator.pushReplacement is called. This makes the outgoing
            // transition clearly visible. Without this layer, pushReplacement
            // instantly culled the Scaffold background (already black), making
            // the FadeTransition on the incoming page look like nothing happened.
            FadeTransition(
              opacity: _exitOverlayOpacity,
              child: const ColoredBox(color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
