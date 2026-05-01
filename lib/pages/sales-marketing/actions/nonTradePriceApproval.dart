// lib/pages/sales-marketing/actions/nonTradePriceApproval.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/sales_reports_model.dart';
import '../../../api/api_service.dart';

import '../../../components/dynamic_form_config.dart';
import '../../../components/data_table_reusable.dart';
import '../../../components/create_data_dialog.dart';
import '../../../components/edit_data_dialog.dart';

class NonTradeApprovalTab extends StatelessWidget {
  final List<NonTradeApproval> approvals;
  final VoidCallback onRefresh;

  const NonTradeApprovalTab({
    super.key,
    required this.approvals,
    required this.onRefresh,
  });

  // --- DARK THEME ---
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
        title: "New Non-Trade Request",
        fields: const [
          FormFieldConfig(key: "partyName", label: "Party Name"),
          FormFieldConfig(
            key: "rate",
            label: "Rate (₹)",
            type: FormFieldType.number,
          ),
          FormFieldConfig(key: "unit", label: "Unit (e.g. MT)"),
        ],
        onSubmit: (dataList) async {
          try {
            // Inject the default status into every item in the batch
            final payload = dataList.map((data) {
              data['status'] = 'Approved';
              return data;
            }).toList();

            await ApiService().addNonTradeApprovals({"approvals": payload});

            onRefresh();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Approvals submitted!")),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("Error: $e")));
            }
          }
        },
      ),
    );
  }

  void _openEditDialog(BuildContext context, NonTradeApproval approval) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => EditDataDialog(
        title: "Edit Request",
        fields: const [
          FormFieldConfig(key: "partyName", label: "Party Name"),
          FormFieldConfig(
            key: "rate",
            label: "Rate (₹)",
            type: FormFieldType.number,
          ),
          FormFieldConfig(key: "unit", label: "Unit"),
          FormFieldConfig(
            key: "status",
            label: "Status",
            type: FormFieldType.dropdown,
            dropdownOptions: ['Pending', 'Approved', 'Rejected'],
          ),
        ],
        initialData: {
          "partyName": approval.partyName,
          "rate": approval.rate,
          "unit": approval.unit,
          "status": approval.status,
        },
        onSubmit: (data) async {
          try {
            await ApiService().editNonTradeApproval(approval.id, data);
            onRefresh();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Approval updated!")),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("Error: $e")));
            }
          }
        },
      ),
    );
  }

  Future<void> _deleteApproval(BuildContext context, String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _surfaceDark,
        title: const Text(
          "Delete Request?",
          style: TextStyle(color: _textWhite),
        ),
        content: const Text(
          "Are you sure you want to permanently delete this non-trade approval request?",
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
        await ApiService().deleteNonTradeApproval(id);
        onRefresh();
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Request deleted.")));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error: $e")));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ReusableDataTable<NonTradeApproval>(
        title: "Non-Trade Price Approvals",
        addActionLabel: "Add New Prices",
        onAdd: () => _openAddDialog(context),
        onEdit: (item) => _openEditDialog(context, item),
        onDelete: (item) => _deleteApproval(context, item.id),
        columns: const [
          "Party Name",
          "Rate",
          "Unit (MT)",
          "Status",
          "Date Submitted",
        ],
        data: approvals,
        buildCells: (item) {
          final date = DateTime.tryParse(item.submittedAt);
          final formattedDate = date != null
              ? DateFormat('dd MMM yyyy').format(date)
              : item.submittedAt;

          final isPending = item.status.toLowerCase() == 'pending';

          return [
            DataCell(
              Text(
                item.partyName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataCell(
              Text(
                "₹${item.rate}",
                style: const TextStyle(
                  color: _primaryAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            DataCell(Text(item.unit)),
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPending
                      ? Colors.orange.withOpacity(0.15)
                      : Colors.green.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.status,
                  style: TextStyle(
                    color: isPending ? Colors.orange : Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            DataCell(
              Text(
                formattedDate,
                style: const TextStyle(color: _textGrey, fontSize: 12),
              ),
            ),
          ];
        },
      ),
    );
  }
}
