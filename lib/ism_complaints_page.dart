import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ISMComplaintsPage extends StatelessWidget {
  const ISMComplaintsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Issue Manager Dashboard")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('complaints')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error loading complaints"));
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No complaints available"));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final c = docs[index];

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(c['category']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c['description']),
                      const SizedBox(height: 6),
                      Text("Status: ${c['status']}"),
                    ],
                  ),
                  trailing: DropdownButton<String>(
                    value: c['status'],
                    items: const [
                      DropdownMenuItem(
                        value: "Not Started",
                        child: Text("Not Started"),
                      ),
                      DropdownMenuItem(
                        value: "In Progress",
                        child: Text("In Progress"),
                      ),
                      DropdownMenuItem(
                        value: "Resolved",
                        child: Text("Resolved"),
                      ),
                    ],
                    onChanged: (val) {
                      FirebaseFirestore.instance
                          .collection('complaints')
                          .doc(c.id)
                          .update({"status": val});
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
