import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final TextEditingController groupNameController = TextEditingController();

  final Set<String> selectedStudentIds = {};
  final Set<String> selectedTeacherIds = {};

  bool loading = false;

  Future<void> _createGroup() async {
  final name = groupNameController.text.trim();
  if (name.isEmpty) return;

  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  setState(() => loading = true);

  try {
    // Ensure creator is included
    selectedTeacherIds.add(user.uid);

    await FirebaseFirestore.instance.collection('groups').add({
      'name': name,
      'teacherIds': selectedTeacherIds.toList(),
      'studentIds': selectedStudentIds.toList(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (mounted) {
      Navigator.pop(context);
    }
  } catch (e) {
    // 🔴 THIS WAS MISSING
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to create group: $e"),
        ),
      );
    }
  } finally {
    // ✅ ALWAYS reset loading
    if (mounted) {
      setState(() => loading = false);
    }
  }
}


  @override
  void dispose() {
    groupNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Group")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: groupNameController,
              decoration: const InputDecoration(
                labelText: "Group Name",
              ),
            ),
          ),

          const Divider(),

          /// 👩‍🎓 STUDENTS
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              "Select Students",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('students')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                return ListView(
                  children: docs.map((doc) {
                    final data =
                        doc.data() as Map<String, dynamic>?;

                    if (data == null) return const SizedBox();

                    final name =
                        data['name']?.toString() ?? 'Unnamed';

                    final selected =
                        selectedStudentIds.contains(doc.id);

                    return CheckboxListTile(
                      title: Text(name),
                      value: selected,
                      onChanged: (_) {
                        setState(() {
                          selected
                              ? selectedStudentIds.remove(doc.id)
                              : selectedStudentIds.add(doc.id);
                        });
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),

          const Divider(),

          /// 👨‍🏫 TEACHERS
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              "Select Teachers",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('teachers')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                return ListView(
                  children: docs.map((doc) {
                    final data =
                        doc.data() as Map<String, dynamic>?;

                    if (data == null) return const SizedBox();

                    final name =
                        data['name']?.toString() ?? 'Unnamed';

                    final selected =
                        selectedTeacherIds.contains(doc.id);

                    return CheckboxListTile(
                      title: Text(name),
                      value: selected,
                      onChanged: (_) {
                        setState(() {
                          selected
                              ? selectedTeacherIds.remove(doc.id)
                              : selectedTeacherIds.add(doc.id);
                        });
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _createGroup,
                    child: const Text("Create Group"),
                  ),
          ),
        ],
      ),
    );
  }
}
