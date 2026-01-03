import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  Future<void> signup() async {
    setState(() => loading = true);

    try {
      // 1. Create Auth user
      UserCredential cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
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

      // ❗ DO NOT NAVIGATE
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() => loading = false);
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
                    onPressed: signup,
                    child: const Text("Create Student Account"),
                  ),
          ],
        ),
      ),
    );
  }
}
