import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_state.dart';
import '../news/bloc/news_bloc.dart';
import '../news/bloc/news_event.dart';
import '../news/screens/news_feed_screen.dart';
import '../news/screens/all_news_screen.dart';
import '../profile/screens/profile_screen.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/utils.dart';
import '../../core/widgets/instruction_overlay.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    context.read<NewsBloc>().add(NewsFeedRequested());
  }

  @override
  Widget build(BuildContext context) {
    AppSizes.init(context);
    return InstructionOverlay(
      child: Scaffold(
        backgroundColor: kBgColor,
        body: SafeArea(
          child: Column(
            children: [
              // ── AppBar ──────────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSizes.spaceLg,
                  AppSizes.spaceMd,
                  AppSizes.spaceLg,
                  0,
                ),
                child: Row(
                  children: [
                    // Page dots
                    Row(
                      children: List.generate(
                        2,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: EdgeInsets.only(right: 4.w),
                          width: _currentPage == i ? 20.w : 6.w,
                          height: 6.h,
                          decoration: BoxDecoration(
                            color: _currentPage == i
                                ? kPrimaryColor
                                : kPrimaryColor.withAlpha(77), // 30% opacity
                            borderRadius: BorderRadius.circular(3.r),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'User Friendly',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryColor,
                      ),
                    ),
                    const Spacer(),
                    // Profile avatar
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProfileScreen(),
                        ),
                      ),
                      child: BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          final name = state is AuthAuthenticated
                              ? state.user.name[0].toUpperCase()
                              : 'U';
                          return CircleAvatar(
                            radius: 18.r,
                            backgroundColor: kPrimaryColor,
                            child: Text(
                              name,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSizes.spaceSm),

              // ── Swipeable pages ─────────────────────────
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  children: const [
                    NewsFeedScreen(),
                    AllNewsScreen(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}