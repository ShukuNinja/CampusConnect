import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'student_home.dart';
import 'teacher_home.dart';
import 'ism_home.dart';

class RoleRouter extends StatelessWidget {
  const RoleRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("No user logged in")),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        // 🔄 Always wait until Firestore responds
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ❌ Auth exists but Firestore role missing
        if (!snapshot.data!.exists) {
          return const Scaffold(
            body: Center(
              child: Text(
                "Setting up your account...\nPlease wait",
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final role = data['role'];

        switch (role) {
          case 'student':
            return const StudentHome();
          case 'teacher':
            return const TeacherHome();
          case 'ism':
            return const ISMHome();
          default:
            return const Scaffold(
              body: Center(child: Text("Invalid role")),
            );
        }
      },
    );
  }
}
