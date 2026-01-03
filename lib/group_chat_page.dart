// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'group_members_page.dart';
// import 'add_group_members_page.dart';
// import 'remove_group_members_page.dart';

// class GroupChatPage extends StatefulWidget {
//   final String groupId;
//   final String groupName;

//   const GroupChatPage({
//     super.key,
//     required this.groupId,
//     required this.groupName,
//   });

//   @override
//   State<GroupChatPage> createState() => _GroupChatPageState();
// }

// class _GroupChatPageState extends State<GroupChatPage> {
//   final TextEditingController controller = TextEditingController();
//   final String uid = FirebaseAuth.instance.currentUser!.uid;

//   bool _isTeacher = false;
//   bool _loading = true;

//   late String _groupName;

//   DocumentReference get _groupRef =>
//       FirebaseFirestore.instance.collection('groups').doc(widget.groupId);

//   @override
//   void initState() {
//     super.initState();
//     _groupName = widget.groupName;
//     _checkRole();
//   }

//   Future<void> _checkRole() async {
//     final snap = await _groupRef.get();
//     if (!snap.exists) return;

//     final data = snap.data() as Map<String, dynamic>;
//     final teacherIds = List<String>.from(data['teacherIds'] ?? []);

//     setState(() {
//       _isTeacher = teacherIds.contains(uid);
//       _loading = false;
//     });
//   }

//   Future<void> _sendMessage() async {
//     final text = controller.text.trim();
//     if (text.isEmpty) return;

//     controller.clear();

//     await _groupRef.collection('messages').add({
//       'senderId': uid,
//       'text': text,
//       'createdAt': FieldValue.serverTimestamp(),
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_loading) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(_groupName),
//         actions: [
//           PopupMenuButton<String>(
//             onSelected: (value) {
//               if (value == 'view') {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) =>
//                         GroupMembersPage(groupId: widget.groupId),
//                   ),
//                 );
//               }
//               if (!_isTeacher) return;

//               if (value == 'add') {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) =>
//                         AddGroupMembersPage(groupId: widget.groupId),
//                   ),
//                 );
//               }
//               if (value == 'remove') {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) =>
//                         RemoveGroupMembersPage(groupId: widget.groupId),
//                   ),
//                 );
//               }
//             },
//             itemBuilder: (_) => _isTeacher
//                 ? const [
//                     PopupMenuItem(value: 'view', child: Text('View Members')),
//                     PopupMenuItem(value: 'add', child: Text('Add Members')),
//                     PopupMenuItem(
//                         value: 'remove', child: Text('Remove Members')),
//                   ]
//                 : const [
//                     PopupMenuItem(value: 'view', child: Text('View Members')),
//                   ],
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: _groupRef
//                   .collection('messages')
//                   .orderBy('createdAt')
//                   .snapshots(),
//               builder: (_, snap) {
//                 if (!snap.hasData) {
//                   return const Center(
//                       child: CircularProgressIndicator());
//                 }

//                 final msgs = snap.data!.docs;

//                 return ListView.builder(
//                   itemCount: msgs.length,
//                   itemBuilder: (_, i) {
//                     final m = msgs[i].data() as Map<String, dynamic>;
//                     final isMe = m['senderId'] == uid;

//                     return Align(
//                       alignment:
//                           isMe ? Alignment.centerRight : Alignment.centerLeft,
//                       child: Container(
//                         margin: const EdgeInsets.all(6),
//                         padding: const EdgeInsets.all(10),
//                         decoration: BoxDecoration(
//                           color: isMe
//                               ? Colors.greenAccent
//                               : Colors.grey.shade300,
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Text(m['text'] ?? ''),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//           if (_isTeacher)
//             SafeArea(
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: controller,
//                       decoration: const InputDecoration(
//                         hintText: "Send message...",
//                         border: InputBorder.none,
//                       ),
//                     ),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.send),
//                     onPressed: _sendMessage,
//                   ),
//                 ],
//               ),
//             )
//           else
//             const Padding(
//               padding: EdgeInsets.all(12),
//               child: Text(
//                 "Only teachers can send messages",
//                 style: TextStyle(color: Colors.grey),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'group_members_page.dart';
import 'add_group_members_page.dart';
import 'remove_group_members_page.dart';

class GroupChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;

  const GroupChatPage({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  final TextEditingController controller = TextEditingController();
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  bool _isTeacher = false;
  bool _loading = true;

  late String _groupName;

  DocumentReference get _groupRef =>
      FirebaseFirestore.instance.collection('groups').doc(widget.groupId);

  @override
  void initState() {
    super.initState();
    _groupName = widget.groupName;
    _checkRole();
  }

  Future<void> _checkRole() async {
    final snap = await _groupRef.get();
    if (!snap.exists) return;

    final data = snap.data() as Map<String, dynamic>;
    final teacherIds = List<String>.from(data['teacherIds'] ?? []);

    setState(() {
      _isTeacher = teacherIds.contains(uid);
      _loading = false;
    });
  }

  Future<void> _sendMessage() async {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    controller.clear();

    await _groupRef.collection('messages').add({
      'senderId': uid,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// ✏️ EDIT GROUP NAME DIALOG
  Future<void> _editGroupName() async {
    final TextEditingController nameController =
        TextEditingController(text: _groupName);

    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Edit Group Name"),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: "Group name",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final value = nameController.text.trim();
                if (value.isEmpty) return;
                Navigator.pop(ctx, value);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );

    if (newName == null || newName == _groupName) return;

    await _groupRef.update({'name': newName});

    setState(() {
      _groupName = newName;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_groupName),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'view') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        GroupMembersPage(groupId: widget.groupId),
                  ),
                );
              }

              if (!_isTeacher) return;

              if (value == 'edit') {
                await _editGroupName();
              }

              if (value == 'add') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AddGroupMembersPage(groupId: widget.groupId),
                  ),
                );
              }

              if (value == 'remove') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        RemoveGroupMembersPage(groupId: widget.groupId),
                  ),
                );
              }
            },
            itemBuilder: (_) => _isTeacher
                ? const [
                    PopupMenuItem(
                      value: 'view',
                      child: Text('View Members'),
                    ),
                    PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit Group Name'),
                    ),
                    PopupMenuItem(
                      value: 'add',
                      child: Text('Add Members'),
                    ),
                    PopupMenuItem(
                      value: 'remove',
                      child: Text('Remove Members'),
                    ),
                  ]
                : const [
                    PopupMenuItem(
                      value: 'view',
                      child: Text('View Members'),
                    ),
                  ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _groupRef
                  .collection('messages')
                  .orderBy('createdAt')
                  .snapshots(),
              builder: (_, snap) {
                if (!snap.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final msgs = snap.data!.docs;

                return ListView.builder(
                  itemCount: msgs.length,
                  itemBuilder: (_, i) {
                    final m = msgs[i].data() as Map<String, dynamic>;
                    final isMe = m['senderId'] == uid;

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.all(6),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isMe
                              ? Colors.greenAccent
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(m['text'] ?? ''),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (_isTeacher)
            SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: "Send message...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                "Only teachers can send messages",
                style: TextStyle(color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }
}
