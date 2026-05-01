// lib/components/create_data_dialog.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dynamic_form_config.dart';

class CreateDataDialog extends StatefulWidget {
  final String title;
  final List<FormFieldConfig> fields;
  final Future<void> Function(List<Map<String, dynamic>> dataList) onSubmit;
  final int? maxItems; // Use this to limit additions (e.g., Top 5 Performers)

  const CreateDataDialog({
    super.key,
    required this.title,
    required this.fields,
    required this.onSubmit,
    this.maxItems,
  });

  @override
  State<CreateDataDialog> createState() => _CreateDataDialogState();
}

class _CreateDataDialogState extends State<CreateDataDialog> {
  final _formKey = GlobalKey<FormState>();
  final List<Map<String, TextEditingController>> _entries = [];
  bool _isSubmitting = false;

  // --- DARK THEME COLORS ---
  static const Color _surfaceDark = Color(0xFF1E1E1E);
  static const Color _primaryAccent = Color(0xFF4361EE);
  static const Color _textWhite = Color(0xFFFFFFFF);
  static const Color _textGrey = Color(0xFFB3B3B3);
  static const Color _borderColor = Color(0xFF333333);
  static const Color _errorRed = Color(0xFFEF4444);

  @override
  void initState() {
    super.initState();
    _addEntry();
  }

  void _addEntry() {
    if (widget.maxItems != null && _entries.length >= widget.maxItems!) return;
    
    final newEntry = <String, TextEditingController>{};
    for (var field in widget.fields) {
      newEntry[field.key] = TextEditingController();
    }
    setState(() => _entries.add(newEntry));
  }

  void _removeEntry(int index) {
    for (var controller in _entries[index].values) {
      controller.dispose();
    }
    setState(() => _entries.removeAt(index));
  }

  @override
  void dispose() {
    for (var entry in _entries) {
      for (var controller in entry.values) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  Future<void> _selectDate(TextEditingController ctrl) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
    );
    if (picked != null) {
      setState(() {
        ctrl.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final payloadList = _entries.map((entry) {
        final payload = <String, dynamic>{};
        for (var field in widget.fields) {
          payload[field.key] = entry[field.key]!.text;
        }
        return payload;
      }).toList();

      await widget.onSubmit(payloadList);
      if (mounted) Navigator.of(context).pop();
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
      enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: _borderColor)),
      focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: _primaryAccent, width: 1.5)),
    );
  }

  Widget _buildField(FormFieldConfig field, Map<String, TextEditingController> entry) {
    final ctrl = entry[field.key]!;

    if (field.type == FormFieldType.dropdown && field.dropdownOptions != null) {
      return DropdownButtonFormField<String>(
        decoration: _inputStyle(field.label),
        dropdownColor: _surfaceDark,
        style: const TextStyle(color: _textWhite),
        validator: (v) => field.isRequired && (v == null || v.isEmpty) ? "Required" : null,
        items: field.dropdownOptions!.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
        onChanged: (val) {
          if (val != null) ctrl.text = val;
        },
      );
    }

    return TextFormField(
      controller: ctrl,
      readOnly: field.type == FormFieldType.date,
      onTap: field.type == FormFieldType.date ? () => _selectDate(ctrl) : null,
      keyboardType: field.type == FormFieldType.number ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: _textWhite),
      decoration: _inputStyle(field.label).copyWith(
        suffixIcon: field.type == FormFieldType.date ? const Icon(Icons.calendar_today, color: _textGrey) : null,
      ),
      validator: (v) => field.isRequired && v!.isEmpty ? "Required" : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    bool canAddMore = widget.maxItems == null || _entries.length < widget.maxItems!;

    return Dialog(
      backgroundColor: _surfaceDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
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
                  Text(
                    widget.title,
                    style: const TextStyle(color: _textWhite, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: _textGrey),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(color: _borderColor),

              // --- BATCH ENTRY LIST ---
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _entries.length,
                  separatorBuilder: (_, __) => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Divider(color: _borderColor),
                  ),
                  itemBuilder: (context, index) {
                    final entry = _entries[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Entry #${index + 1}", style: const TextStyle(color: _primaryAccent, fontWeight: FontWeight.bold)),
                            if (_entries.length > 1)
                              IconButton(
                                icon: const Icon(Icons.delete, color: _errorRed, size: 20),
                                onPressed: () => _removeEntry(index),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...widget.fields.map((field) => Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: _buildField(field, entry),
                            )),
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
                    onPressed: canAddMore ? _addEntry : null,
                    icon: const Icon(Icons.add, color: _primaryAccent),
                    label: Text(
                      widget.maxItems != null 
                        ? "Add Another (${widget.maxItems! - _entries.length} left)"
                        : "Add Another",
                      style: const TextStyle(color: _primaryAccent),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text("Save All (${_entries.length})", style: const TextStyle(color: Colors.white)),
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