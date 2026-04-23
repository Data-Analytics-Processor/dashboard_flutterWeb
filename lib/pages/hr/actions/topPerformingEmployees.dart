// lib/pages/hr/actions/topPerformingEmployees.dart
import 'package:flutter/material.dart';
import '../../../models/hr_reports_model.dart';
import '../../../api/api_service.dart';

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

  // --- DARK THEME ---
  static const Color _bgDark = Color(0xFF121212);
  // static const Color _surfaceDark = Color(0xFF1E1E1E);
  static const Color _primaryAccent = Color(0xFF4361EE);
  // static const Color _textWhite = Color(0xFFFFFFFF);
  static const Color _textGrey = Color(0xFFB3B3B3);
  // static const Color _borderColor = Color(0xFF333333);

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

  // --- DARK THEME ---
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
      builder: (_) => _AddPerformersDialog(
        type: type,
        currentCount: performers.length,
        onRefresh: onRefresh,
      ),
    );
  }

  void _openEditDialog(BuildContext context, HrPerformer performer) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _EditPerformerDialog(
        type: type,
        performer: performer,
        onRefresh: onRefresh,
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
      await _apiService.deleteHrPerformer(type, id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Performer removed.")),
        );
        onRefresh();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isTop = type == 'top';
    Color themeColor = isTop ? _primaryAccent : _errorRed;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            children: [
              Text(
                "${isTop ? 'Top' : 'Bottom'} Performers List",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _textWhite,
                ),
              ),
              ElevatedButton.icon(
                onPressed: performers.length >= 5
                    ? null
                    : () => _openAddDialog(context),
                icon: const Icon(Icons.add, color: Colors.white, size: 18),
                label: Text(
                  "Add ${isTop ? 'Top' : 'Bottom'}",
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(backgroundColor: themeColor),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Container(
            decoration: BoxDecoration(
              color: _surfaceDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            child: DataTable(
              headingTextStyle: const TextStyle(color: _textGrey),
              dataTextStyle: const TextStyle(color: _textWhite),
              columns: const [
                DataColumn(label: Text("Name")),
                DataColumn(label: Text("Designation")),
                DataColumn(label: Text("Department")),
                DataColumn(label: Text("Actions")),
              ],
              rows: performers.map((p) {
                return DataRow(cells: [
                  DataCell(Text(p.name,
                      style:
                          const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(p.designation)),
                  DataCell(Text(p.department)),
                  DataCell(Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit,
                            color: _primaryAccent),
                        onPressed: () =>
                            _openEditDialog(context, p),
                      ),
                      IconButton(
                        icon:
                            const Icon(Icons.delete, color: _errorRed),
                        onPressed: () =>
                            _deletePerformer(context, p.id),
                      ),
                    ],
                  )),
                ]);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class PerformerControllers {
  final TextEditingController name = TextEditingController();
  final TextEditingController desig = TextEditingController();
  final TextEditingController dept = TextEditingController();
  void dispose() {
    name.dispose();
    desig.dispose();
    dept.dispose();
  }
}
class _AddPerformersDialog extends StatefulWidget {
  final String type;
  final int currentCount;
  final VoidCallback onRefresh;

  const _AddPerformersDialog({
    required this.type,
    required this.currentCount,
    required this.onRefresh,
  });

  @override
  State<_AddPerformersDialog> createState() =>
      _AddPerformersDialogState();
}

class _AddPerformersDialogState extends State<_AddPerformersDialog> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final List<PerformerControllers> _entries = [PerformerControllers()];
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

  void _addEntry() {
    if (_entries.length < (5 - widget.currentCount)) {
      setState(() => _entries.add(PerformerControllers()));
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

  Future<void> _submitBatch() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final payload = _entries.map((e) => {
            "name": e.name.text,
            "designation": e.desig.text,
            "department": e.dept.text,
          }).toList();

      final success = await _apiService.addHrPerformer({
        "type": widget.type,
        "performers": payload,
      });

      if (success) {
        widget.onRefresh();
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Performers added!")),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isTop = widget.type == 'top';
    int maxAllowed = 5 - widget.currentCount;

    return Dialog(
      backgroundColor: _surfaceDark,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Add ${isTop ? 'Top' : 'Bottom'} Performers",
                    style: const TextStyle(
                        color: _textWhite,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon:
                        const Icon(Icons.close, color: _textGrey),
                    onPressed: () =>
                        Navigator.of(context).pop(),
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
                                decoration:
                                    _inputStyle("Name #${index + 1}"),
                                style: const TextStyle(
                                    color: _textWhite),
                                validator: (v) =>
                                    v!.isEmpty ? "Req" : null,
                              ),
                            ),
                            if (_entries.length > 1)
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: _errorRed),
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
                                decoration:
                                    _inputStyle("Designation"),
                                style: const TextStyle(
                                    color: _textWhite),
                                validator: (v) =>
                                    v!.isEmpty ? "Req" : null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: entry.dept,
                                decoration:
                                    _inputStyle("Department"),
                                style: const TextStyle(
                                    color: _textWhite),
                                validator: (v) =>
                                    v!.isEmpty ? "Req" : null,
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

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed:
                        _entries.length < maxAllowed ? _addEntry : null,
                    icon: const Icon(Icons.add,
                        color: _primaryAccent),
                    label: Text(
                      "Add Row (${maxAllowed - _entries.length} left)",
                      style:
                          const TextStyle(color: _primaryAccent),
                    ),
                  ),
                  ElevatedButton(
                    onPressed:
                        _isSubmitting ? null : _submitBatch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryAccent,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child:
                                CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            "Save (${_entries.length})",
                            style: const TextStyle(
                                color: Colors.white),
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

// ================= EDIT =================

class _EditPerformerDialog extends StatefulWidget {
  final String type;
  final HrPerformer performer;
  final VoidCallback onRefresh;

  const _EditPerformerDialog({
    required this.type,
    required this.performer,
    required this.onRefresh,
  });

  @override
  State<_EditPerformerDialog> createState() =>
      _EditPerformerDialogState();
}

class _EditPerformerDialogState
    extends State<_EditPerformerDialog> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  late PerformerControllers entry;
  bool _isSubmitting = false;

  static const Color _surfaceDark = Color(0xFF1E1E1E);
  static const Color _primaryAccent = Color(0xFF4361EE);
  static const Color _textWhite = Color(0xFFFFFFFF);
  static const Color _textGrey = Color(0xFFB3B3B3);
  static const Color _borderColor = Color(0xFF333333);

  @override
  void initState() {
    super.initState();
    entry = PerformerControllers();
    entry.name.text = widget.performer.name;
    entry.desig.text = widget.performer.designation;
    entry.dept.text = widget.performer.department;
  }

  @override
  void dispose() {
    entry.dispose();
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
      await _apiService.editHrPerformer(
        widget.type,
        widget.performer.id,
        {
          "name": entry.name.text,
          "designation": entry.desig.text,
          "department": entry.dept.text,
        },
      );

      widget.onRefresh();
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Performer updated!")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: _surfaceDark,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Edit Performer",
                    style: TextStyle(
                        color: _textWhite,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon:
                        const Icon(Icons.close, color: _textGrey),
                    onPressed: () =>
                        Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(color: _borderColor),

              TextFormField(
                controller: entry.name,
                decoration: _inputStyle("Name"),
                style:
                    const TextStyle(color: _textWhite),
                validator: (v) =>
                    v!.isEmpty ? "Req" : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: entry.desig,
                decoration: _inputStyle("Designation"),
                style:
                    const TextStyle(color: _textWhite),
                validator: (v) =>
                    v!.isEmpty ? "Req" : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: entry.dept,
                decoration: _inputStyle("Department"),
                style:
                    const TextStyle(color: _textWhite),
                validator: (v) =>
                    v!.isEmpty ? "Req" : null,
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _isSubmitting ? null : _submitEdit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryAccent,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child:
                              CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Update",
                          style:
                              TextStyle(color: Colors.white),
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