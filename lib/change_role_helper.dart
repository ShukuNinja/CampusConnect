import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'role_select_page.dart';

Future<void> changeRole(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('selected_role');

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => const RoleSelectPage()),
    (route) => false,
  );
}
