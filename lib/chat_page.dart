import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatPage extends StatefulWidget {
  final String? chatId; // nullable
  final String otherUserId;
  final String otherUserName;

  const ChatPage({
    super.key,
    required this.chatId,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController controller = TextEditingController();
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  DocumentReference? _chatRef;
  String? _chatId;

  @override
  void initState() {
    super.initState();

    _chatId = widget.chatId;

    if (_chatId != null) {
      _chatRef =
          FirebaseFirestore.instance.collection('chats').doc(_chatId);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  /// 🧱 Create chat ONLY when first message is sent
  Future<void> _ensureChatExists(String firstMessage) async {
    if (_chatRef != null) return;

    final doc =
        await FirebaseFirestore.instance.collection('chats').add({
      "participants": [uid, widget.otherUserId],
      "createdAt": FieldValue.serverTimestamp(),
      "lastMessage": firstMessage,
      "lastMessageAt": FieldValue.serverTimestamp(),
    });

    _chatId = doc.id;
    _chatRef = doc;

    setState(() {}); // rebuild to attach stream
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.otherUserName)),
      body: Column(
        children: [
          /// 💬 MESSAGES
          Expanded(
            child: _chatRef == null
                ? const Center(
                    child: Text(
                      "Say hi 👋",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : StreamBuilder<QuerySnapshot>(
                    stream: _chatRef!
                        .collection('messages')
                        .orderBy('createdAt')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData ||
                          snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text(
                            "Say hi 👋",
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }

                      final messages = snapshot.data!.docs;

                      return ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index].data()
                              as Map<String, dynamic>;

                          final isMe =
                              msg['senderId'] == uid;

                          return Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 4),
                              padding:
                                  const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? Colors.blueAccent
                                    : Colors.grey.shade300,
                                borderRadius:
                                    BorderRadius.circular(8),
                              ),
                              child: Text(
                                msg['text'] ?? "",
                                style: TextStyle(
                                  color: isMe
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),

          /// ✏️ INPUT BAR
          SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8),
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: "Type a message...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    final text = controller.text.trim();
                    if (text.isEmpty) return;

                    // 🧱 Create chat if needed
                    await _ensureChatExists(text);

                    // 💬 Send message
                    await _chatRef!
                        .collection('messages')
                        .add({
                      "senderId": uid,
                      "text": text,
                      "createdAt":
                          FieldValue.serverTimestamp(),
                    });

                    // 🔄 Update chat meta
                    await _chatRef!.update({
                      "lastMessage": text,
                      "lastMessageAt":
                          FieldValue.serverTimestamp(),
                    });

                    controller.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
