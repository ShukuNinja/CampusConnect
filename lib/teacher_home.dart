// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// import 'raise_complaint_page.dart';
// import 'my_complaints_page.dart';
// import 'conversations_page.dart';
// import 'student_profile_page.dart';
// import 'create_group_page.dart';
// import 'login_teacher_page.dart';

// class TeacherHome extends StatelessWidget {
//   const TeacherHome({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser;

//     if (user == null) {
//       return const Scaffold(
//         body: Center(child: Text("User not logged in")),
//       );
//     }

//     final uid = user.uid;

//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F7FB),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0.5,
//         centerTitle: true,
//         title: const Text(
//           "Teacher Dashboard",
//           style: TextStyle(
//             fontWeight: FontWeight.w600,
//             color: Colors.black87,
//           ),
//         ),
//         iconTheme: const IconThemeData(color: Colors.black87),
//         actions: [
//           /// ✅ FIXED LOGOUT — THIS IS THE ONLY CHANGE
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: () async {
//               await FirebaseAuth.instance.signOut();

//               if (!context.mounted) return;

//               Navigator.pushAndRemoveUntil(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => const LoginTeacherPage(),
//                 ),
//                 (route) => false,
//               );
//             },
//           ),
//         ],
//       ),
//       body: StreamBuilder<DocumentSnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('teachers')
//             .doc(uid)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (!snapshot.hasData || !snapshot.data!.exists) {
//             return const Center(child: Text("Teacher profile not found"));
//           }

//           final data = snapshot.data!.data() as Map<String, dynamic>;
//           final name = data['name'] ?? '';

//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 /// 👤 PROFILE CARD
//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.all(20),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(
//                       color: const Color(0xFFCBD5E1),
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.03),
//                         blurRadius: 8,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           CircleAvatar(
//                             radius: 26,
//                             backgroundColor: Colors.white,
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 border: Border.all(
//                                   color: const Color(0xFF4F6EF7),
//                                   width: 2,
//                                 ),
//                               ),
//                               alignment: Alignment.center,
//                               child: Text(
//                                 name.isNotEmpty
//                                     ? name[0].toUpperCase()
//                                     : '',
//                                 style: const TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                   color: Color(0xFF4F6EF7),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 16),
//                           Expanded(
//                             child: Text(
//                               name,
//                               style: const TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.black87,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 16),
//                       _profileInfo("Department", data['dept']),
//                       _profileInfo("Availability", data['availability']),

//                       const SizedBox(height: 8),

//                       /// 🔄 AVAILABILITY DROPDOWN (UNCHANGED)
//                       DropdownButton<String>(
//                         value: data['availability'],
//                         items: const [
//                           DropdownMenuItem(
//                             value: 'available',
//                             child: Text('AVAILABLE'),
//                           ),
//                           DropdownMenuItem(
//                             value: 'busy',
//                             child: Text('BUSY'),
//                           ),
//                           DropdownMenuItem(
//                             value: 'offline',
//                             child: Text('OFFLINE'),
//                           ),
//                         ],
//                         onChanged: (newValue) async {
//                           if (newValue == null ||
//                               newValue == data['availability']) return;

//                           await FirebaseFirestore.instance
//                               .collection('teachers')
//                               .doc(uid)
//                               .update({'availability': newValue});
//                         },
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 32),

//                 const Text(
//                   "Quick Actions",
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.black87,
//                   ),
//                 ),

//                 const SizedBox(height: 16),

//                 _actionButton(
//                   context,
//                   icon: Icons.report_problem_outlined,
//                   label: "Raise Complaint",
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => const RaiseComplaintPage(),
//                       ),
//                     );
//                   },
//                 ),

//                 _actionButton(
//                   context,
//                   icon: Icons.assignment_outlined,
//                   label: "My Complaints",
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => const MyComplaintsPage(),
//                       ),
//                     );
//                   },
//                 ),

//                 _actionButton(
//                   context,
//                   icon: Icons.chat_bubble_outline,
//                   label: "Conversations",
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => const ConversationsPage(),
//                       ),
//                     );
//                   },
//                 ),

//                 _actionButton(
//                   context,
//                   icon: Icons.group_outlined,
//                   label: "Create Group",
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => const CreateGroupPage(),
//                       ),
//                     );
//                   },
//                 ),

//                 const SizedBox(height: 24),

//                 const Text(
//                   "Students",
//                   style: TextStyle(
//                     fontWeight: FontWeight.w600,
//                     color: Colors.black87,
//                   ),
//                 ),

//                 const SizedBox(height: 8),

//                 /// 📚 STUDENT LIST (UNCHANGED)
//                 StreamBuilder<QuerySnapshot>(
//                   stream: FirebaseFirestore.instance
//                       .collection('students')
//                       .snapshots(),
//                   builder: (context, snap) {
//                     if (!snap.hasData) {
//                       return const Center(
//                         child: CircularProgressIndicator(),
//                       );
//                     }

