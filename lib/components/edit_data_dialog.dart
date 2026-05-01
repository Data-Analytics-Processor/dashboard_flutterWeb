// lib/components/edit_data_dialog.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dynamic_form_config.dart';

class EditDataDialog extends StatefulWidget {
  final String title;
  final List<FormFieldConfig> fields;
  final Map<String, dynamic> initialData;
  final Future<void> Function(Map<String, dynamic> data) onSubmit;

  const EditDataDialog({
    super.key,
    required this.title,
    required this.fields,
    required this.initialData,
    required this.onSubmit,
  });

  @override
  State<EditDataDialog> createState() => _EditDataDialogState();
}

class _EditDataDialogState extends State<EditDataDialog> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  bool _isSubmitting = false;

  static const Color _surfaceDark = Color(0xFF1E1E1E);
  static const Color _primaryAccent = Color(0xFF4361EE);
  static const Color _textWhite = Color(0xFFFFFFFF);
  static const Color _textGrey = Color(0xFFB3B3B3);
  static const Color _borderColor = Color(0xFF333333);

  @override
  void initState() {
    super.initState();
    for (var field in widget.fields) {
      _controllers[field.key] = TextEditingController(
        text: widget.initialData[field.key]?.toString() ?? '',
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _selectDate(TextEditingController ctrl) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(ctrl.text) ?? DateTime.now(),
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
      final payload = <String, dynamic>{};
      for (var field in widget.fields) {
        payload[field.key] = _controllers[field.key]!.text;
      }
      await widget.onSubmit(payload);
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

  Widget _buildField(FormFieldConfig field) {
    final ctrl = _controllers[field.key]!;

    if (field.type == FormFieldType.dropdown && field.dropdownOptions != null) {
      return DropdownButtonFormField<String>(
        value: ctrl.text.isNotEmpty ? ctrl.text : null,
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
              ...widget.fields.map((field) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: _buildField(field),
                  )),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("Update", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
