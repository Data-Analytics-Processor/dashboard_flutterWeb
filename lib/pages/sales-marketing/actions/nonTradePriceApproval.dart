// lib/pages/sales-marketing/actions/nonTradePriceApproval.dart
import 'package:flutter/material.dart';
import '../../../models/sales_reports_model.dart';
import '../../../api/api_service.dart';
import 'package:intl/intl.dart';

class NonTradeApprovalTab extends StatelessWidget {
  final List<NonTradeApproval> approvals;
  final VoidCallback onRefresh;

  const NonTradeApprovalTab({super.key, required this.approvals, required this.onRefresh});

  void _openAddDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _AddNonTradeDialog(onRefresh: onRefresh);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Non-Trade Price Approvals", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () => _openAddDialog(context),
                icon: const Icon(Icons.add, color: Colors.white, size: 18),
                label: const Text("New Request", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0A2540)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text("Party Name")),
                  DataColumn(label: Text("Rate")),
                  DataColumn(label: Text("Unit (MT)")),
                  DataColumn(label: Text("Status")),
                  DataColumn(label: Text("Date Submitted")),
                ],
                rows: approvals.map((a) {
                  final date = DateTime.tryParse(a.submittedAt);
                  final formattedDate = date != null ? DateFormat('dd MMM yyyy').format(date) : a.submittedAt;
                  
                  return DataRow(cells: [
                    DataCell(Text(a.partyName, style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text("₹${a.rate}", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))),
                    DataCell(Text(a.unit)),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: a.status.toLowerCase() == 'pending' ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          a.status, 
                          style: TextStyle(
                            color: a.status.toLowerCase() == 'pending' ? Colors.orange.shade800 : Colors.green.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 12
                          )
                        ),
                      )
                    ),
                    DataCell(Text(formattedDate, style: const TextStyle(color: Colors.grey, fontSize: 12))),
                  ]);
                }).toList(),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// --- HELPER & DIALOG ---
class ApprovalControllers {
  final TextEditingController partyName = TextEditingController();
  final TextEditingController rate = TextEditingController();
  final TextEditingController unit = TextEditingController(text: 'MT');
  void dispose() { partyName.dispose(); rate.dispose(); unit.dispose(); }
}

class _AddNonTradeDialog extends StatefulWidget {
  final VoidCallback onRefresh;
  const _AddNonTradeDialog({required this.onRefresh});

  @override
  State<_AddNonTradeDialog> createState() => _AddNonTradeDialogState();
}

class _AddNonTradeDialogState extends State<_AddNonTradeDialog> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final List<ApprovalControllers> _entries = [ApprovalControllers()];
  bool _isSubmitting = false;

  @override
  void dispose() {
    for (var entry in _entries) { entry.dispose(); }
    super.dispose();
  }

  Future<void> _submitBatch() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final payloadList = _entries.map((e) => {
        "partyName": e.partyName.text,
        "rate": e.rate.text,
        "unit": e.unit.text,
        "status": "Approved",
      }).toList();

      final success = await _apiService.addNonTradeApprovals({
        "approvals": payloadList 
      });

      if (success) {
        widget.onRefresh();
        if (mounted) {
          Navigator.of(context).pop(); 
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Approvals submitted!")));
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600, 
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("New Non-Trade Request", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
                ],
              ),
              const Divider(),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _entries.length,
                  separatorBuilder: (_, __) => const Divider(height: 32),
                  itemBuilder: (context, index) {
                    final entry = _entries[index];
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: TextFormField(controller: entry.partyName, decoration: InputDecoration(labelText: "Party Name #${index + 1}", border: const OutlineInputBorder()), validator: (v) => v!.isEmpty ? "Req" : null)),
                            if (_entries.length > 1) IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() { _entries[index].dispose(); _entries.removeAt(index); }))
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: TextFormField(controller: entry.rate, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Rate (₹)", border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? "Req" : null)),
                            const SizedBox(width: 8),
                            Expanded(child: TextFormField(controller: entry.unit, keyboardType: TextInputType.text, decoration: const InputDecoration(labelText: "Unit", border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? "Req" : null)),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () => setState(() => _entries.add(ApprovalControllers())),
                    icon: const Icon(Icons.add), label: const Text("Add Another")
                  ),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitBatch,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0A2540)),
                    child: _isSubmitting ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text("Submit (${_entries.length})", style: const TextStyle(color: Colors.white)),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}