//                     final students = snap.data!.docs;

//                     return Column(
//                       children: students.map((doc) {
//                         final s =
//                             doc.data() as Map<String, dynamic>;

//                         return Card(
//                           margin:
//                               const EdgeInsets.symmetric(vertical: 6),
//                           child: ListTile(
//                             title: Text(s['name'] ?? 'Student'),
//                             subtitle: Text(
//                               "${s['regno']} • ${s['dept']}",
//                             ),
//                             trailing: const Icon(
//                               Icons.arrow_forward_ios,
//                               size: 14,
//                             ),
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (_) => StudentProfilePage(
//                                     student: s,
//                                     studentId: doc.id,
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                         );
//                       }).toList(),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _profileInfo(String label, dynamic value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 6),
//       child: Text(
//         "$label: $value",
//         style: const TextStyle(
//           fontSize: 14,
//           color: Colors.black87,
//         ),
//       ),
//     );
//   }

//   Widget _actionButton(
//     BuildContext context, {
//     required IconData icon,
//     required String label,
//     required VoidCallback onTap,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(12),
//         onTap: onTap,
//         child: Container(
//           width: double.infinity,
//           padding:
//               const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(
//               color: const Color(0xFFE2E8F0),
//             ),
//           ),
//           child: Row(
//             children: [
//               Icon(icon, color: const Color(0xFF4F6EF7)),
//               const SizedBox(width: 16),
//               Text(
//                 label,
//                 style: const TextStyle(
//                   fontSize: 15,
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
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_notifications_page.dart';
import 'login_teacher_page.dart';

import 'raise_complaint_page.dart';
import 'my_complaints_page.dart';
import 'conversations_page.dart';
import 'create_group_page.dart';
import 'teacher_students_page.dart'; // ✅ NEW PAGE

class TeacherHome extends StatelessWidget {
  const TeacherHome({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("User not logged in")),
      );
    }

    final uid = user.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          "Teacher Dashboard",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
  IconButton(
    icon: const Icon(Icons.notifications_outlined),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const UserNotificationsPage(),
        ),
      );
    },
  ),
  IconButton(
    icon: const Icon(Icons.logout),
    onPressed: () async {
  await FirebaseAuth.instance.signOut();

  if (!context.mounted) return;

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (_) => const LoginTeacherPage(),
    ),
    (_) => false,
  );
},

  ),
],

      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('teachers')
            .doc(uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Teacher profile not found"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final name = data['name'] ?? '';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 👤 PROFILE CARD
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: Colors.white,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF4F6EF7),
                                  width: 2,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                name.isNotEmpty
                                    ? name[0].toUpperCase()
                                    : '',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4F6EF7),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _profileInfo("Department", data['dept']),
                      _profileInfo("Availability", data['availability']),
                      const SizedBox(height: 8),

                      /// 🔄 AVAILABILITY DROPDOWN (UNCHANGED LOGIC)
                      DropdownButton<String>(
                        value: data['availability'],
                        items: const [
                          DropdownMenuItem(
                            value: 'available',
                            child: Text('AVAILABLE'),
                          ),
                          DropdownMenuItem(
                            value: 'busy',
                            child: Text('BUSY'),
                          ),
                          DropdownMenuItem(
                            value: 'offline',
                            child: Text('OFFLINE'),
                          ),
                        ],
                        onChanged: (newValue) async {
                          if (newValue == null ||
                              newValue == data['availability']) return;

                          await FirebaseFirestore.instance
                              .collection('teachers')
                              .doc(uid)
                              .update({'availability': newValue});
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                const Text(
                  "Quick Actions",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 16),

                _actionButton(
                  context,
                  icon: Icons.report_problem_outlined,
                  label: "Raise Complaint",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RaiseComplaintPage(),
                      ),
                    );
                  },
                ),

                _actionButton(
                  context,
                  icon: Icons.assignment_outlined,
                  label: "My Complaints",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MyComplaintsPage(),
                      ),
                    );
                  },
                ),

                _actionButton(
                  context,
                  icon: Icons.chat_bubble_outline,
                  label: "Conversations",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ConversationsPage(),
                      ),
                    );
                  },
                ),

                _actionButton(
                  context,
                  icon: Icons.group_outlined,
                  label: "Create Group",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreateGroupPage(),
                      ),
                    );
                  },
                ),

                /// ✅ NEW BUTTON
                _actionButton(
                  context,
                  icon: Icons.school_outlined,
                  label: "Students",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TeacherStudentsPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _profileInfo(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        "$label: $value",
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _actionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF4F6EF7)),
              const SizedBox(width: 16),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
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
