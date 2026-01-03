import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RemoveGroupMembersPage extends StatefulWidget {
  final String groupId;

  const RemoveGroupMembersPage({
    super.key,
    required this.groupId,
  });

  @override
  State<RemoveGroupMembersPage> createState() =>
      _RemoveGroupMembersPageState();
}

class _RemoveGroupMembersPageState
    extends State<RemoveGroupMembersPage> {
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  final Set<String> removeStudents = {};
  final Set<String> removeTeachers = {};

  bool loading = true;

  List<String> studentIds = [];
  List<String> teacherIds = [];

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    final snap = await FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .get();

    final data = snap.data();
    if (data == null) return;

    studentIds = List<String>.from(data['studentIds'] ?? []);
    teacherIds = List<String>.from(data['teacherIds'] ?? []);

    setState(() => loading = false);
  }

  Future<void> _removeSelected() async {
    if (removeStudents.isEmpty &&
        removeTeachers.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .update({
      'studentIds':
          FieldValue.arrayRemove(removeStudents.toList()),
      'teacherIds':
          FieldValue.arrayRemove(removeTeachers.toList()),
    });

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Remove Members"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _removeSelected,
          ),
        ],
      ),
      body: ListView(
        children: [
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

          ...teacherIds.map((id) {
            if (id == uid) return const SizedBox.shrink();

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('teachers')
                  .doc(id)
                  .get(),
              builder: (context, snap) {
                final name =
                    snap.data?.get('name') ?? 'Unknown';

                return CheckboxListTile(
                  title: Text(name),
                  subtitle: const Text("Teacher"),
                  value: removeTeachers.contains(id),
                  onChanged: (v) {
                    setState(() {
                      v == true
                          ? removeTeachers.add(id)
                          : removeTeachers.remove(id);
                    });
                  },
                );
              },
            );
          }),

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

          ...studentIds.map((id) {
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('students')
                  .doc(id)
                  .get(),
              builder: (context, snap) {
                final name =
                    snap.data?.get('name') ?? 'Unknown';

                return CheckboxListTile(
                  title: Text(name),
                  subtitle: const Text("Student"),
                  value: removeStudents.contains(id),
                  onChanged: (v) {
                    setState(() {
                      v == true
                          ? removeStudents.add(id)
                          : removeStudents.remove(id);
                    });
                  },
                );
              },
            );
          }),
        ],
      ),
    );
  }
}
