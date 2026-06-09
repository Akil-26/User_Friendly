import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/utils.dart';
import '../auth/screens/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      icon: Icons.newspaper_rounded,
      title: 'Your news,\nyour way',
      subtitle: 'Get personalized news from trusted sources like BBC, Reuters, The Hindu and more.',
      color: kPrimaryColor,
    ),
    _OnboardingData(
      icon: Icons.smart_toy_outlined,
      title: 'Chat with\nany article',
      subtitle: 'Ask questions about any news article and get AI-powered answers based only on that article.',
      color: const Color(0xFF3B82F6),
    ),
    _OnboardingData(
      icon: Icons.interests_outlined,
      title: 'Pick your\ninterests',
      subtitle: 'Choose topics you love — tech, sports, finance, science and more.',
      color: const Color(0xFF10B981),
    ),
  ];

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    AppSizes.init(context);
    return Scaffold(
      backgroundColor: kBgColor,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.all(AppSizes.spaceMd),
                child: TextButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ),
                  child: Text(
                    'Skip',
                    style: GoogleFonts.playfairDisplay(
                      color: kGrayText,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: EdgeInsets.all(AppSizes.spaceXl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 140.w,
                          height: 140.w,
                          decoration: BoxDecoration(
                            color: page.color.withAlpha(26), // 10% opacity
                            borderRadius: BorderRadius.circular(40.r),
                          ),
                          child: Icon(
                            page.icon,
                            size: 72.sp,
                            color: page.color,
                          ),
                        ),
                        SizedBox(height: 48.h),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 36.sp,
                            fontWeight: FontWeight.bold,
                            color: kDarkText,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: AppSizes.spaceMd),
                        Text(
                          page.subtitle,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 16.sp,
                            color: kGrayText,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSizes.spaceXl,
                0,
                AppSizes.spaceXl,
                AppSizes.spaceXl,
              ),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _pages.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: kPrimaryColor,
                      dotColor: kPrimaryColor.withAlpha(51), // 20% opacity
                      dotHeight: 8.h,
                      dotWidth: 8.w,
                      expansionFactor: 3,
                    ),
                  ),
                  SizedBox(height: AppSizes.spaceXl),
                  SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: ElevatedButton(
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingData {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  _OnboardingData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}