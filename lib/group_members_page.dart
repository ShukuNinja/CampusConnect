import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupMembersPage extends StatelessWidget {
  final String groupId;

  const GroupMembersPage({
    super.key,
    required this.groupId,
  });

  /// Resolve user name safely
  Future<String> _getName(
    String uid,
    String collection,
  ) async {
    final doc = await FirebaseFirestore.instance
        .collection(collection)
        .doc(uid)
        .get();

    if (!doc.exists) return 'Unknown';

    final data = doc.data();
    if (data == null) return 'Unknown';

    return data['name']?.toString() ?? 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    final groupRef =
        FirebaseFirestore.instance.collection('groups').doc(groupId);

    return Scaffold(
      appBar: AppBar(title: const Text("Group Members")),
      body: StreamBuilder<DocumentSnapshot>(
        stream: groupRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text("Group not found"),
            );
          }

          final data = snapshot.data!.data();
          if (data == null ||
              data is! Map<String, dynamic>) {
            return const Center(
              child: Text("Invalid group data"),
            );
          }

          final List<String> teacherIds =
              List<String>.from(data['teacherIds'] ?? []);
          final List<String> studentIds =
              List<String>.from(data['studentIds'] ?? []);

          return ListView(
            children: [
              /// 👨‍🏫 TEACHERS
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  "Teachers",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),

              if (teacherIds.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text("No teachers in this group"),
                )
              else
                ...teacherIds.map(
                  (uid) => FutureBuilder<String>(
                    future: _getName(uid, 'teachers'),
                    builder: (context, snap) {
                      return ListTile(
                        leading:
                            const Icon(Icons.person_outline),
                        title: Text(
                          snap.data ?? 'Loading...',
                        ),
                        subtitle: const Text("Teacher"),
                      );
                    },
                  ),
                ),

              const Divider(),

              /// 👩‍🎓 STUDENTS
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  "Students",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),

              if (studentIds.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text("No students in this group"),
                )
              else
                ...studentIds.map(
                  (uid) => FutureBuilder<String>(
                    future: _getName(uid, 'students'),
                    builder: (context, snap) {
                      return ListTile(
                        leading:
                            const Icon(Icons.person_outline),
                        title: Text(
                          snap.data ?? 'Loading...',
                        ),
                        subtitle: const Text("Student"),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
