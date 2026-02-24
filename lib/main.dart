import 'package:device_frame/device_frame.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rakna_app/core/app_theme.dart';
import 'package:rakna_app/injection_container.dart' as di;
import 'package:rakna_app/presentation/manager/auth_cubit.dart';
import 'package:rakna_app/presentation/manager/auth_state.dart';
import 'package:rakna_app/presentation/manager/booking_cubit.dart';
import 'package:rakna_app/presentation/manager/parking_cubit.dart';
import 'package:rakna_app/presentation/manager/theme_cubit.dart';
import 'package:rakna_app/presentation/pages/guard_home_screen.dart';
import 'package:rakna_app/presentation/pages/home_screen.dart';
import 'package:rakna_app/presentation/pages/login_screen.dart';
import 'package:rakna_app/presentation/pages/onboarding_screen.dart';

const bool _kShowDeviceFrame = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  ));

  await Firebase.initializeApp();
  await di.init();

  runApp(const RaknaApp());
}

class RaknaApp extends StatelessWidget {
  const RaknaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => di.sl<AuthCubit>()..checkAuthStatus()),
        BlocProvider(create: (_) => di.sl<ParkingCubit>()),
        BlocProvider(create: (_) => di.sl<BookingCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          final app = MaterialApp(
            title: 'Rakna',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            home: const _AuthGate(),
          );

          if (!_kShowDeviceFrame) return app;

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData.dark().copyWith(
              scaffoldBackgroundColor: const Color(0xFF111111),
            ),
            home: Scaffold(
              backgroundColor: const Color(0xFF111111),
              body: SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: DeviceFrame(
                      device: Devices.ios.iPhone13ProMax,
                      isFrameVisible: true,
                      orientation: Orientation.portrait,
                      screen: app,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  bool? _onboardingComplete;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance().timeout(
        const Duration(seconds: 3),
      );
      if (mounted) {
        setState(() {
          _onboardingComplete = prefs.getBool('onboarding_complete') ?? false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _onboardingComplete = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          if (state.role == 'guard') {
            return const GuardHomeScreen();
          }
          return const HomeScreen();
        }

        if (_onboardingComplete == null || state is AuthInitial) {
          return const _SplashScreen();
        }

        if (!_onboardingComplete!) {
          return const OnboardingScreen();
        }
        return const LoginScreen();
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 100,
              width: 100,
              child: Image.asset(
                'assets/images/icon.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 24),
            Hero(
              tag: 'app_logo_text',
              child: Material(
                color: Colors.transparent,
                child: Text(
                  'R A K N A',
                  style: GoogleFonts.montserrat(
                    fontSize: 42,
                    fontWeight: FontWeight.w200,
                    letterSpacing: 15.0,
                    color: cs.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: cs.primary,
                strokeWidth: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
