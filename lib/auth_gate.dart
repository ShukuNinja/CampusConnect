import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'role_select_page.dart';
import 'role_router.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // ⏳ Firebase checking session
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ✅ Logged in → route by role
        if (snapshot.hasData) {
          return const RoleRouter();
        }

        // ❌ Not logged in → select role
        return const RoleSelectPage();
      },
    );
  }
}
