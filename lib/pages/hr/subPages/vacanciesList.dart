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

  // --- DARK THEME ---
  static const Color _bgDark = Color(0xFF121212);
  static const Color _surfaceDark = Color(0xFF1E1E1E);
  static const Color _primaryAccent = Color(0xFF4361EE);
  static const Color _textWhite = Color(0xFFFFFFFF);
  static const Color _textGrey = Color(0xFFB3B3B3);
  static const Color _borderColor = Color(0xFF333333);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: _primaryAccent),
      );
    }

    if (errorMessage != null) {
      return Container(
        color: _bgDark,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: Colors.redAccent, size: 48),
              const SizedBox(height: 16),
              Text(
                "Failed to load data\n$errorMessage",
                textAlign: TextAlign.center,
                style: const TextStyle(color: _textGrey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryAccent,
                ),
                child: const Text("Retry",
                    style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      );
    }

    if (vacancies.isEmpty) {
      return const Center(
        child: Text(
          "No HR Vacancy data found.",
          style: TextStyle(color: _textGrey, fontSize: 16),
        ),
      );
    }

    return Container(
      color: _bgDark,
      child: RefreshIndicator(
        onRefresh: () async => onRetry(),
        color: _primaryAccent,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Automated Insights",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _textWhite,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _primaryAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "As of: $reportDate",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _primaryAccent,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // --- TABLE CARD ---
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _surfaceDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor:
                          WidgetStateProperty.resolveWith(
                              (states) => _bgDark),
                      headingTextStyle: const TextStyle(
                        color: _textGrey,
                        fontWeight: FontWeight.w600,
                      ),
                      dataTextStyle:
                          const TextStyle(color: _textWhite),
                      columnSpacing: 24,
                      horizontalMargin: 20,
                      columns: const [
                        DataColumn(label: Text("Position")),
                        DataColumn(label: Text("Department")),
                        DataColumn(label: Text("Company")),
                        DataColumn(label: Text("Location")),
                        DataColumn(label: Text("Vacancies")),
                        DataColumn(label: Text("Priority")),
                      ],
                      rows: vacancies.map((vacancy) {
                        final isCritical =
                            vacancy.critical.toLowerCase().contains("critical") &&
                                !vacancy.critical
                                    .toLowerCase()
                                    .contains("non");

                        return DataRow(
                          cells: [
                            DataCell(Text(
                              vacancy.position,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600),
                            )),
                            DataCell(Text(vacancy.department)),
                            DataCell(Text(vacancy.company)),
                            DataCell(Text(vacancy.location)),
                            DataCell(Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: _primaryAccent.withOpacity(0.15),
                                borderRadius:
                                    BorderRadius.circular(12),
                              ),
                              child: Text(
                                vacancy.vacantNos.toString(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            )),
                            DataCell(Row(
                              children: [
                                Icon(
                                  isCritical
                                      ? Icons.local_fire_department_rounded
                                      : Icons.info_outline_rounded,
                                  size: 16,
                                  color: isCritical
                                      ? Colors.orangeAccent
                                      : _textGrey,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  vacancy.critical,
                                  style: TextStyle(
                                    color: isCritical
                                        ? Colors.orangeAccent
                                        : _textGrey,
                                    fontWeight: isCritical
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    fontSize: 12,
                                  ),
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
      ),
    );
  }
}