import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupISMPage extends StatefulWidget {
  const SignupISMPage({super.key});

  @override
  State<SignupISMPage> createState() => _SignupISMPageState();
}

class _SignupISMPageState extends State<SignupISMPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();

  bool loading = false;
  bool obscure = true;

  Future<void> signup() async {
    setState(() => loading = true);

    try {
      UserCredential cred =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text.trim(),
      );

      final uid = cred.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'role': 'ism',
        'email': _email.text.trim(),
      });

      await FirebaseFirestore.instance.collection('isms').doc(uid).set({
        'name': _name.text.trim(),
        'email': _email.text.trim(),
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ISM Signup")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _name, decoration: const InputDecoration(labelText: "Name")),
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
                    child: const Text("Create ISM Account"),
                  ),
          ],
        ),
      ),
    );
  }
}
