import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/utils.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_state.dart';
import '../onboarding/onboarding_screen.dart';
import '../main/main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  // Plane fly-in
  late AnimationController _planeController;
  late Animation<Offset> _planePosition;
  late Animation<double> _planeScale;
  late Animation<double> _planeRotation;

  // Title reveal
  late AnimationController _titleController;
  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _taglineFade;

  // Idle float
  late AnimationController _floatController;
  late Animation<double> _floatY;

  // Loading dots
  late AnimationController _dotsController;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    // ── Plane flies in ─────────────────────────────
    _planeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _planePosition = Tween<Offset>(
      begin: const Offset(-1.5, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _planeController,
      curve: Curves.easeOutCubic,
    ));

    _planeScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _planeController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _planeRotation = Tween<double>(begin: -0.15, end: 0.0).animate(
      CurvedAnimation(
        parent: _planeController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    // ── Title fades up ──────────────────────────────
    _titleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _titleFade = CurvedAnimation(
      parent: _titleController,
      curve: Curves.easeOut,
    );

    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _titleController,
      curve: Curves.easeOutCubic,
    ));

    _taglineFade = CurvedAnimation(
      parent: _titleController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    );

    // ── Idle float loop ─────────────────────────────
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _floatY = Tween<double>(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(
        parent: _floatController,
        curve: Curves.easeInOut,
      ),
    );

    // ── Loading dots pulse ──────────────────────────
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _runSequence();
  }

  Future<void> _runSequence() async {
    // Short pause so cream bg settles
    await Future.delayed(const Duration(milliseconds: 150));

    // Plane flies in
    await _planeController.forward();

    // Start floating idle
    _floatController.repeat(reverse: true);

    // Title appears
    await Future.delayed(const Duration(milliseconds: 100));
    _titleController.forward();

    // Dots pulse
    await Future.delayed(const Duration(milliseconds: 400));
    _dotsController.repeat(reverse: true);

    // Hold for branding moment
    await Future.delayed(const Duration(milliseconds: 1800));

    _navigate();
  }

  void _navigate() {
    if (!mounted) return;
    final authState = context.read<AuthBloc>().state;

    Widget destination;
    if (authState is AuthAuthenticated) {
      destination = const MainScreen();
    } else {
      destination = const OnboardingScreen();
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => destination,
        transitionDuration: const Duration(milliseconds: 600),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: anim,
          child: child,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _planeController.dispose();
    _titleController.dispose();
    _floatController.dispose();
    _dotsController.dispose();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
    ));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppSizes.init(context);

    return Scaffold(
      backgroundColor: kBgColor,
      body: Stack(
        children: [

          // ── Subtle background circles ───────────────
          Positioned(
            top: -80.h,
            right: -80.w,
            child: Container(
              width: 280.w,
              height: 280.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kPrimaryColor.withAlpha(15),
              ),
            ),
          ),
          Positioned(
            bottom: -100.h,
            left: -100.w,
            child: Container(
              width: 320.w,
              height: 320.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kPrimaryColor.withAlpha(10),
              ),
            ),
          ),

          // ── Main content ────────────────────────────
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  // Paper plane with float animation
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _planeController,
                      _floatController,
                    ]),
                    builder: (context, child) {
                      return SlideTransition(
                        position: _planePosition,
                        child: Transform.translate(
                          offset: Offset(0, _floatY.value),
                          child: Transform.rotate(
                            angle: _planeRotation.value,
                            child: ScaleTransition(
                              scale: _planeScale,
                              child: child,
                            ),
                          ),
                        ),
                      );
                    },
                    child: Image.asset(
                      'assets/images/paperplane.png',
                      width: 220.w,
                      height: 220.w,
                      fit: BoxFit.contain,
                    ),
                  ),

                  SizedBox(height: 36.h),

                  // Title + tagline
                  SlideTransition(
                    position: _titleSlide,
                    child: FadeTransition(
                      opacity: _titleFade,
                      child: Column(
                        children: [
                          Text(
                            'User Friendly',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 38.sp,
                              fontWeight: FontWeight.bold,
                              color: kDarkText,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          FadeTransition(
                            opacity: _taglineFade,
                            child: Text(
                              'NEWS THAT KNOWS YOU',
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                color: kGrayText,
                                letterSpacing: 3,
                                fontWeight: FontWeight.w600,
                              ),
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

          // ── Loading dots at bottom ──────────────────
          Positioned(
            bottom: 52.h + AppSizes.bottomBarHeight,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _dotsController,
              builder: (context, _) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) {
                    final delay = i * 0.25;
                    final t = (_dotsController.value - delay).clamp(0.0, 1.0);
                    final opacity = (math.sin(t * math.pi)).clamp(0.2, 1.0);
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      width: 7.w,
                      height: 7.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: kPrimaryColor.withAlpha((opacity * 255).round()),
                      ),
                    );
                  }),
                );
              },
            ),
          ),

          // ── Branding footer ─────────────────────────
          Positioned(
            bottom: 20.h + AppSizes.bottomBarHeight,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _taglineFade,
              child: Text(
                'by Akileshwaran',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  color: kGrayText.withAlpha(128),
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}