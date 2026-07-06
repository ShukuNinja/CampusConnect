import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'otp_verification_page.dart';
import 'role_router.dart';
import 'services/email_otp_service.dart';

class SignupStudentPage extends StatefulWidget {
  const SignupStudentPage({super.key});

  @override
  State<SignupStudentPage> createState() => _SignupStudentPageState();
}

class _SignupStudentPageState extends State<SignupStudentPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  final _regno = TextEditingController();
  final _dept = TextEditingController();
  final _year = TextEditingController();

  bool loading = false;
  bool obscure = true;

  void _snack(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red : null,
      ),
    );
  }

  String? _validate() {
    if (_name.text.trim().isEmpty) return "Please enter your name";
    if (!_email.text.trim().contains('@')) return "Please enter a valid email";
    if (_password.text.trim().length < 6) {
      return "Password must be at least 6 characters";
    }
    return null;
  }

  /// Step 1 — validate, email an OTP, then open the verification screen.
  /// The account is only created once the OTP is confirmed.
  Future<void> startSignup() async {
    final error = _validate();
    if (error != null) {
      _snack(error, error: true);
      return;
    }

    setState(() => loading = true);
    try {
      await EmailOtpService.instance.sendOtp(_email.text.trim());
    } catch (e) {
      _snack(e.toString(), error: true);
      setState(() => loading = false);
      return;
    }
    setState(() => loading = false);

    if (!mounted) return;
    final verified = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => OtpVerificationPage(
          email: _email.text.trim(),
          onVerified: _createAccount,
        ),
      ),
    );

    if (verified == true && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const RoleRouter()),
        (route) => false,
      );
    }
  }

  /// Step 2 — runs only after the emailed OTP is verified.
  Future<void> _createAccount() async {
    // 1. Create Auth user
    final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: _email.text.trim(),
      password: _password.text.trim(),
    );

    final uid = cred.user!.uid;

    // 2. Role routing doc
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'role': 'student',
      'email': _email.text.trim(),
    });

    // 3. Student profile
    await FirebaseFirestore.instance.collection('students').doc(uid).set({
      'name': _name.text.trim(),
      'regno': _regno.text.trim(),
      'dept': _dept.text.trim(),
      'passingYear': _year.text.trim(),
      'email': _email.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Student Signup")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _name, decoration: const InputDecoration(labelText: "Name")),
            TextField(controller: _regno, decoration: const InputDecoration(labelText: "Register Number")),
            TextField(controller: _dept, decoration: const InputDecoration(labelText: "Department")),
            TextField(controller: _year, decoration: const InputDecoration(labelText: "Passing Year")),
            TextField(controller: _email, decoration: const InputDecoration(labelText: "Email")),
            TextField(
              controller: _password,
              obscureText: obscure,
              decoration: InputDecoration(
                labelText: "Password",
                suffixIcon: IconButton(
                  icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => obscure = !obscure),
                ),
              ),
            ),
            const SizedBox(height: 20),
            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: startSignup,
                    child: const Text("Create Student Account"),
                  ),
          ],
        ),
      ),
    );
  }
}
