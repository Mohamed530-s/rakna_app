import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:rakna_app/core/app_colors.dart';
import 'package:rakna_app/presentation/pages/login_screen.dart';
import 'package:rakna_app/presentation/widgets/cyberpunk_background.dart';
import 'package:rakna_app/presentation/widgets/r_arrow_logo.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  bool _isLastPage = false;

  void _completeOnboarding() async {
    HapticFeedback.heavyImpact();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 1000),
          pageBuilder: (_, __, ___) => const LoginScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: CyberpunkBackground(
        child: Stack(
          children: [
            PageView(
              controller: _controller,
              onPageChanged: (index) {
                HapticFeedback.selectionClick();
                setState(() {
                  _isLastPage = index == 2;
                });
              },
              children: [
                _buildLottiePage(
                  lottieAsset: 'assets/lottie/onboarding_map.json',
                  title: "Find Your Spot",
                  desc:
                      "No more circling around.\nLocate premium parking in seconds with AI precision.",
                ),
                _buildLottiePage(
                  lottieAsset: 'assets/lottie/onboarding_security.json',
                  title: "Digital Guard",
                  desc:
                      "Your spot is secured with a unique digital ticket.\nOnly you can access it.",
                ),
                _buildLottiePage(
                  lottieAsset: 'assets/lottie/onboarding_elite.json',
                  title: "Join the Elite",
                  desc:
                      "Experience the next level of luxury parking management.",
                  isLast: true,
                ),
              ],
            ),
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _controller,
                    count: 3,
                    effect: ExpandingDotsEffect(
                      activeDotColor: AppColors.accent,
                      dotColor: Colors.white.withValues(alpha: 0.2),
                      dotHeight: 6,
                      dotWidth: 6,
                      spacing: 8,
                      expansionFactor: 3,
                    ),
                  ),
                  const SizedBox(height: 36),
                  if (_isLastPage)
                    FadeInUp(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 60),
                        child: SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _completeOnboarding,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'GET STARTED',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                letterSpacing: 2.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 52),
                ],
              ),
            ),
            if (!_isLastPage)
              Positioned(
                top: 50,
                right: 20,
                child: SafeArea(
                  child: FadeIn(
                    child: TextButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        _controller.animateToPage(
                          2,
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Text(
                        "Skip",
                        style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLottiePage({
    required String lottieAsset,
    required String title,
    required String desc,
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInDown(
            duration: const Duration(milliseconds: 800),
            child: isLast
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const RArrowLogo(size: 80),
                      const SizedBox(height: 16),
                      Hero(
                        tag: 'app_logo',
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            'R A K N A',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                              fontSize: 42,
                              fontWeight: FontWeight.w200,
                              letterSpacing: 15.0,
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : SizedBox(
                    height: 300,
                    width: 300,
                    child: Lottie.asset(
                      lottieAsset,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppColors.accent.withValues(alpha: 0.6),
                            strokeWidth: 2,
                          ),
                        );
                      },
                    ),
                  ),
          ),
          const SizedBox(height: 60),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: Text(
              title,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: Text(
              desc,
              style: GoogleFonts.inter(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 15,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
