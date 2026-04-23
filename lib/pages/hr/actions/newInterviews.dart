// lib/pages/hr/actions/newInterviews.dart
import 'package:flutter/material.dart';
import '../../../models/hr_reports_model.dart';
import '../../../api/api_service.dart';
import 'package:intl/intl.dart';

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
  static const Color _borderColor = Color(0xFF333333);
  static const Color _errorRed = Color(0xFFEF4444);

  void _openAddDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _AddInterviewsDialog(onRefresh: onRefresh);
      },
    );
  }

  void _openEditDialog(BuildContext context, HrInterview interview) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _EditInterviewDialog(interview: interview, onRefresh: onRefresh);
      },
    );
  }

  Future<void> _deleteInterview(BuildContext context, String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _surfaceDark,
        title: const Text(
          "Delete Interview?",
          style: TextStyle(color: _textWhite),
        ),
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

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Interview deleted."),
              backgroundColor: _surfaceDark,
            ),
          );
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
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                const Text(
                  "Scheduled Interviews",
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
                    "Add New Interviews",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryAccent,
                    elevation: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
                    DataColumn(label: Text("Name")),
                    DataColumn(label: Text("Designation")),
                    DataColumn(label: Text("Department")),
                    DataColumn(label: Text("Date")),
                    DataColumn(label: Text("Actions")),
                  ],
                  rows: interviews.asMap().entries.map((entry) {
                    HrInterview i = entry.value;
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            i.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataCell(Text(i.designation)),
                        DataCell(Text(i.department)),
                        DataCell(
                          Text(
                            i.dateOfInterview,
                            style: const TextStyle(color: _primaryAccent),
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
                                onPressed: () => _openEditDialog(context, i),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: _errorRed,
                                  size: 20,
                                ),
                                onPressed: () =>
                                    _deleteInterview(context, i.id),
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

class InterviewControllers {
  final TextEditingController name = TextEditingController();
  final TextEditingController desig = TextEditingController();
  final TextEditingController dept = TextEditingController();
  final TextEditingController date = TextEditingController();

  void dispose() {
    name.dispose();
    desig.dispose();
    dept.dispose();
    date.dispose();
  }
}

// ================= ADD DIALOG =================

class _AddInterviewsDialog extends StatefulWidget {
  final VoidCallback onRefresh;
  const _AddInterviewsDialog({required this.onRefresh});

  @override
  State<_AddInterviewsDialog> createState() => _AddInterviewsDialogState();
}

class _AddInterviewsDialogState extends State<_AddInterviewsDialog> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final List<InterviewControllers> _entries = [InterviewControllers()];
  bool _isSubmitting = false;

  // --- DARK COLORS ---
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

  Future<void> _selectDate(TextEditingController ctrl) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: _primaryAccent,
              surface: _surfaceDark,
              onSurface: _textWhite,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        ctrl.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _submitBatch() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final payloadList = _entries
          .map(
            (e) => {
              "name": e.name.text,
              "designation": e.desig.text,
              "department": e.dept.text,
              "dateOfInterview": e.date.text,
            },
          )
          .toList();

      final success = await _apiService.addHrInterview({
        "interviews": payloadList,
      });

      if (success) {
        widget.onRefresh();
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Interviews added!")));
        }
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Schedule New Interviews",
                    style: TextStyle(
                      color: _textWhite,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: _textGrey),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(color: _borderColor),

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
                                controller: entry.name,
                                decoration: _inputStyle(
                                  "Candidate Name #${index + 1}",
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
                                controller: entry.desig,
                                decoration: _inputStyle("Designation"),
                                style: const TextStyle(color: _textWhite),
                                validator: (v) => v!.isEmpty ? "Req" : null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: entry.dept,
                                decoration: _inputStyle("Department"),
                                style: const TextStyle(color: _textWhite),
                                validator: (v) => v!.isEmpty ? "Req" : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: entry.date,
                          readOnly: true,
                          onTap: () => _selectDate(entry.date),
                          decoration: _inputStyle("Date").copyWith(
                            suffixIcon: const Icon(
                              Icons.calendar_today,
                              color: _textGrey,
                            ),
                          ),
                          style: const TextStyle(color: _textWhite),
                          validator: (v) => v!.isEmpty ? "Req" : null,
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
                    onPressed: () =>
                        setState(() => _entries.add(InterviewControllers())),
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
                            "Save All (${_entries.length})",
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

// ================= EDIT DIALOG =================

class _EditInterviewDialog extends StatefulWidget {
  final HrInterview interview;
  final VoidCallback onRefresh;

  const _EditInterviewDialog({
    required this.interview,
    required this.onRefresh,
  });

  @override
  State<_EditInterviewDialog> createState() => _EditInterviewDialogState();
}

class _EditInterviewDialogState extends State<_EditInterviewDialog> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  late InterviewControllers entry;
  bool _isSubmitting = false;

  static const Color _surfaceDark = Color(0xFF1E1E1E);
  static const Color _primaryAccent = Color(0xFF4361EE);
  static const Color _textWhite = Color(0xFFFFFFFF);
  static const Color _textGrey = Color(0xFFB3B3B3);
  static const Color _borderColor = Color(0xFF333333);

  @override
  void initState() {
    super.initState();
    entry = InterviewControllers();
    entry.name.text = widget.interview.name;
    entry.desig.text = widget.interview.designation;
    entry.dept.text = widget.interview.department;
    entry.date.text = widget.interview.dateOfInterview;
  }

  @override
  void dispose() {
    entry.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        entry.date.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
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
      await _apiService.editHrInterview(widget.interview.id, {
        "name": entry.name.text,
        "designation": entry.desig.text,
        "department": entry.dept.text,
        "dateOfInterview": entry.date.text,
      });

      widget.onRefresh();
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Interview updated!")));
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Edit Interview",
                    style: TextStyle(
                      color: _textWhite,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: _textGrey),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(color: _borderColor),

              TextFormField(
                controller: entry.name,
                decoration: _inputStyle("Candidate Name"),
                style: const TextStyle(color: _textWhite),
                validator: (v) => v!.isEmpty ? "Req" : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: entry.desig,
                decoration: _inputStyle("Designation"),
                style: const TextStyle(color: _textWhite),
                validator: (v) => v!.isEmpty ? "Req" : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: entry.dept,
                decoration: _inputStyle("Department"),
                style: const TextStyle(color: _textWhite),
                validator: (v) => v!.isEmpty ? "Req" : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: entry.date,
                readOnly: true,
                onTap: _selectDate,
                decoration: _inputStyle("Date").copyWith(
                  suffixIcon: const Icon(
                    Icons.calendar_today,
                    color: _textGrey,
                  ),
                ),
                style: const TextStyle(color: _textWhite),
                validator: (v) => v!.isEmpty ? "Req" : null,
              ),

              const SizedBox(height: 24),

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
