// lib/pages/hr/actions/topPerformingEmployees.dart
import 'package:flutter/material.dart';
import '../../../models/hr_reports_model.dart';
import '../../../api/api_service.dart';

import '../../../components/dynamic_form_config.dart';
import '../../../components/data_table_reusable.dart';
import '../../../components/create_data_dialog.dart';
import '../../../components/edit_data_dialog.dart';

class TopPerformingEmployeesTab extends StatelessWidget {
  final List<HrPerformer> topPerformers;
  final List<HrPerformer> bottomPerformers;
  final VoidCallback onRefresh;

  const TopPerformingEmployeesTab({
    super.key,
    required this.topPerformers,
    required this.bottomPerformers,
    required this.onRefresh,
  });

  static const Color _bgDark = Color(0xFF121212);
  static const Color _primaryAccent = Color(0xFF4361EE);
  static const Color _textGrey = Color(0xFFB3B3B3);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bgDark,
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              labelColor: _primaryAccent,
              unselectedLabelColor: _textGrey,
              indicatorColor: _primaryAccent,
              tabs: [
                Tab(icon: Icon(Icons.trending_up), text: "Top 5 Performers"),
                Tab(icon: Icon(Icons.trending_down), text: "Bottom 5 Performers"),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _PerformerTableOnly(
                    type: 'top',
                    performers: topPerformers,
                    onRefresh: onRefresh,
                  ),
                  _PerformerTableOnly(
                    type: 'bottom',
                    performers: bottomPerformers,
                    onRefresh: onRefresh,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PerformerTableOnly extends StatelessWidget {
  final String type;
  final List<HrPerformer> performers;
  final VoidCallback onRefresh;
  final ApiService _apiService = ApiService();

  _PerformerTableOnly({
    required this.type,
    required this.performers,
    required this.onRefresh,
  });

  static const Color _surfaceDark = Color(0xFF1E1E1E);
  static const Color _textWhite = Color(0xFFFFFFFF);
  static const Color _textGrey = Color(0xFFB3B3B3);
  static const Color _errorRed = Color(0xFFEF4444);

  void _openAddDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => CreateDataDialog(
        title: "Add ${type == 'top' ? 'Top' : 'Bottom'} Performer",
        maxItems: 5 - performers.length,
        fields: const [
          FormFieldConfig(key: "name", label: "Name"),
          FormFieldConfig(key: "designation", label: "Designation"),
          FormFieldConfig(key: "department", label: "Department"),
        ],
        onSubmit: (dataList) async {
          try {
            await _apiService.addHrPerformer({
              "type": type,
              "performers": dataList,
            });
            onRefresh();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Performer added!")),
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

  void _openEditDialog(BuildContext context, HrPerformer performer) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => EditDataDialog(
        title: "Edit Performer",
        fields: const [
          FormFieldConfig(key: "name", label: "Name"),
          FormFieldConfig(key: "designation", label: "Designation"),
          FormFieldConfig(key: "department", label: "Department"),
        ],
        initialData: {
          "name": performer.name,
          "designation": performer.designation,
          "department": performer.department,
        },
        onSubmit: (data) async {
          try {
            await _apiService.editHrPerformer(type, performer.id, data);
            onRefresh();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Performer updated!")),
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

  Future<void> _deletePerformer(BuildContext context, String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _surfaceDark,
        title: const Text("Remove Performer?", style: TextStyle(color: _textWhite)),
        content: const Text(
          "Are you sure you want to remove this employee from the list?",
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
        await _apiService.deleteHrPerformer(type, id);
        onRefresh();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Performer removed.")),
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
    bool isTop = type == 'top';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ReusableDataTable<HrPerformer>(
        title: "${isTop ? 'Top' : 'Bottom'} Performers List",
        addActionLabel: "Add ${isTop ? 'Top' : 'Bottom'}",
        // Disable Add if we already have 5 (Pass null to hide/disable)
        onAdd: performers.length >= 5 ? null : () => _openAddDialog(context),
        onEdit: (item) => _openEditDialog(context, item),
        onDelete: (item) => _deletePerformer(context, item.id),
        columns: const ["Name", "Designation", "Department"],
        data: performers,
        buildCells: (p) => [
          DataCell(Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold))),
          DataCell(Text(p.designation)),
          DataCell(Text(p.department)),
        ],
      ),
    );
  }
}