
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// import 'chat_page.dart';

// class TeacherProfilePage extends StatelessWidget {
//   final String teacherId;
//   final Map<String, dynamic> teacher;

//   const TeacherProfilePage({
//     super.key,
//     required this.teacherId,
//     required this.teacher,
//   });

//   /// 🔍 Find existing chat
//   Future<String?> _findExistingChatId(
//     String currentUid,
//     String otherUid,
//   ) async {
//     final query = await FirebaseFirestore.instance
//         .collection('chats')
//         .where('participants', arrayContains: currentUid)
//         .get();

//     for (final doc in query.docs) {
//       final participants = List<String>.from(doc['participants']);
//       if (participants.contains(otherUid)) {
//         return doc.id;
//       }
//     }
//     return null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final studentId = FirebaseAuth.instance.currentUser!.uid;

//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F7FB),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0.5,
//         centerTitle: true,
//         iconTheme: const IconThemeData(color: Colors.black87),
//         title: Text(
//           teacher['name'] ?? 'Teacher Profile',
//           style: const TextStyle(
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
//             /// 👤 TEACHER INFO CARD
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 border: Border.all(color: const Color(0xFFCBD5E1)),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _infoRow("Name", teacher['name']),
//                   _infoRow("Department", teacher['dept']),
//                   _infoRow(
//                     "Availability",
//                     teacher['availability'],
//                     bold: true,
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 32),

//             /// 💬 MESSAGE NOW BUTTON (NEW)
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () async {
//                   final chatId = await _findExistingChatId(
//                     studentId,
//                     teacherId,
//                   );

//                   if (!context.mounted) return;

//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => ChatPage(
//                         chatId: chatId,
//                         otherUserId: teacherId,
//                         otherUserName: teacher['name'],
//                       ),
//                     ),
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 child: const Text(
//                   "Message Now",
//                   style: TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _infoRow(String label, dynamic value, {bool bold = false}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 10),
//       child: Text(
//         "$label: $value",
//         style: TextStyle(
//           fontSize: 14,
//           fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
//           color: Colors.black87,
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'chat_page.dart';

class TeacherProfilePage extends StatelessWidget {
  final String teacherId;
  final Map<String, dynamic> teacher;

  const TeacherProfilePage({
    super.key,
    required this.teacherId,
    required this.teacher,
  });

  /// 🔍 Find existing chat (UNCHANGED)
  Future<String?> _findExistingChatId(
    String currentUid,
    String otherUid,
  ) async {
    final query = await FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: currentUid)
        .get();

    for (final doc in query.docs) {
      final participants = List<String>.from(doc['participants']);
      if (participants.contains(otherUid)) {
        return doc.id;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final studentId = FirebaseAuth.instance.currentUser!.uid;
    final name = teacher['name'] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          "Teacher Profile",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 👤 PROFILE CARD — SAME AS STUDENT PROFILE
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFCBD5E1),
                ),
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
                  /// Avatar + Name
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

                  _infoRow("Department", teacher['dept']),
                  _infoRow(
                    "Availability",
                    teacher['availability'],
                    bold: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            /// 💬 MESSAGE NOW BUTTON — UNCHANGED LOGIC
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final chatId = await _findExistingChatId(
                    studentId,
                    teacherId,
                  );

                  if (!context.mounted) return;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatPage(
                        chatId: chatId,
                        otherUserId: teacherId,
                        otherUserName: teacher['name'],
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Message Now",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, dynamic value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        "$label: $value",
        style: TextStyle(
          fontSize: 14,
          fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
          color: Colors.black87,
        ),
      ),
    );
  }
}
