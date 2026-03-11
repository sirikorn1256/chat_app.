import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:chat_app/widgets/user_image_picker.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  var _isLogin = true;
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _enteredUsername = '';
  File? _selectedImage;
  var _isAuthenticating = false;

  //Google Login
  Future<void> _googleLogin() async {
    try {
      setState(() { _isAuthenticating = true; });
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() { _isAuthenticating = false; });
        return;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken, idToken: googleAuth.idToken,
      );
      final userCredentials = await _firebase.signInWithCredential(credential);
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredentials.user!.uid)
          .get();
      if (!userDoc.exists) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentials.user!.uid)
            .set({
          'username': googleUser.displayName ?? 'Google User',
          'email': googleUser.email,
          'image_url': googleUser.photoUrl ??
              'https://ui-avatars.com/api/?name=${googleUser.displayName}',
        });
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Login Error: $error')),
      );
    } finally {
      if (mounted) setState(() { _isAuthenticating = false; });
    }
  }

  //GitHub Login
  Future<void> _githubLogin() async {
    try {
      setState(() { _isAuthenticating = true; });

      final githubProvider = GithubAuthProvider();
      githubProvider.addScope('read:user');
      githubProvider.addScope('user:email');

      final userCredentials = await _firebase.signInWithProvider(githubProvider);

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredentials.user!.uid)
          .get();

      if (!userDoc.exists) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentials.user!.uid)
            .set({
          'username': userCredentials.user!.displayName ?? 'GitHub User',
          'email': userCredentials.user!.email ?? '',
          'image_url': userCredentials.user!.photoURL ??
              'https://ui-avatars.com/api/?name=${userCredentials.user!.displayName}',
        });
      }
    } on FirebaseAuthException catch (e) {
      String message = 'GitHub Login Error';
      if (e.code == 'account-exists-with-different-credential') {
        message = 'อีเมลนี้มีบัญชีอยู่แล้ว\nกรุณา Login ด้วย Google หรือ Email/Password แทนครับ';
      } else {
        message = e.message ?? message;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.orange.shade700),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('GitHub Login Error: $error')),
        );
      }
    } finally {
      if (mounted) setState(() { _isAuthenticating = false; });
    }
  }

  //Email/Password
  void _submit() async {
    final isValid = _form.currentState!.validate();
    if (!isValid || (!_isLogin && _selectedImage == null)) return;
    _form.currentState!.save();

    try {
      setState(() { _isAuthenticating = true; });
      if (_isLogin) {
        await _firebase.signInWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
      } else {
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
        final imageBytes = await _selectedImage!.readAsBytes();
        final base64Image = base64Encode(imageBytes);
        final imageUrl = 'data:image/jpeg;base64,$base64Image';

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentials.user!.uid)
            .set({
          'username': _enteredUsername,
          'email': _enteredEmail,
          'image_url': imageUrl,
        });
      }
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message ?? 'Auth failed.')),
      );
      setState(() { _isAuthenticating = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    const actionGreen = Color(0xFF48825F);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F4),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 20, top: 40),
                  width: 220,
                  child: Image.asset('assets/images/chat.png'),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 24,
                          offset: const Offset(0, 10))
                    ],
                  ),
                  child: Form(
                    key: _form,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!_isLogin)
                          UserImagePicker(onPickImage: (img) => _selectedImage = img),

                        _buildTextField(
                          label: 'Email Address',
                          icon: Icons.email_outlined,
                          onSave: (val) => _enteredEmail = val!,
                          validator: (val) =>
                              (val == null || !val.contains('@')) ? 'Invalid email' : null,
                          focusColor: actionGreen,
                        ),
                        const SizedBox(height: 10),

                        if (!_isLogin)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _buildTextField(
                              label: 'Username',
                              icon: Icons.person_outline,
                              onSave: (val) => _enteredUsername = val!,
                              validator: (val) =>
                                  (val == null || val.trim().length < 4) ? 'Min 4 chars' : null,
                              focusColor: actionGreen,
                            ),
                          ),

                        _buildTextField(
                          label: 'Password',
                          icon: Icons.lock_outline,
                          isPassword: true,
                          onSave: (val) => _enteredPassword = val!,
                          validator: (val) =>
                              (val == null || val.trim().length < 6) ? 'Min 6 chars' : null,
                          focusColor: actionGreen,
                        ),
                        const SizedBox(height: 20),

                        if (_isAuthenticating)
                          const CircularProgressIndicator(color: actionGreen),
                        if (!_isAuthenticating) ...[
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 104, 173, 132),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                              ),
                              child: Text(
                                _isLogin ? 'Log In' : 'Sign Up',
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),

                          Row(
                            children: [
                              Expanded(
                                  child: Divider(color: Colors.grey.shade300, thickness: 1)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text("OR",
                                    style: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold)),
                              ),
                              Expanded(
                                  child: Divider(color: Colors.grey.shade300, thickness: 1)),
                            ],
                          ),
                          const SizedBox(height: 18),

                          _buildSocialButton(
                            label: 'Continue with Google',
                            icon: Icons.g_mobiledata_rounded,
                            iconSize: 34,
                            onTap: _googleLogin,
                          ),
                          const SizedBox(height: 10),
                          _buildSocialButton(
                            label: 'Continue with GitHub',
                            icon: Icons.code_rounded,
                            iconSize: 22,
                            onTap: _githubLogin, 
                          ),

                          const SizedBox(height: 12),

                          TextButton.icon(
                            onPressed: () => setState(() => _isLogin = !_isLogin),
                            icon: Icon(
                              _isLogin
                                  ? Icons.person_add_alt_1_rounded
                                  : Icons.login_rounded,
                              color: actionGreen,
                              size: 18,
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: actionGreen,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            ),
                            label: Text(
                              _isLogin ? 'Create new account' : 'I already have an account',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    bool isPassword = false,
    required Function(String?) onSave,
    required String? Function(String?) validator,
    required Color focusColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: TextFormField(
        style: const TextStyle(
            color: Color(0xFF1A202C), fontSize: 15, fontWeight: FontWeight.w700),
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: label,
          hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w500,
              fontSize: 14),
          prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: focusColor, width: 1.5)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Colors.redAccent, width: 1)),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
        validator: validator,
        onSaved: onSave,
      ),
    );
  }

  Widget _buildSocialButton({
    required String label,
    required IconData icon,
    required double iconSize,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 46),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
        foregroundColor: const Color(0xFF2D3748),
        backgroundColor: Colors.transparent,
      ),
      icon: Icon(icon, size: iconSize),
      label: Text(label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
    );
  }
}