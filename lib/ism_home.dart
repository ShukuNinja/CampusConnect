import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'ism_analytics_page.dart';
import 'login_ism_page.dart';

class ISMHome extends StatefulWidget {
  const ISMHome({super.key});

  @override
  State<ISMHome> createState() => _ISMHomeState();
}

class _ISMHomeState extends State<ISMHome>
    with SingleTickerProviderStateMixin {
  final user = FirebaseAuth.instance.currentUser!;

  late TabController _tabController;

  final List<String> categoryOptions = [
    'All',
    'electrical',
    'cleaning',
    'sanitation',
    'plumbing',
    'others',
  ];

  final List<String> statusOptions = [
    'pending',
    'in_progress',
    'resolved',
  ];

  String selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Issue Manager Dashboard"),
        actions: [
          /// ✅ ONLY FIX IS HERE
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();

              if (!mounted) return;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginISMPage(),
                ),
                (route) => false,
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Complaints"),
            Tab(text: "Analytics"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _complaintsTab(),
          const ISMAnalyticsPage(),
        ],
      ),
    );
  }

  // ================= COMPLAINTS TAB =================

  Widget _complaintsTab() {
    return Column(
      children: [
        _categoryFilter(),
        const Divider(),
        _complaintsList(),
      ],
    );
  }

  Widget _categoryFilter() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: DropdownButton<String>(
        value: selectedCategory,
        isExpanded: true,
        items: categoryOptions.map((c) {
          return DropdownMenuItem(
            value: c,
            child: Text(c.toUpperCase()),
          );
        }).toList(),
        onChanged: (value) {
          if (value == null) return;
          setState(() => selectedCategory = value);
        },
      ),
    );
  }

  Widget _complaintsList() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('complaints')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final complaints = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return selectedCategory == 'All' ||
                data['category'] == selectedCategory;
          }).toList();

          if (complaints.isEmpty) {
            return const Center(child: Text("No complaints found"));
          }

          return ListView.builder(
            itemCount: complaints.length,
            itemBuilder: (context, index) {
              final doc = complaints[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(
                    data['category'].toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['description']),
                      if (data['awaitingConfirmation'] == true)
                        const Padding(
                          padding: EdgeInsets.only(top: 6),
                          child: Text(
                            "Waiting for user approval",
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  trailing: _statusDropdown(doc.id, data),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ================= STATUS HANDLER =================

  Widget _statusDropdown(String complaintId, Map<String, dynamic> data) {
    return DropdownButton<String>(
      value: data['status'],
      underline: const SizedBox(),
      items: statusOptions.map((status) {
        return DropdownMenuItem(
          value: status,
          child: Text(status.replaceAll('_', ' ').toUpperCase()),
        );
      }).toList(),
      onChanged: (value) async {
        if (value == null) return;

        final ref = FirebaseFirestore.instance
            .collection('complaints')
            .doc(complaintId);

        final now = Timestamp.now();

        if (value == 'resolved' &&
            data['awaitingConfirmation'] == true &&
            data['lastResolutionRequestAt'] != null) {
          final last =
              (data['lastResolutionRequestAt'] as Timestamp).toDate();

          if (DateTime.now().difference(last).inHours < 24) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "User has already been asked. Try again after 24 hours.",
                ),
              ),
            );
            return;
          }
        }

        if (value == 'resolved') {
          await FirebaseFirestore.instance.collection('notifications').add({
            'toUserId': data['createdBy'],
            'complaintId': complaintId,
            'category': data['category'],
            'description': data['description'],
            'responded': false,
            'createdAt': now,
          });

          await ref.update({
            'status': 'resolved',
            'awaitingConfirmation': true,
            'lastResolutionRequestAt': now,
          });

          return;
        }

        await ref.update({
          'status': value,
          'awaitingConfirmation': false,
        });
      },
    );
  }
}
