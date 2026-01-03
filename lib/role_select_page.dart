// import 'package:flutter/material.dart';
// import 'login_student_page.dart';
// import 'login_teacher_page.dart';
// import 'login_ism_page.dart';

// class RoleSelectPage extends StatelessWidget {
//   const RoleSelectPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F7FB),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0.5,
//         centerTitle: true,
//         iconTheme: const IconThemeData(color: Colors.black87),
//         title: const Text(
//           "Who are you?",
//           style: TextStyle(
//             fontWeight: FontWeight.w600,
//             color: Colors.black87,
//           ),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               "Continue as",
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.black87,
//               ),
//             ),
//             const SizedBox(height: 20),

//             _roleCard(
//               context,
//               icon: Icons.school_outlined,
//               label: "Student",
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => const LoginStudentPage(),
//                   ),
//                 );
//               },
//             ),

//             _roleCard(
//               context,
//               icon: Icons.person_outline,
//               label: "Teacher",
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => const LoginTeacherPage(),
//                   ),
//                 );
//               },
//             ),

//             _roleCard(
//               context,
//               icon: Icons.admin_panel_settings_outlined,
//               label: "ISM",
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => const LoginISMPage(),
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _roleCard(
//     BuildContext context, {
//     required IconData icon,
//     required String label,
//     required VoidCallback onTap,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 14),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(14),
//         onTap: onTap,
//         child: Container(
//           width: double.infinity,
//           padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(14),
//             border: Border.all(
//               color: const Color(0xFFE2E8F0),
//             ),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.03),
//                 blurRadius: 6,
//                 offset: const Offset(0, 3),
//               ),
//             ],
//           ),
//           child: Row(
//             children: [
//               Icon(icon, size: 26, color: const Color(0xFF4F6EF7)),
//               const SizedBox(width: 16),
//               Text(
//                 label,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.black87,
//                 ),
//               ),
//               const Spacer(),
//               const Icon(
//                 Icons.arrow_forward_ios,
//                 size: 14,
//                 color: Colors.grey,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_student_page.dart';
import 'login_teacher_page.dart';
import 'login_ism_page.dart';

class RoleSelectPage extends StatelessWidget {
  const RoleSelectPage({super.key});

  Future<void> _selectRole(
    BuildContext context,
    String role,
    Widget page,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_role', role);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          "Who are you?",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Continue as",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),

            _roleCard(
              context,
              icon: Icons.school_outlined,
              label: "Student",
              onTap: () => _selectRole(
                context,
                'student',
                const LoginStudentPage(),
              ),
            ),

            _roleCard(
              context,
              icon: Icons.person_outline,
              label: "Teacher",
              onTap: () => _selectRole(
                context,
                'teacher',
                const LoginTeacherPage(),
              ),
            ),

            _roleCard(
              context,
              icon: Icons.admin_panel_settings_outlined,
              label: "ISM",
              onTap: () => _selectRole(
                context,
                'ism',
                const LoginISMPage(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roleCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, size: 26, color: const Color(0xFF4F6EF7)),
              const SizedBox(width: 16),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
