import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddGroupMembersPage extends StatefulWidget {
  final String groupId;

  const AddGroupMembersPage({
    super.key,
    required this.groupId,
  });

  @override
  State<AddGroupMembersPage> createState() => _AddGroupMembersPageState();
}

class _AddGroupMembersPageState extends State<AddGroupMembersPage> {
  final Set<String> selectedStudents = {};
  final Set<String> selectedTeachers = {};

  bool loading = true;

  List<String> existingStudentIds = [];
  List<String> existingTeacherIds = [];

  @override
  void initState() {
    super.initState();
    _loadExistingMembers();
  }

  Future<void> _loadExistingMembers() async {
    final snap = await FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .get();

    final data = snap.data();
    if (data == null) return;

    existingStudentIds =
        List<String>.from(data['studentIds'] ?? []);
    existingTeacherIds =
        List<String>.from(data['teacherIds'] ?? []);

    setState(() => loading = false);
  }

  Future<void> _addMembers() async {
    if (selectedStudents.isEmpty &&
        selectedTeachers.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .update({
      'studentIds': FieldValue.arrayUnion(
        selectedStudents.toList(),
      ),
      'teacherIds': FieldValue.arrayUnion(
        selectedTeachers.toList(),
      ),
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
        title: const Text("Add Members"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _addMembers,
          ),
        ],
      ),
      body: ListView(
        children: [
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

          /// 👩‍🎓 STUDENTS
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('students')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();

              return Column(
                children: snapshot.data!.docs.map((doc) {
                  if (existingStudentIds.contains(doc.id)) {
                    return const SizedBox.shrink();
                  }

                  final data =
                      doc.data() as Map<String, dynamic>;
                  final selected =
                      selectedStudents.contains(doc.id);

                  return CheckboxListTile(
                    value: selected,
                    title: Text(data['name'] ?? 'Unnamed'),
                    subtitle:
                        Text(data['dept'] ?? ''),
                    onChanged: (v) {
                      setState(() {
                        v == true
                            ? selectedStudents.add(doc.id)
                            : selectedStudents.remove(doc.id);
                      });
                    },
                  );
                }).toList(),
              );
            },
          ),

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

          /// 👨‍🏫 TEACHERS
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('teachers')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();

              return Column(
                children: snapshot.data!.docs.map((doc) {
                  if (existingTeacherIds.contains(doc.id)) {
                    return const SizedBox.shrink();
                  }

                  final data =
                      doc.data() as Map<String, dynamic>;
                  final selected =
                      selectedTeachers.contains(doc.id);

                  return CheckboxListTile(
                    value: selected,
                    title: Text(data['name'] ?? 'Unnamed'),
                    subtitle:
                        Text(data['dept'] ?? ''),
                    onChanged: (v) {
                      setState(() {
                        v == true
                            ? selectedTeachers.add(doc.id)
                            : selectedTeachers.remove(doc.id);
                      });
                    },
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
