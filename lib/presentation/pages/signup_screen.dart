import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rakna_app/presentation/manager/auth_cubit.dart';
import 'package:rakna_app/presentation/manager/auth_state.dart';
import 'package:rakna_app/presentation/widgets/cyberpunk_background.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  late AnimationController _logoController;
  late Animation<double> _logoScale;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.15, end: 0.40).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
    _logoScale = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    if (mounted) {
      context.read<AuthCubit>().reset();
    }
    _glowController.dispose();
    _logoController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSignup() {
    FocusScope.of(context).unfocus();
    HapticFeedback.mediumImpact();
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
      context.read<AuthCubit>().register(email, password, name);
    } else {
      _showGlassSnackBar('Please fill all fields', isError: true);
    }
  }

  void _showGlassSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError
            ? const Color(0xFF8B1A1A).withValues(alpha: 0.95)
            : const Color(0xFF0A0A0A).withValues(alpha: 0.95),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(20),
        elevation: 0,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: cs.surface,
      body: CyberpunkBackground(
        child: SafeArea(
          child: BlocListener<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is AuthError) {
                String msg = state.message;
                if (msg.contains("email-already-in-use")) {
                  msg = "This email is already registered.";
                } else if (msg.contains("weak-password")) {
                  msg = "Password is too weak. Use 6+ characters.";
                } else if (msg.contains("network-request-failed")) {
                  msg = "Network unavailable. Check connection.";
                }
                _showGlassSnackBar(msg, isError: true);
              }
              if (state is SignupSuccess) {
                _showGlassSnackBar(
                    'Identity forged successfully. Proceed to login.');
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (!context.mounted) return;
                  Navigator.pop(context);
                });
              }
            },
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 36.0),
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 60),
                          Center(
                            child: AnimatedBuilder(
                              animation: _logoController,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _logoScale.value,
                                  child: SizedBox(
                                    height: 100,
                                    width: 100,
                                    child: Image.asset(
                                      'assets/images/icon.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          Hero(
                            tag: 'app_logo_text',
                            child: Material(
                              color: Colors.transparent,
                              child: Text(
                                'R A K N A',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.montserrat(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w200,
                                  letterSpacing: 12.0,
                                  color: cs.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(40),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 28, vertical: 32),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.03),
                                  borderRadius: BorderRadius.circular(40),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.10),
                                    width: 0.5,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    _buildUnderlineField(
                                      controller: _nameController,
                                      label: 'Full Name',
                                      icon: Icons.person_outline,
                                    ),
                                    const SizedBox(height: 24),
                                    _buildUnderlineField(
                                      controller: _emailController,
                                      label: 'Email',
                                      icon: Icons.alternate_email,
                                      keyboardType: TextInputType.emailAddress,
                                    ),
                                    const SizedBox(height: 24),
                                    _buildUnderlineField(
                                      controller: _passwordController,
                                      label: 'Password',
                                      icon: Icons.lock_outline,
                                      isPassword: true,
                                    ),
                                    const SizedBox(height: 32),
                                    BlocBuilder<AuthCubit, AuthState>(
                                      builder: (context, state) {
                                        return _buildGhostButton(
                                          text: 'CREATE IDENTITY',
                                          isLoading: state is AuthLoading,
                                          onTap: _onSignup,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 40),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Already verified?  ",
                                  style: GoogleFonts.inter(
                                    color: cs.onSurface.withValues(alpha: 0.4),
                                    fontSize: 14,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    "Access Portal",
                                    style: GoogleFonts.inter(
                                      color: cs.primary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      decoration: TextDecoration.underline,
                                      decorationColor: cs.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUnderlineField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final cs = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(
        color: cs.onSurface,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      cursorColor: cs.primary,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(
          color: cs.onSurface.withValues(alpha: 0.4),
          fontSize: 14,
          fontWeight: FontWeight.w300,
        ),
        prefixIcon:
            Icon(icon, color: cs.onSurface.withValues(alpha: 0.35), size: 20),
        suffixIcon: isPassword
            ? GestureDetector(
                onTap: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                child: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: cs.onSurface.withValues(alpha: 0.3),
                  size: 20,
                ),
              )
            : null,
        border: InputBorder.none,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
              color: Colors.white.withValues(alpha: 0.15), width: 0.5),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: cs.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Widget _buildGhostButton({
    required String text,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: cs.primary.withValues(alpha: _glowAnimation.value),
                blurRadius: 50,
                spreadRadius: 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: InkWell(
                onTap: isLoading ? null : onTap,
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: cs.primary.withValues(alpha: 0.5),
                      width: 1,
                    ),
                    color: cs.primary.withValues(alpha: 0.08),
                  ),
                  child: isLoading
                      ? SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: cs.primary,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          text,
                          style: GoogleFonts.inter(
                            color: cs.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.0,
                          ),
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
