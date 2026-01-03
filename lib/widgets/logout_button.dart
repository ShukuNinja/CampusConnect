import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../role_select_page.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.logout),
      onPressed: () async {
        await FirebaseAuth.instance.signOut();

        if (!context.mounted) return;

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const RoleSelectPage(),
          ),
          (route) => false,
        );
      },
    );
  }
}
