import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../utils/utils.dart';
import '../services/prefs_service.dart';

class InstructionOverlay extends StatefulWidget {
  final Widget child;
  const InstructionOverlay({super.key, required this.child});

  @override
  State<InstructionOverlay> createState() => _InstructionOverlayState();
}

class _InstructionOverlayState extends State<InstructionOverlay>
    with SingleTickerProviderStateMixin {
  bool _show = false;
  int _step = 0;
  late AnimationController _controller;
  late Animation<double> _fade;

  // Each step: which area to highlight + where tooltip appears
  final List<_TooltipStep> _steps = [
    _TooltipStep(
      icon: Icons.swipe_right_outlined,
      title: 'Swipe left to explore',
      subtitle: 'Swipe left to browse all news by category tabs',
      tooltipAlignment: TooltipPosition.bottom,
      highlightRect: null, // bottom of screen hint
    ),
    _TooltipStep(
      icon: Icons.smart_toy_outlined,
      title: 'Chat with any article',
      subtitle: 'Tap the orange button to ask AI questions — answers come only from that article',
      tooltipAlignment: TooltipPosition.bottom,
      highlightRect: null,
    ),
    _TooltipStep(
      icon: Icons.touch_app_outlined,
      title: 'Tap to read full article',
      subtitle: 'Tapping anywhere on the card opens the original article in your browser',
      tooltipAlignment: TooltipPosition.bottom,
      highlightRect: null,
    ),
    _TooltipStep(
      icon: Icons.person_outlined,
      title: 'Your profile is up here',
      subtitle: 'Tap your avatar to update interests, change password, or manage your account',
      tooltipAlignment: TooltipPosition.top,
      highlightRect: null,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    final first = await PrefsService.isFirstTime();
    if (first && mounted) {
      setState(() => _show = true);
      _controller.forward();
    }
  }

  void _next() {
    if (_step < _steps.length - 1) {
      setState(() => _step++);
    } else {
      _dismiss();
    }
  }

  Future<void> _dismiss() async {
    await _controller.reverse();
    await PrefsService.markSeen();
    if (mounted) setState(() => _show = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppSizes.init(context);
    if (!_show) return widget.child;

    final step = _steps[_step];
    final isLast = _step == _steps.length - 1;
    final isTop = step.tooltipAlignment == TooltipPosition.top;

    return Stack(
      children: [
        widget.child,
        FadeTransition(
          opacity: _fade,
          child: Container(
            color: Colors.black.withAlpha(200), // 80% opacity
            child: SafeArea(
              child: Stack(
                children: [
                  // Tooltip positioned based on step
                  Positioned(
                    top: isTop ? 60.h : null,
                    bottom: isTop ? null : 60.h,
                    left: 20.w,
                    right: 20.w,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: isTop
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        // Arrow pointing up (for top tooltip)
                        if (isTop)
                          Padding(
                            padding: EdgeInsets.only(right: 18.w),
                            child: CustomPaint(
                              size: Size(16.w, 10.h),
                              painter: _ArrowPainter(pointUp: true),
                            ),
                          ),

                        // Tooltip card
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(18.r),
                          ),
                          padding: EdgeInsets.all(AppSizes.spaceLg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Icon
                              Container(
                                width: 40.w,
                                height: 40.w,
                                decoration: BoxDecoration(
                                  color: kPrimaryColor,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Icon(
                                  step.icon,
                                  color: Colors.white,
                                  size: 22.sp,
                                ),
                              ),
                              SizedBox(height: 12.h),

                              // Title
                              Text(
                                step.title,
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4.h),

                              // Subtitle
                              Text(
                                step.subtitle,
                                style: GoogleFonts.inter(
                                  color: Colors.white60,
                                  fontSize: 13.sp,
                                  height: 1.5,
                                ),
                              ),
                              SizedBox(height: 16.h),

                              // Footer: dots + next/done button
                              Row(
                                children: [
                                  // Dots
                                  Row(
                                    children: List.generate(
                                      _steps.length,
                                      (i) => AnimatedContainer(
                                        duration: const Duration(
                                            milliseconds: 200),
                                        margin:
                                            EdgeInsets.only(right: 5.w),
                                        width: i == _step ? 18.w : 6.w,
                                        height: 6.h,
                                        decoration: BoxDecoration(
                                          color: i == _step
                                              ? kPrimaryColor
                                              : Colors.white24,
                                          borderRadius:
                                              BorderRadius.circular(3.r),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Spacer(),

                                  // Next / Done button
                                  GestureDetector(
                                    onTap: _next,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                        vertical: 8.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: kPrimaryColor,
                                        borderRadius: BorderRadius.circular(
                                            AppSizes.radiusCircular),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            isLast ? 'Done' : 'Next',
                                            style: GoogleFonts.inter(
                                              color: Colors.white,
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          if (!isLast) ...[
                                            SizedBox(width: 4.w),
                                            Icon(
                                              Icons.arrow_forward_rounded,
                                              color: Colors.white,
                                              size: 14.sp,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Arrow pointing down (for bottom tooltip)
                        if (!isTop)
                          Padding(
                            padding: EdgeInsets.only(left: 18.w),
                            child: CustomPaint(
                              size: Size(16.w, 10.h),
                              painter: _ArrowPainter(pointUp: false),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Skip button
                  Positioned(
                    top: 0,
                    right: 20.w,
                    child: TextButton(
                      onPressed: _dismiss,
                      child: Text(
                        'Skip',
                        style: GoogleFonts.inter(
                          color: Colors.white60,
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Arrow painter for tooltip tail
class _ArrowPainter extends CustomPainter {
  final bool pointUp;
  _ArrowPainter({required this.pointUp});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..style = PaintingStyle.fill;

    final path = Path();
    if (pointUp) {
      path.moveTo(size.width / 2, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    } else {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width / 2, size.height);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

enum TooltipPosition { top, bottom }

class _TooltipStep {
  final IconData icon;
  final String title;
  final String subtitle;
  final TooltipPosition tooltipAlignment;
  final Rect? highlightRect;

  _TooltipStep({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.tooltipAlignment,
    this.highlightRect,
  });
}