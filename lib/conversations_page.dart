import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'chat_page.dart';
import 'group_chat_page.dart';

class ConversationsPage extends StatelessWidget {
  const ConversationsPage({super.key});

  Future<String> _resolveUserName(String uid) async {
    final studentDoc = await FirebaseFirestore.instance
        .collection('students')
        .doc(uid)
        .get();

    if (studentDoc.exists) {
      return studentDoc.data()?['name'] ?? 'Unknown';
    }

    final teacherDoc = await FirebaseFirestore.instance
        .collection('teachers')
        .doc(uid)
        .get();

    if (teacherDoc.exists) {
      return teacherDoc.data()?['name'] ?? 'Unknown';
    }

    return 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("User not logged in")),
      );
    }

    final currentUid = user.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          "Conversations",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      body: Column(
        children: [
          /// ===================== 1–1 CHATS =====================
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .where('participants', arrayContains: currentUid)
                  .orderBy('lastMessageAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];

                final chats = docs.where((doc) {
                  final data =
                      doc.data() as Map<String, dynamic>?;

                  return data != null &&
                      data['lastMessage'] != null &&
                      data['lastMessage']
                          .toString()
                          .isNotEmpty;
                }).toList();

                if (chats.isEmpty) {
                  return const SizedBox();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Text(
                        "Chats",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: chats.length,
                        itemBuilder: (context, index) {
                          final chatDoc = chats[index];
                          final data = chatDoc.data()
                              as Map<String, dynamic>;

                          final participants =
                              List<String>.from(
                                  data['participants'] ?? []);

                          final otherUserId =
                              participants.firstWhere(
                            (id) => id != currentUid,
                            orElse: () => "",
                          );

                          return FutureBuilder<String>(
                            future: _resolveUserName(otherUserId),
                            builder: (context, nameSnap) {
                              final name =
                                  nameSnap.data ?? "Loading...";

                              return Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 6),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(
                                    Icons.person_outline,
                                    color: Colors.black54,
                                  ),
                                  title: Text(
                                    name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  subtitle: Text(
                                    data['lastMessage'],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ChatPage(
                                          chatId: chatDoc.id,
                                          otherUserId: otherUserId,
                                          otherUserName: name,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          /// ===================== GROUP CHATS =====================
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('groups')
                  .where('studentIds', arrayContains: currentUid)
                  .snapshots(),
              builder: (context, studentSnap) {
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('groups')
                      .where('teacherIds', arrayContains: currentUid)
                      .snapshots(),
                  builder: (context, teacherSnap) {
                    if (studentSnap.connectionState ==
                            ConnectionState.waiting ||
                        teacherSnap.connectionState ==
                            ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator());
                    }

                    final Map<String, QueryDocumentSnapshot>
                        groupMap = {};

                    for (final doc
                        in studentSnap.data?.docs ?? []) {
                      groupMap[doc.id] = doc;
                    }

                    for (final doc
                        in teacherSnap.data?.docs ?? []) {
                      groupMap[doc.id] = doc;
                    }

                    if (groupMap.isEmpty) {
                      return const SizedBox();
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Text(
                            "Groups",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView(
                            children: groupMap.values.map((doc) {
                              final data =
                                  doc.data() as Map<String, dynamic>?;

                              if (data == null) {
                                return const SizedBox();
                              }

                              final groupName =
                                  data['name']?.toString() ??
                                      "Group";

                              return Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 6),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(
                                    Icons.group_outlined,
                                    color: Colors.black54,
                                  ),
                                  title: Text(
                                    groupName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  subtitle: const Text(
                                    "Group",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            GroupChatPage(
                                          groupId: doc.id,
                                          groupName: groupName,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
