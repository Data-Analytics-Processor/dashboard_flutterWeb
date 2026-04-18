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

  void _openEditDialog(BuildContext context, NonTradeApproval approval) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _EditNonTradeDialog(
          approval: approval,
          onRefresh: onRefresh,
        );
      },
    );
  }

  Future<void> _deleteApproval(BuildContext context, String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Request?"),
        content: const Text("Are you sure you want to permanently delete this non-trade approval request?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true), 
            child: const Text("Delete", style: TextStyle(color: Colors.white))
          ),
        ],
      )
    );

    if (confirm == true) {
      try {
        await ApiService().deleteNonTradeApproval(id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Request deleted.")));
          onRefresh();
        }
      } catch (e) {
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              const Text(
                "Non-Trade Price Approvals",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => _openAddDialog(context),
                icon: const Icon(Icons.add, color: Colors.white, size: 18),
                label: const Text("Add New Prices", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A2540),
                ),
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
                  DataColumn(label: Text("Actions")),
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
                    DataCell(Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit, color: Colors.blue, size: 20), onPressed: () => _openEditDialog(context, a)),
                        IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 20), onPressed: () => _deleteApproval(context, a.id)),
                      ],
                    )),
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

class _EditNonTradeDialog extends StatefulWidget {
  final NonTradeApproval approval;
  final VoidCallback onRefresh;

  const _EditNonTradeDialog({required this.approval, required this.onRefresh});

  @override
  State<_EditNonTradeDialog> createState() => _EditNonTradeDialogState();
}

class _EditNonTradeDialogState extends State<_EditNonTradeDialog> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _partyNameCtrl;
  late TextEditingController _rateCtrl;
  late TextEditingController _unitCtrl;
  late String _status;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _partyNameCtrl = TextEditingController(text: widget.approval.partyName);
    _rateCtrl = TextEditingController(text: widget.approval.rate);
    _unitCtrl = TextEditingController(text: widget.approval.unit);
    _status = widget.approval.status;
  }

  @override
  void dispose() {
    _partyNameCtrl.dispose();
    _rateCtrl.dispose();
    _unitCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitEdit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final payload = {
        "partyName": _partyNameCtrl.text,
        "rate": _rateCtrl.text,
        "unit": _unitCtrl.text,
        "status": _status,
      };

      await _apiService.editNonTradeApproval(widget.approval.id, payload);

      widget.onRefresh();
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Approval updated!")));
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
        width: 400,
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
                  const Text("Edit Request", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
                ],
              ),
              const Divider(),
              TextFormField(
                controller: _partyNameCtrl, 
                decoration: const InputDecoration(labelText: "Party Name", border: OutlineInputBorder()), 
                validator: (v) => v!.isEmpty ? "Required" : null
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _rateCtrl, 
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Rate (₹)", border: OutlineInputBorder()), 
                      validator: (v) => v!.isEmpty ? "Required" : null
                    )
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _unitCtrl, 
                      decoration: const InputDecoration(labelText: "Unit", border: OutlineInputBorder()), 
                      validator: (v) => v!.isEmpty ? "Required" : null
                    )
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: "Status", border: OutlineInputBorder()),
                items: ['Pending', 'Approved', 'Rejected'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _status = val);
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitEdit,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0A2540), padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: _isSubmitting ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text("Update", style: TextStyle(color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}