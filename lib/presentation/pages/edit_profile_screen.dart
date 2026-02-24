import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rakna_app/core/app_colors.dart';
import 'package:rakna_app/presentation/manager/auth_cubit.dart';
import 'package:rakna_app/presentation/manager/auth_state.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  File? _selectedImage;

  String? _currentPhotoUrl;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final state = context.read<AuthCubit>().state;
    String name = "User";
    String email = "user@example.com";
    String phone = "";

    if (state is AuthAuthenticated) {
      name = state.user.displayName ?? "User";
      email = state.user.email ?? "user@example.com";
      _currentPhotoUrl = state.user.photoURL;
    }

    _loadPhoneFromFirestore();

    _nameController = TextEditingController(text: name);
    _phoneController = TextEditingController(text: phone);
    _emailController = TextEditingController(text: email);
  }

  Future<void> _loadPhoneFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists && mounted) {
        final data = doc.data();
        setState(() {
          _phoneController.text = data?['phone'] as String? ?? '';
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    HapticFeedback.lightImpact();

    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 75,
    );

    if (pickedFile != null && mounted) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty) {
      _showErrorSnackBar('Name cannot be empty.');
      return;
    }

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      String? photoUrl = _currentPhotoUrl;

      if (_selectedImage != null) {
        photoUrl = await _uploadProfilePhoto(user.uid, _selectedImage!);
      }

      await user.updateDisplayName(name);
      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': name,
        'phone': phone,
        if (photoUrl != null) 'photoUrl': photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        await context.read<AuthCubit>().refreshUser();
      }

      if (mounted) {
        _showSuccessSnackBar('Profile updated successfully');
        Navigator.pop(context);
      }
    } on FirebaseException catch (e) {
      if (mounted) _showErrorSnackBar(e.message ?? 'Firebase error');
    } catch (e) {
      if (mounted) _showErrorSnackBar(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<String> _uploadProfilePhoto(String uid, File imageFile) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('profile_photos')
        .child('$uid.jpg');

    final uploadTask = ref.putFile(
      imageFile,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  void _showSuccessSnackBar(String message) {
    final cs = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline,
                color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: cs.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.error.withValues(alpha: 0.95),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Edit Profile",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: cs.onSurface),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: cs.primary, width: 2),
                    boxShadow: isDark
                        ? [
                            BoxShadow(
                              color: cs.primary.withValues(alpha: 0.3),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ]
                        : [],
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor:
                        isDark ? Colors.grey[800] : Colors.grey[200],
                    backgroundImage: _resolveAvatarImage(),
                    child: _resolveAvatarImage() == null
                        ? Icon(Icons.person,
                            size: 50,
                            color: isDark
                                ? Colors.white
                                : AppColors.lightTextSecondary)
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: cs.primary,
                        shape: BoxShape.circle,
                        boxShadow: isDark
                            ? [
                                BoxShadow(
                                  color: cs.primary.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                ),
                              ],
                      ),
                      child:
                          Icon(Icons.camera_alt, color: cs.onPrimary, size: 18),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            _buildField(
              context,
              controller: _nameController,
              label: 'Full Name',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 20),
            _buildField(
              context,
              controller: _phoneController,
              label: 'Phone Number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            _buildField(
              context,
              controller: _emailController,
              label: 'Email',
              icon: Icons.alternate_email,
              enabled: false,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _isLoading
                      ? SizedBox(
                          key: const ValueKey('loading'),
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: cs.onPrimary,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'SAVE CHANGES',
                          key: const ValueKey('text'),
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            letterSpacing: 1.5,
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

  ImageProvider? _resolveAvatarImage() {
    if (_selectedImage != null) {
      return FileImage(_selectedImage!);
    }
    if (_currentPhotoUrl != null && _currentPhotoUrl!.isNotEmpty) {
      return NetworkImage(_currentPhotoUrl!);
    }
    return null;
  }

  Widget _buildField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isDark
                ? Colors.white.withValues(alpha: 0.04)
                : Colors.white.withValues(alpha: 0.6),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : AppColors.lightBorder,
              width: 0.5,
            ),
          ),
          child: TextField(
            controller: controller,
            enabled: enabled,
            keyboardType: keyboardType,
            style: GoogleFonts.inter(
              color:
                  enabled ? cs.onSurface : cs.onSurface.withValues(alpha: 0.5),
              fontSize: 15,
            ),
            cursorColor: cs.primary,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: GoogleFonts.inter(
                color: cs.secondary,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Icon(icon, color: cs.secondary, size: 20),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            ),
          ),
        ),
      ),
    );
  }
}
