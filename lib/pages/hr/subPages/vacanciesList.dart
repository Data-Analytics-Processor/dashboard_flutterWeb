// lib/pages/hr/subPages/vacanciesList.dart

import 'package:flutter/material.dart';
import '../../../models/hr_reports_model.dart';

class VacanciesListTab extends StatelessWidget {
  final List<HrVacancy> vacancies;
  final String reportDate;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;

  const VacanciesListTab({
    super.key,
    required this.vacancies,
    required this.reportDate,
    required this.isLoading,
    this.errorMessage,
    required this.onRetry,
  });

  // Theme Constants
  static const Color _bgWhite = Color(0xFFF8FAFC);
  static const Color _primaryNavy = Color(0xFF0A2540);
  static const Color _textBlack = Color(0xFF1E293B);
  static const Color _textGrey = Color(0xFF64748B);
  static const Color _surfaceWhite = Color(0xFFFFFFFF);
  static const Color _borderColor = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: _primaryNavy));
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            Text("Failed to load data\n$errorMessage",
                textAlign: TextAlign.center, style: const TextStyle(color: _textGrey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(backgroundColor: _primaryNavy),
              child: const Text("Retry", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      );
    }

    if (vacancies.isEmpty) {
      return const Center(
        child: Text("No HR Vacancy data found.", style: TextStyle(color: _textGrey, fontSize: 16)),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRetry(),
      color: _primaryNavy,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Automated Insights",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _textBlack),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _primaryNavy.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "As of: $reportDate",
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _primaryNavy),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Data Table Card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: _surfaceWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _borderColor),
                boxShadow: [
                  BoxShadow(color: _textBlack.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.resolveWith((states) => _bgWhite),
                    columnSpacing: 24,
                    horizontalMargin: 20,
                    columns: const [
                      DataColumn(label: Text("Position", style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("Department", style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("Company", style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("Location", style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("Vacancies", style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("Priority", style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: vacancies.map((vacancy) {
                      final isCritical = vacancy.critical.toLowerCase().contains("critical") &&
                          !vacancy.critical.toLowerCase().contains("non");

                      return DataRow(
                        cells: [
                          DataCell(Text(vacancy.position, style: const TextStyle(fontWeight: FontWeight.w600, color: _textBlack))),
                          DataCell(Text(vacancy.department, style: const TextStyle(color: _textGrey))),
                          DataCell(Text(vacancy.company, style: const TextStyle(color: _textGrey))),
                          DataCell(Text(vacancy.location, style: const TextStyle(color: _textGrey))),
                          DataCell(Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: _textBlack.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(vacancy.vacantNos.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                          )),
                          DataCell(Row(
                            children: [
                              Icon(
                                isCritical ? Icons.local_fire_department_rounded : Icons.info_outline_rounded,
                                size: 16,
                                color: isCritical ? Colors.orangeAccent : _textGrey,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                vacancy.critical,
                                style: TextStyle(
                                    color: isCritical ? Colors.orange[800] : _textGrey,
                                    fontWeight: isCritical ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 12),
                              ),
                            ],
                          )),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}