// lib/pages/hr/actions/newInterviews.dart
import 'package:flutter/material.dart';
import '../../../models/hr_reports_model.dart';
import '../../../api/api_service.dart';
import 'package:intl/intl.dart';

class NewInterviewsTab extends StatelessWidget {
  final List<HrInterview> interviews;
  final VoidCallback onRefresh;

  const NewInterviewsTab({super.key, required this.interviews, required this.onRefresh});

  void _openAddDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _AddInterviewsDialog(onRefresh: onRefresh);
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
              const Text("Scheduled Interviews", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () => _openAddDialog(context),
                icon: const Icon(Icons.add, color: Colors.white, size: 18),
                label: const Text("Schedule Interviews", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0A2540)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Data Table
          Container(
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text("Name")),
                  DataColumn(label: Text("Designation")),
                  DataColumn(label: Text("Department")),
                  DataColumn(label: Text("Date")),
                ],
                rows: interviews.map((i) => DataRow(cells: [
                  DataCell(Text(i.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(i.designation)),
                  DataCell(Text(i.department)),
                  DataCell(Text(i.dateOfInterview, style: const TextStyle(color: Colors.blue))),
                ])).toList(),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// --- HELPER CLASS FOR BATCH FORMS ---
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

// --- THE DIALOG MODAL ---
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

  @override
  void dispose() {
    for (var entry in _entries) { entry.dispose(); }
    super.dispose();
  }

  Future<void> _selectDate(TextEditingController ctrl) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
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
      final payloadList = _entries.map((e) => {
        "name": e.name.text,
        "designation": e.desig.text,
        "department": e.dept.text,
        "dateOfInterview": e.date.text,
      }).toList();

      final success = await _apiService.addHrInterview({
        "interviews": payloadList // Batch payload
      });

      if (success) {
        widget.onRefresh();
        if (mounted) {
          Navigator.of(context).pop(); // Close dialog on success
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Interviews added!")));
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
        width: 600, // Good max width for Web, scales down on Android automatically
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
                  const Text("Schedule New Interviews", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
                ],
              ),
              const Divider(),
              // Scrollable Form List
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
                            Expanded(child: TextFormField(controller: entry.name, decoration: InputDecoration(labelText: "Candidate Name #${index + 1}", border: const OutlineInputBorder()), validator: (v) => v!.isEmpty ? "Req" : null)),
                            if (_entries.length > 1) IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() { _entries[index].dispose(); _entries.removeAt(index); }))
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: TextFormField(controller: entry.desig, decoration: const InputDecoration(labelText: "Designation", border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? "Req" : null)),
                            const SizedBox(width: 8),
                            Expanded(child: TextFormField(controller: entry.dept, decoration: const InputDecoration(labelText: "Department", border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? "Req" : null)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: entry.date,
                          readOnly: true,
                          onTap: () => _selectDate(entry.date),
                          decoration: const InputDecoration(labelText: "Date", suffixIcon: Icon(Icons.calendar_today), border: OutlineInputBorder()),
                          validator: (v) => v!.isEmpty ? "Req" : null
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Bottom Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () => setState(() => _entries.add(InterviewControllers())),
                    icon: const Icon(Icons.add), label: const Text("Add Another")
                  ),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitBatch,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0A2540)),
                    child: _isSubmitting ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text("Save All (${_entries.length})", style: const TextStyle(color: Colors.white)),
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