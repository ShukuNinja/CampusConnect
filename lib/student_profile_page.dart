// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// import 'chat_page.dart';

// class StudentProfilePage extends StatelessWidget {
//   final Map<String, dynamic> student;
//   final String studentId;

//   const StudentProfilePage({
//     super.key,
//     required this.student,
//     required this.studentId,
//   });

//   /// 🔍 Find existing chat using participants logic
//   Future<String?> _findExistingChatId(
//     String currentUid,
//     String otherUid,
//   ) async {
//     final query = await FirebaseFirestore.instance
//         .collection('chats')
//         .where('participants', arrayContains: currentUid)
//         .get();

//     for (final doc in query.docs) {
//       final participants =
//           List<String>.from(doc['participants']);
//       if (participants.contains(otherUid)) {
//         return doc.id;
//       }
//     }
//     return null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final currentUid = FirebaseAuth.instance.currentUser!.uid;

//     return Scaffold(
//       appBar: AppBar(title: const Text("Student Profile")),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text("Name: ${student['name']}"),
//             Text("Email: ${student['email']}"),
//             Text("Department: ${student['dept']}"),
//             Text("Reg No: ${student['regno']}"),
//             Text("Year: ${student['year']}"),

//             const SizedBox(height: 24),

//             /// 💬 MESSAGE NOW
//             ElevatedButton(
//               onPressed: () async {
//                 final chatId = await _findExistingChatId(
//                   currentUid,
//                   studentId,
//                 );

//                 if (!context.mounted) return;

//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => ChatPage(
//                       chatId: chatId,
//                       otherUserId: studentId,
//                       otherUserName: student['name'],
//                     ),
//                   ),
//                 );
//               },
//               child: const Text("Message Now"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'chat_page.dart';

class StudentProfilePage extends StatelessWidget {
  final Map<String, dynamic> student;
  final String studentId;

  const StudentProfilePage({
    super.key,
    required this.student,
    required this.studentId,
  });

  /// 🔍 Find existing chat using participants logic
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
    final currentUid = FirebaseAuth.instance.currentUser!.uid;
    final name = student['name'] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: const Text(
          "Student Profile",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Padding(
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
                  _infoRow("Email", student['email']),
                  _infoRow("Department", student['dept']),
                  _infoRow("Register No", student['regno']),
                  _infoRow("Passing Year", student['passingYear']),
                ],
              ),
            ),

            const SizedBox(height: 32),

            /// 💬 MESSAGE NOW BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final chatId = await _findExistingChatId(
                    currentUid,
                    studentId,
                  );

                  if (!context.mounted) return;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatPage(
                        chatId: chatId,
                        otherUserId: studentId,
                        otherUserName: student['name'],
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

  Widget _infoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        "$label: $value",
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    );
  }
}
