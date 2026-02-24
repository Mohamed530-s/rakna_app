import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthCubit() : super(AuthInitial());

  void reset() {
    emit(AuthInitial());
  }

  Future<void> checkAuthStatus() async {
    try {
      final user = await _auth.authStateChanges().first.timeout(
            const Duration(seconds: 5),
            onTimeout: () => _auth.currentUser,
          );

      if (user != null) {
        await _emitUserRole(user);
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        await _emitUserRole(credential.user!);
      } else {
        emit(const AuthError('Login failed.'));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Authentication error'));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> register(String email, String password, String name) async {
    emit(AuthLoading());
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'email': email,
          'name': name,
          'role': 'user',
          'createdAt': FieldValue.serverTimestamp(),
        });

        await user.updateDisplayName(name);
        await _auth.signOut();
        emit(SignupSuccess());
      } else {
        emit(const AuthError('Registration failed.'));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Registration error'));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> refreshUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.reload();
      final refreshed = _auth.currentUser;
      if (refreshed != null) {
        await _emitUserRole(refreshed);
      }
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Logout failed: $e'));
    }
  }

  Future<void> _emitUserRole(User user) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get()
          .timeout(const Duration(seconds: 3));

      if (doc.exists) {
        final data = doc.data();
        final role = data?['role'] as String? ?? 'user';
        emit(AuthAuthenticated(user, role: role));
      } else {
        emit(AuthAuthenticated(user, role: 'user'));
      }
    } catch (e) {
      emit(AuthAuthenticated(user, role: 'user'));
    }
  }
}
