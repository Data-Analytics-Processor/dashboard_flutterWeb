// lib/pages/hr/actions/newInterviews.dart
import 'package:flutter/material.dart';
import '../../../models/hr_reports_model.dart';
import '../../../api/api_service.dart';

import '../../../components/dynamic_form_config.dart';
import '../../../components/data_table_reusable.dart';
import '../../../components/create_data_dialog.dart';
import '../../../components/edit_data_dialog.dart';

class NewInterviewsTab extends StatelessWidget {
  final List<HrInterview> interviews;
  final VoidCallback onRefresh;
  final ApiService _apiService = ApiService();

  NewInterviewsTab({
    super.key,
    required this.interviews,
    required this.onRefresh,
  });

  // --- DARK THEME COLORS ---
  static const Color _bgDark = Color(0xFF121212);
  static const Color _surfaceDark = Color(0xFF1E1E1E);
  static const Color _primaryAccent = Color(0xFF4361EE);
  static const Color _textWhite = Color(0xFFFFFFFF);
  static const Color _textGrey = Color(0xFFB3B3B3);
  static const Color _errorRed = Color(0xFFEF4444);

  void _openAddDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => CreateDataDialog(
        title: "Schedule New Interview",
        fields: const [
          FormFieldConfig(key: "name", label: "Candidate Name"),
          FormFieldConfig(key: "designation", label: "Designation"),
          FormFieldConfig(key: "department", label: "Department"),
          FormFieldConfig(
              key: "dateOfInterview", label: "Date", type: FormFieldType.date),
        ],
        onSubmit: (dataList) async {
          try {
            await _apiService.addHrInterview({
              "interviews": dataList,
            });
            onRefresh();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Interview added!")),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error: $e")),
              );
            }
          }
        },
      ),
    );
  }

  void _openEditDialog(BuildContext context, HrInterview interview) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => EditDataDialog(
        title: "Edit Interview",
        fields: const [
          FormFieldConfig(key: "name", label: "Candidate Name"),
          FormFieldConfig(key: "designation", label: "Designation"),
          FormFieldConfig(key: "department", label: "Department"),
          FormFieldConfig(
              key: "dateOfInterview", label: "Date", type: FormFieldType.date),
        ],
        initialData: {
          "name": interview.name,
          "designation": interview.designation,
          "department": interview.department,
          "dateOfInterview": interview.dateOfInterview,
        },
        onSubmit: (data) async {
          try {
            await _apiService.editHrInterview(interview.id, data);
            onRefresh();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Interview updated!")),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error: $e")),
              );
            }
          }
        },
      ),
    );
  }

  Future<void> _deleteInterview(BuildContext context, String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _surfaceDark,
        title: const Text("Delete Interview?", style: TextStyle(color: _textWhite)),
        content: const Text(
          "Are you sure you want to remove this candidate?",
          style: TextStyle(color: _textGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel", style: TextStyle(color: _textGrey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _errorRed),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _apiService.deleteHrInterview(id);
        onRefresh();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Interview deleted.")),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $e")),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bgDark,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ReusableDataTable<HrInterview>(
          title: "Scheduled Interviews",
          addActionLabel: "Add New Interviews",
          onAdd: () => _openAddDialog(context),
          onEdit: (item) => _openEditDialog(context, item),
          onDelete: (item) => _deleteInterview(context, item.id),
          columns: const ["Name", "Designation", "Department", "Date"],
          data: interviews,
          buildCells: (i) => [
            DataCell(Text(i.name, style: const TextStyle(fontWeight: FontWeight.bold))),
            DataCell(Text(i.designation)),
            DataCell(Text(i.department)),
            DataCell(Text(i.dateOfInterview, style: const TextStyle(color: _primaryAccent))),
          ],
        ),
      ),
    );
  }
}