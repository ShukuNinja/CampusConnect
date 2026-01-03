import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'role_select_page.dart';
import 'login_student_page.dart';
import 'login_teacher_page.dart';
import 'login_ism_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final prefs = await SharedPreferences.getInstance();
  final role = prefs.getString('selected_role');

  runApp(CampusConnectApp(initialRole: role));
}

class CampusConnectApp extends StatelessWidget {
  final String? initialRole;

  const CampusConnectApp({super.key, this.initialRole});

  @override
  Widget build(BuildContext context) {
    Widget home;

    if (initialRole == null) {
      home = const RoleSelectPage();
    } else {
      switch (initialRole) {
        case 'student':
          home = const LoginStudentPage();
          break;
        case 'teacher':
          home = const LoginTeacherPage();
          break;
        case 'ism':
          home = const LoginISMPage();
          break;
        default:
          home = const RoleSelectPage();
      }
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: home,
    );
  }
}

