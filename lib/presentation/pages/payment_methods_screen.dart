import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rakna_app/core/app_colors.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  CollectionReference<Map<String, dynamic>>? _paymentMethodsRef() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('payment_methods');
  }

  Future<void> _addCard({
    required String last4,
    required String holder,
    required String expiry,
    required String brand,
  }) async {
    final ref = _paymentMethodsRef();
    if (ref == null) return;

    final existing = await ref.get();
    for (final doc in existing.docs) {
      await doc.reference.delete();
    }

    await ref.add({
      'last4': last4,
      'holder': holder,
      'expiry': expiry,
      'brand': brand,
      'token': 'tok_mock_${DateTime.now().millisecondsSinceEpoch}',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _removeCard(String docId) async {
    final ref = _paymentMethodsRef();
    if (ref == null) return;
    await ref.doc(docId).delete();
  }

  void _showAddCardSheet() {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final numberCtrl = TextEditingController();
    final holderCtrl = TextEditingController();
    final expiryCtrl = TextEditingController();
    final cvvCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
                color: isDark
                    ? const Color(0xFF1A1A1A).withValues(alpha: 0.96)
                    : Colors.white.withValues(alpha: 0.98),
                border: Border(
                  top: BorderSide(
                      color: cs.primary.withValues(alpha: 0.25), width: 1),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: cs.onSurface.withValues(alpha: 0.12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'ADD NEW CARD',
                      style: GoogleFonts.inter(
                        color: cs.secondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.8,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildGlassInput(
                      numberCtrl,
                      'XXXX XXXX XXXX XXXX',
                      Icons.credit_card,
                      isDark,
                      cs,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(16),
                        _CardNumberFormatter(),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildGlassInput(holderCtrl, 'Cardholder Name',
                        Icons.person_outline, isDark, cs),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _buildGlassInput(
                            expiryCtrl,
                            'MM/YY',
                            Icons.calendar_today_outlined,
                            isDark,
                            cs,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                              _ExpiryDateFormatter(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildGlassInput(
                            cvvCtrl,
                            'CVV',
                            Icons.lock_outline,
                            isDark,
                            cs,
                            keyboardType: TextInputType.number,
                            obscure: true,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(3),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () async {
                          HapticFeedback.mediumImpact();

                          final rawNumber =
                              numberCtrl.text.replaceAll(' ', '').trim();
                          final holder = holderCtrl.text.trim();
                          final expiry = expiryCtrl.text.trim();
                          final cvv = cvvCtrl.text.trim();

                          String? error;
                          if (rawNumber.length != 16) {
                            error = 'Card number must be exactly 16 digits';
                          } else if (holder.isEmpty) {
                            error = 'Cardholder name is required';
                          } else if (!RegExp(r'^\d{2}/\d{2}$')
                              .hasMatch(expiry)) {
                            error = 'Expiry must be MM/YY format';
                          } else if (cvv.length != 3) {
                            error = 'CVV must be exactly 3 digits';
                          }

                          if (error != null) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(
                                content: Text(error,
                                    style:
                                        GoogleFonts.inter(color: Colors.white)),
                                backgroundColor:
                                    AppColors.error.withValues(alpha: 0.95),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                                margin: const EdgeInsets.all(20),
                              ),
                            );
                            return;
                          }

                          final last4 =
                              rawNumber.substring(rawNumber.length - 4);
                          final brand = rawNumber.startsWith('4')
                              ? 'Visa'
                              : rawNumber.startsWith('5')
                                  ? 'Mastercard'
                                  : 'Card';

                          await _addCard(
                            last4: last4,
                            holder: holder,
                            expiry: expiry,
                            brand: brand,
                          );

                          if (!ctx.mounted) return;
                          Navigator.pop(ctx);

                          if (!mounted) return;
                          _showGlassSnackBar('$brand ending in $last4 saved',
                              isError: false);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cs.primary,
                          foregroundColor: cs.onPrimary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: Text(
                          'SAVE CARD',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassInput(
    TextEditingController ctrl,
    String hint,
    IconData icon,
    bool isDark,
    ColorScheme cs, {
    TextInputType? keyboardType,
    int? maxLength,
    bool obscure = false,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      maxLength: maxLength,
      obscureText: obscure,
      inputFormatters: inputFormatters,
      style: GoogleFonts.inter(
        color: cs.onSurface,
        fontSize: 15,
        letterSpacing: keyboardType == TextInputType.number ? 1.5 : 0,
      ),
      cursorColor: cs.primary,
      decoration: InputDecoration(
        counterText: '',
        hintText: hint,
        hintStyle: GoogleFonts.inter(
          color: cs.onSurface.withValues(alpha: 0.3),
          fontSize: 15,
        ),
        prefixIcon: Icon(icon, color: cs.secondary, size: 20),
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.grey.withValues(alpha: 0.06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : AppColors.lightBorder,
            width: 0.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : AppColors.lightBorder,
            width: 0.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.primary, width: 1),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  void _showGlassSnackBar(String message, {required bool isError}) {
    if (!mounted) return;
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
              child: Text(message,
                  style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400)),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final ref = _paymentMethodsRef();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: cs.onSurface, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Payment Methods',
          style: GoogleFonts.inter(
            color: cs.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: ref == null
          ? Center(
              child: Text('Please sign in',
                  style: GoogleFonts.inter(color: cs.secondary)))
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: ref.orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];

                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      if (docs.isNotEmpty) ...[
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                _buildPremiumCard(docs.first, isDark, cs),
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: () async {
                                      HapticFeedback.lightImpact();
                                      await _removeCard(docs.first.id);
                                      if (!mounted) return;
                                      _showGlassSnackBar('Card removed',
                                          isError: false);
                                    },
                                    icon: Icon(Icons.delete_outline,
                                        color: AppColors.error, size: 18),
                                    label: Text(
                                      'Remove Card',
                                      style: GoogleFonts.inter(
                                        color: AppColors.error,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                          color: AppColors.error
                                              .withValues(alpha: 0.3)),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14)),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ] else ...[
                        Expanded(
                          child: Center(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: cs.primary.withValues(alpha: 0.08),
                                      boxShadow: isDark
                                          ? [
                                              BoxShadow(
                                                color: cs.primary
                                                    .withValues(alpha: 0.15),
                                                blurRadius: 40,
                                                spreadRadius: 10,
                                              ),
                                            ]
                                          : [],
                                    ),
                                    child: Icon(
                                      Icons.credit_card_off_outlined,
                                      size: 48,
                                      color: cs.primary.withValues(alpha: 0.6),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    'No cards saved',
                                    style: GoogleFonts.inter(
                                      color: cs.onSurface,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Add a Visa or Mastercard\nfor faster checkout',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      color: cs.secondary,
                                      fontSize: 14,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      SafeArea(
                        top: false,
                        child: SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              _showAddCardSheet();
                            },
                            icon: const Icon(Icons.add, size: 20),
                            label: Text(
                              docs.isNotEmpty ? 'REPLACE CARD' : 'ADD NEW CARD',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                letterSpacing: 1.5,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: cs.primary,
                              foregroundColor: cs.onPrimary,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildPremiumCard(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    bool isDark,
    ColorScheme cs,
  ) {
    final data = doc.data();
    final brand = (data['brand'] as String?) ?? 'Visa';
    final last4 = (data['last4'] as String?) ?? '••••';
    final holder = (data['holder'] as String?) ?? 'CARDHOLDER';
    final expiry = (data['expiry'] as String?) ?? '••/••';
    final isVisa = brand.toLowerCase() == 'visa';

    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: 210,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isVisa
                  ? [
                      const Color(0xFF1A1F3D),
                      const Color(0xFF2A2F5D),
                      const Color(0xFF1A1F3D),
                    ]
                  : [
                      const Color(0xFF2D1B3D),
                      const Color(0xFF4A2D5D),
                      const Color(0xFF2D1B3D),
                    ],
            ),
            boxShadow: [
              BoxShadow(
                color:
                    (isVisa ? const Color(0xFF3F51B5) : const Color(0xFFE040FB))
                        .withValues(alpha: 0.25),
                blurRadius: 30,
                spreadRadius: 2,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              children: [
                Positioned(
                  right: -30,
                  top: -30,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.04),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: -40,
                  bottom: -40,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.03),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            brand.toUpperCase(),
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 4,
                            ),
                          ),
                          Icon(Icons.contactless_outlined,
                              color: Colors.white.withValues(alpha: 0.5),
                              size: 28),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: 45,
                        height: 32,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFD4AF37),
                              Color(0xFFF5D060),
                              Color(0xFFD4AF37),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD4AF37)
                                  .withValues(alpha: 0.3),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(Icons.memory,
                              size: 18,
                              color: const Color(0xFF8B7330)
                                  .withValues(alpha: 0.6)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '•••• •••• •••• $last4',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 3,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CARD HOLDER',
                                style: GoogleFonts.inter(
                                  color: Colors.white.withValues(alpha: 0.35),
                                  fontSize: 8,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                holder.toUpperCase(),
                                style: GoogleFonts.inter(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'EXPIRES',
                                style: GoogleFonts.inter(
                                  color: Colors.white.withValues(alpha: 0.35),
                                  fontSize: 8,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                expiry,
                                style: GoogleFonts.inter(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();

    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();

    for (int i = 0; i < digits.length; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(digits[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
