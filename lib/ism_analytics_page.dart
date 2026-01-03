import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class ISMAnalyticsPage extends StatelessWidget {
  const ISMAnalyticsPage({super.key});

  // 🌸 Elegant pastel palette
  static const List<Color> pastelColors = [
    Color(0xFFFFC1A1), // Peach
    Color(0xFFBEE7E8), // Mild Cyan
    Color(0xFFD6C7F7), // Baby Purple
    Color(0xFFF2E2C4), // Beige
    Color(0xFFB7D7B7), // Sage Green
  ];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('complaints').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        int pending = 0;
        int inProgress = 0;

        final Map<String, int> categoryAll = {};
        final Map<String, int> categoryPending = {};
        final Map<String, int> categoryInProgress = {};

        for (var doc in docs) {
          final d = doc.data() as Map<String, dynamic>;
          final category = d['category'];
          final status = d['status'];

          categoryAll[category] = (categoryAll[category] ?? 0) + 1;

          if (status == 'pending') {
            pending++;
            categoryPending[category] =
                (categoryPending[category] ?? 0) + 1;
          }

          if (status == 'in_progress') {
            inProgress++;
            categoryInProgress[category] =
                (categoryInProgress[category] ?? 0) + 1;
          }
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _section(
              "Pending vs In Progress",
              _pieWithLegend({'Pending': pending, 'In Progress': inProgress}),
            ),
            _section(
              "Pending by Category",
              _pieWithLegend(categoryPending),
            ),
            _section(
              "In Progress by Category",
              _pieWithLegend(categoryInProgress),
            ),
            _section(
              "All Complaints by Category",
              _pieWithLegend(categoryAll),
            ),
          ],
        );
      },
    );
  }

  /// ================= SECTION =================
  Widget _section(String title, Widget content) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }

  /// ================= PIE + LEGEND =================
  Widget _pieWithLegend(Map<String, int> data) {
    if (data.isEmpty) {
      return const Center(child: Text("No data"));
    }

    final total = data.values.fold<int>(0, (a, b) => a + b);

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: _buildSections(data, total),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildLegend(data),
      ],
    );
  }

  /// ================= PIE SECTIONS =================
  List<PieChartSectionData> _buildSections(
      Map<String, int> data, int total) {
    int colorIndex = 0;

    return data.entries.map((entry) {
      final percentage =
          total == 0 ? 0 : (entry.value / total * 100).toStringAsFixed(1);

      final section = PieChartSectionData(
        value: entry.value.toDouble(),
        title: "$percentage%",
        radius: 75,
        color: pastelColors[colorIndex % pastelColors.length],
        titleStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      );

      colorIndex++;
      return section;
    }).toList();
  }

  /// ================= LEGEND =================
  Widget _buildLegend(Map<String, int> data) {
    int colorIndex = 0;

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: data.entries.map((entry) {
        final color = pastelColors[colorIndex % pastelColors.length];
        colorIndex++;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              "${entry.key.toUpperCase()} (${entry.value})",
              style: const TextStyle(fontSize: 13),
            ),
          ],
        );
      }).toList(),
    );
  }
}
