import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/widgets.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  var currentUser;

  AuthService({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  })  : _auth = firebaseAuth,
        _firestore = firestore;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: ${e.toString()}');
    }
  }

  Future<UserModel> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      if (!EmailValidator.validate(email)) {
        throw Exception('Invalid email format');
      }

      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      
      final doc = await _firestore.collection('users').doc(credential.user!.uid).get();
      return UserModel.fromFirestore(doc);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  Future<UserModel> registerWithEmailAndPassword(
    String email,
    String password, {
    String? name,
  }) async {
    try {
      if (!EmailValidator.validate(email)) {
        throw Exception('Invalid email format');
      }

      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = UserModel(
        id: credential.user!.uid,
        email: email.trim(),
        name: name?.trim() ?? email.split('@')[0],
        isGuest: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(user.id).set(user.toMap());
      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

Future<UserModel> createGuestUser() async {
  try {
    // Создаем уникальный ID для гостя
    final guestId = 'guest_${DateTime.now().millisecondsSinceEpoch}';

    // Создаем объект UserModel для гостя
    final guestUser = UserModel(
      id: guestId,
      email: 'guest@example.com',
      name: 'Guest',
      isGuest: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      photoUrl: null,
      favoriteBooks: [],
      readingProgress: {},
    );

    // Сохраняем гостя в Firestore
    await _firestore.collection('users').doc(guestUser.id).set(guestUser.toMap());

    return guestUser;
  } catch (e) {
    debugPrint('Error creating guest user: $e');
    throw Exception('Failed to create guest account');
  }
}

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Logout failed: ${e.toString()}');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      if (!EmailValidator.validate(email)) {
        throw Exception('Invalid email format');
      }
      await _auth.sendPasswordResetEmail(email: email.trim());
    } catch (e) {
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }

  Future<UserModel> updateProfile({
    required String userId,
    String? name,
    String? photoUrl,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (name != null) updates['name'] = name.trim();
      if (photoUrl != null) updates['photoUrl'] = photoUrl.trim();

      await _firestore.collection('users').doc(userId).update(updates);
      final updatedDoc = await _firestore.collection('users').doc(userId).get();
      return UserModel.fromFirestore(updatedDoc);
    } catch (e) {
      throw Exception('Profile update failed: ${e.toString()}');
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      throw Exception('Email verification failed: ${e.toString()}');
    }
  }

  Future<void> reloadUser() async {
    try {
      await _auth.currentUser?.reload();
    } catch (e) {
      throw Exception('User reload failed: ${e.toString()}');
    }
  }

  Exception _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('User not found');
      case 'wrong-password':
        return Exception('Wrong password');
      case 'email-already-in-use':
        return Exception('Email already in use');
      case 'invalid-email':
        return Exception('Invalid email format');
      case 'weak-password':
        return Exception('Weak password');
      case 'user-disabled':
        return Exception('Account disabled');
      case 'operation-not-allowed':
        return Exception('Operation not allowed');
      case 'too-many-requests':
        return Exception('Too many requests. Try again later');
      default:
        return Exception('Error: ${e.message}');
    }
  }
}