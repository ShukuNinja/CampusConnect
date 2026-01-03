// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// import 'create_group_page.dart';

// class TeacherStudentsPage extends StatefulWidget {
//   const TeacherStudentsPage({super.key});

//   @override
//   State<TeacherStudentsPage> createState() => _TeacherStudentsPageState();
// }

// class _TeacherStudentsPageState extends State<TeacherStudentsPage> {
//   final List<String> departments = ['All', 'cse', 'it', 'ece', 'eee'];

//   String deptFilter = 'All';
//   String search = '';
//   bool selectionMode = false;

//   final Set<String> selectedStudentIds = {};

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Students"),
//         actions: [
//           IconButton(
//             icon: Icon(selectionMode ? Icons.close : Icons.group_add),
//             onPressed: () {
//               setState(() {
//                 selectionMode = !selectionMode;
//                 selectedStudentIds.clear();
//               });
//             },
//           ),
//         ],
//       ),

//       floatingActionButton: selectionMode && selectedStudentIds.isNotEmpty
//           ? FloatingActionButton.extended(
//               icon: const Icon(Icons.arrow_forward),
//               label: const Text("Next"),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => const CreateGroupPage(),

//                   ),
//                 );
//               },
//             )
//           : null,

//       body: Column(
//         children: [
//           /// 🔹 Filters
//           Padding(
//             padding: const EdgeInsets.all(8),
//             child: Row(
//               children: [
//                 DropdownButton<String>(
//                   value: deptFilter,
//                   items: departments
//                       .map(
//                         (d) => DropdownMenuItem(
//                           value: d,
//                           child: Text(d.toUpperCase()),
//                         ),
//                       )
//                       .toList(),
//                   onChanged: (v) {
//                     if (v == null) return;
//                     setState(() => deptFilter = v);
//                   },
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: TextField(
//                     decoration: const InputDecoration(
//                       hintText: "Search name / reg no",
//                     ),
//                     onChanged: (v) => setState(() => search = v.trim()),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           /// 🔹 Students List
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collection('students')
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState ==
//                     ConnectionState.waiting) {
//                   return const Center(
//                       child: CircularProgressIndicator());
//                 }

//                 if (!snapshot.hasData ||
//                     snapshot.data!.docs.isEmpty) {
//                   return const Center(
//                     child: Text("No students found"),
//                   );
//                 }

//                 final students = snapshot.data!.docs.where((doc) {
//                   final raw = doc.data();

//                   if (raw == null ||
//                       raw is! Map<String, dynamic>) {
//                     return false;
//                   }

//                   final name =
//                       raw['name']?.toString().toLowerCase() ?? '';
//                   final regno =
//                       raw['regno']?.toString().toLowerCase() ?? '';
//                   final dept =
//                       raw['dept']?.toString().toLowerCase() ?? '';

//                   final deptOk = deptFilter == 'All' ||
//                       dept == deptFilter.toLowerCase();

//                   final searchLower = search.toLowerCase();
//                   final searchOk = name.contains(searchLower) ||
//                       regno.contains(searchLower);

//                   return deptOk && searchOk;
//                 }).toList();

//                 if (students.isEmpty) {
//                   return const Center(
//                     child: Text("No students match filters"),
//                   );
//                 }

//                 return ListView.builder(
//                   itemCount: students.length,
//                   itemBuilder: (_, i) {
//                     final doc = students[i];
//                     final data =
//                         doc.data() as Map<String, dynamic>;

//                     final name =
//                         data['name']?.toString() ?? "Unnamed";
//                     final regno =
//                         data['regno']?.toString() ?? "N/A";
//                     final dept =
//                         data['dept']?.toString().toUpperCase() ??
//                             "N/A";

//                     final isSelected =
//                         selectedStudentIds.contains(doc.id);

//                     return ListTile(
//                       leading: selectionMode
//                           ? Checkbox(
//                               value: isSelected,
//                               onChanged: (_) {
//                                 setState(() {
//                                   isSelected
//                                       ? selectedStudentIds
//                                           .remove(doc.id)
//                                       : selectedStudentIds
//                                           .add(doc.id);
//                                 });
//                               },
//                             )
//                           : null,
//                       title: Text(name),
//                       subtitle: Text("$regno • $dept"),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'student_profile_page.dart';

class TeacherStudentsPage extends StatefulWidget {
  const TeacherStudentsPage({super.key});

  @override
  State<TeacherStudentsPage> createState() => _TeacherStudentsPageState();
}

class _TeacherStudentsPageState extends State<TeacherStudentsPage> {
  final List<String> deptFilterOptions = [
    'All',
    'CSE',
    'IT',
    'ECE',
    'EEE',
    'MECH',
  ];

  String selectedDept = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          "Students",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 🎯 DEPARTMENT FILTER
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedDept,
                  isExpanded: true,
                  items: deptFilterOptions
                      .map(
                        (d) => DropdownMenuItem(
                          value: d,
                          child: Text(d),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => selectedDept = v);
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// 📚 STUDENT LIST
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: selectedDept == 'All'
                    ? FirebaseFirestore.instance
                        .collection('students')
                        .snapshots()
                    : FirebaseFirestore.instance
                        .collection('students')
                        .where('dept', isEqualTo: selectedDept)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final students = snapshot.data!.docs;

                  if (students.isEmpty) {
                    return const Center(
                      child: Text("No students found"),
                    );
                  }

                  return ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (_, i) {
                      final doc = students[i];
                      final s = doc.data() as Map<String, dynamic>;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: ListTile(
                          title: Text(
                            s['name'] ?? 'Student',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            "${s['regno']} • ${s['dept']}",
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => StudentProfilePage(
                                  student: s,
                                  studentId: doc.id,
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
        ),
      ),
    );
  }
}
