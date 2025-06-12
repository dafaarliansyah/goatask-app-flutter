import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:todo_app_with_firebase/providers/todo_provider.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get user => _user;

  AuthProvider() {
    _init();
  }

  void _init() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      print('authStateChanges: _user = $_user');
      notifyListeners();
    });
  }

  // Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // Simpan data user ke Firestore jika pertama kali login
      await _saveUserData(
        userCredential.user!.uid,
        userCredential.user!.displayName ?? 'User',
        userCredential.user!.email ?? '',
        userCredential.user!.photoURL,
      );

      _user = userCredential.user;
      print('signInWithGoogle: _user = $_user');
      notifyListeners();
      return _user;
    } on FirebaseAuthException catch (e) {
      print('Error signing in with Google: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }

  // Register with email and password
  Future<User?> registerWithEmail(
    String email,
    String password,
    String name,
  ) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await userCredential.user!.updateDisplayName(name);

      // Simpan data user ke Firestore
      await _saveUserData(
        userCredential.user!.uid,
        name,
        email,
        null, // Tidak ada foto untuk email/password
      );

      _user = userCredential.user;
      print('registerWithEmail: _user = $_user');
      notifyListeners();
      return _user;
    } on FirebaseAuthException catch (e) {
      print('Error registering with email: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      print('Error registering with email: $e');
      return null;
    }
  }

  // Login with email and password
  Future<User?> loginWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _user = userCredential.user;
      print('loginWithEmail: _user = $_user');
      notifyListeners();
      return _user;
    } on FirebaseAuthException catch (e) {
      print('Error logging in with email: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      print('Error logging in with email: $e');
      return null;
    }
  }

  // Simpan data user ke Firestore
  Future<void> _saveUserData(
    String userId,
    String name,
    String email,
    String? photoUrl,
  ) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'name': name,
        'email': email,
        'photoUrl': photoUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error saving user data to Firestore: $e');
    }
  }

  Future<void> signOut(BuildContext context) async {
    print('signOut() dipanggil');
    await GoogleSignIn().signOut();
    await _auth.signOut();
    _user = null;
    print('_user setelah signOut: $_user');
    Provider.of<TodoProvider>(context, listen: false).clearTodos();
    notifyListeners();
  }
}