// lib/pages/sales-marketing/actions/nonTradePriceApproval.dart
import 'package:flutter/material.dart';
import '../../../models/sales_reports_model.dart';
import '../../../api/api_service.dart';
import 'package:intl/intl.dart';

class NonTradeApprovalTab extends StatelessWidget {
  final List<NonTradeApproval> approvals;
  final VoidCallback onRefresh;

  const NonTradeApprovalTab({
    super.key,
    required this.approvals,
    required this.onRefresh,
  });

  // --- DARK THEME ---
  static const Color _bgDark = Color(0xFF121212);
  static const Color _surfaceDark = Color(0xFF1E1E1E);
  static const Color _primaryAccent = Color(0xFF4361EE);
  static const Color _textWhite = Color(0xFFFFFFFF);
  static const Color _textGrey = Color(0xFFB3B3B3);
  static const Color _borderColor = Color(0xFF333333);
  static const Color _errorRed = Color(0xFFEF4444);

  void _openAddDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _AddNonTradeDialog(onRefresh: onRefresh),
    );
  }

  void _openEditDialog(BuildContext context, NonTradeApproval approval) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          _EditNonTradeDialog(approval: approval, onRefresh: onRefresh),
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
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Request deleted.")));
          onRefresh();
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
    return Container(
      color: _bgDark,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER ---
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                const Text(
                  "Non-Trade Price Approvals",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _textWhite,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _openAddDialog(context),
                  icon: const Icon(Icons.add, color: Colors.white, size: 18),
                  label: const Text(
                    "Add New Prices",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryAccent,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // --- TABLE ---
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: _surfaceDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingTextStyle: const TextStyle(
                    color: _textGrey,
                    fontWeight: FontWeight.w600,
                  ),
                  dataTextStyle: const TextStyle(color: _textWhite),
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
                    final formattedDate = date != null
                        ? DateFormat('dd MMM yyyy').format(date)
                        : a.submittedAt;

                    final isPending = a.status.toLowerCase() == 'pending';

                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            a.partyName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataCell(
                          Text(
                            "₹${a.rate}",
                            style: const TextStyle(
                              color: _primaryAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataCell(Text(a.unit)),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isPending
                                  ? Colors.orange.withOpacity(0.15)
                                  : Colors.green.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              a.status,
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
                            style: const TextStyle(
                              color: _textGrey,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: _primaryAccent,
                                  size: 20,
                                ),
                                onPressed: () => _openEditDialog(context, a),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: _errorRed,
                                  size: 20,
                                ),
                                onPressed: () => _deleteApproval(context, a.id),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ApprovalControllers {
  final TextEditingController partyName = TextEditingController();
  final TextEditingController rate = TextEditingController();
  final TextEditingController unit = TextEditingController(text: 'MT');
  void dispose() {
    partyName.dispose();
    rate.dispose();
    unit.dispose();
  }
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

  // --- DARK THEME ---
  static const Color _surfaceDark = Color(0xFF1E1E1E);
  static const Color _primaryAccent = Color(0xFF4361EE);
  static const Color _textWhite = Color(0xFFFFFFFF);
  static const Color _textGrey = Color(0xFFB3B3B3);
  static const Color _borderColor = Color(0xFF333333);
  static const Color _errorRed = Color(0xFFEF4444);

  @override
  void dispose() {
    for (var entry in _entries) {
      entry.dispose();
    }
    super.dispose();
  }

  InputDecoration _inputStyle(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: _textGrey),
      filled: true,
      fillColor: _surfaceDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _borderColor),
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: _borderColor),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: _primaryAccent, width: 1.5),
      ),
    );
  }

  Future<void> _submitBatch() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final payloadList = _entries
          .map(
            (e) => {
              "partyName": e.partyName.text,
              "rate": e.rate.text,
              "unit": e.unit.text,
              "status": "Approved",
            },
          )
          .toList();

      final success = await _apiService.addNonTradeApprovals({
        "approvals": payloadList,
      });

      if (success) {
        widget.onRefresh();
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Approvals submitted!")));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: _surfaceDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- HEADER ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "New Non-Trade Request",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _textWhite,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: _textGrey),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),

              const Divider(color: _borderColor),

              // --- FORM LIST ---
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _entries.length,
                  separatorBuilder: (_, __) =>
                      const Divider(color: _borderColor),
                  itemBuilder: (context, index) {
                    final entry = _entries[index];

                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: entry.partyName,
                                decoration: _inputStyle(
                                  "Party Name #${index + 1}",
                                ),
                                style: const TextStyle(color: _textWhite),
                                validator: (v) => v!.isEmpty ? "Req" : null,
                              ),
                            ),
                            if (_entries.length > 1)
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: _errorRed,
                                ),
                                onPressed: () => setState(() {
                                  _entries[index].dispose();
                                  _entries.removeAt(index);
                                }),
                              ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: entry.rate,
                                keyboardType: TextInputType.number,
                                decoration: _inputStyle("Rate (₹)"),
                                style: const TextStyle(color: _textWhite),
                                validator: (v) => v!.isEmpty ? "Req" : null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: entry.unit,
                                decoration: _inputStyle("Unit"),
                                style: const TextStyle(color: _textWhite),
                                validator: (v) => v!.isEmpty ? "Req" : null,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // --- ACTIONS ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () =>
                        setState(() => _entries.add(ApprovalControllers())),
                    icon: const Icon(Icons.add, color: _primaryAccent),
                    label: const Text(
                      "Add Another",
                      style: TextStyle(color: _primaryAccent),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitBatch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryAccent,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            "Submit (${_entries.length})",
                            style: const TextStyle(color: Colors.white),
                          ),
                  ),
                ],
              ),
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

  // --- DARK THEME ---
  static const Color _surfaceDark = Color(0xFF1E1E1E);
  static const Color _primaryAccent = Color(0xFF4361EE);
  static const Color _textWhite = Color(0xFFFFFFFF);
  static const Color _textGrey = Color(0xFFB3B3B3);
  static const Color _borderColor = Color(0xFF333333);

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

  InputDecoration _inputStyle(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: _textGrey),
      filled: true,
      fillColor: _surfaceDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _borderColor),
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: _borderColor),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: _primaryAccent, width: 1.5),
      ),
    );
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Approval updated!")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: _surfaceDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- HEADER ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Edit Request",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _textWhite,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: _textGrey),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),

              const Divider(color: _borderColor),

              // --- FORM ---
              TextFormField(
                controller: _partyNameCtrl,
                decoration: _inputStyle("Party Name"),
                style: const TextStyle(color: _textWhite),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _rateCtrl,
                      keyboardType: TextInputType.number,
                      decoration: _inputStyle("Rate (₹)"),
                      style: const TextStyle(color: _textWhite),
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _unitCtrl,
                      decoration: _inputStyle("Unit"),
                      style: const TextStyle(color: _textWhite),
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: _status,
                dropdownColor: _surfaceDark,
                style: const TextStyle(color: _textWhite),
                decoration: _inputStyle("Status"),
                items: ['Pending', 'Approved', 'Rejected']
                    .map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text(
                          s,
                          style: const TextStyle(color: _textWhite),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _status = val);
                },
              ),

              const SizedBox(height: 24),

              // --- ACTION ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitEdit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Update",
                          style: TextStyle(color: Colors.white),
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
