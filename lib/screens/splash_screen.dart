import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AnimationController _scaleController;
  late final AnimationController _slideController;

  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    // Staggered animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _scaleController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _slideController.forward();
    });

    // Navigate after 2.8s
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) widget.onComplete();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final mascotDimension = math.min(size.width * 0.52, size.height * 0.28).clamp(130.0, 230.0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Subtle teal radial glow in center-upper area
          Positioned(
            top: size.height * 0.12,
            left: size.width * 0.1,
            right: size.width * 0.1,
            child: Container(
              height: size.height * 0.45,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF00B4A6).withValues(alpha: 0.15),
                    const Color(0xFF00B4A6).withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),

          // Decorative floating dots — top-left
          _dot(top: size.height * 0.06, left: size.width * 0.08, radius: 6, color: const Color(0xFF00B4A6)),
          _dot(top: size.height * 0.10, left: size.width * 0.18, radius: 4, color: const Color(0xFFFF9EB5), filled: false),
          // top-right
          _dot(top: size.height * 0.07, right: size.width * 0.10, radius: 9, color: const Color(0xFF00B4A6)),
          _dot(top: size.height * 0.13, right: size.width * 0.22, radius: 5, color: const Color(0xFFFF9EB5)),
          // bottom-left
          _dot(bottom: size.height * 0.10, left: size.width * 0.06, radius: 7, color: const Color(0xFF00B4A6)),
          _dot(bottom: size.height * 0.16, left: size.width * 0.20, radius: 4, color: const Color(0xFFFF9EB5)),
          // bottom-right
          _dot(bottom: size.height * 0.08, right: size.width * 0.08, radius: 5, color: const Color(0xFF00B4A6), filled: false),
          _dot(bottom: size.height * 0.14, right: size.width * 0.18, radius: 8, color: const Color(0xFF00B4A6)),
          _dot(bottom: size.height * 0.06, right: size.width * 0.30, radius: 4, color: const Color(0xFFFF9EB5)),

          // Main content
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Brain mascot with scale + fade animation
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: ScaleTransition(
                        scale: _scaleAnim,
                        child: Image.asset(
                          'assets/images/brain_mascot.png',
                          width: mascotDimension,
                          height: mascotDimension,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // App name + tagline slide up + fade
                    SlideTransition(
                      position: _slideAnim,
                      child: FadeTransition(
                        opacity: _fadeAnim,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // App name
                            Text(
                              'Recallio',
                              style: GoogleFonts.nunito(
                                fontSize: 44,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF1A2E5A),
                                letterSpacing: -1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Tagline
                            Text(
                              'Study Smart. Recall Better.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontStyle: FontStyle.italic,
                                color: const Color(0xFF00B4A6),
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom loading indicator
          Positioned(
            bottom: size.height * 0.06,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      const Color(0xFF00B4A6).withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double radius,
    required Color color,
    bool filled = true,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: filled ? color : Colors.transparent,
          border: filled ? null : Border.all(color: color, width: 2),
        ),
      ),
    );
  }
}
