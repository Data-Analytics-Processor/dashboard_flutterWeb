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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            labelColor: Colors.green,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.green,
            tabs: [
              Tab(icon: Icon(Icons.trending_up), text: "Top 5 Performers"),
              Tab(icon: Icon(Icons.trending_down, color: Colors.red), child: Text("Bottom 5 Performers", style: TextStyle(color: Colors.red))),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _PerformerTableOnly(type: 'top', performers: topPerformers, onRefresh: onRefresh),
                _PerformerTableOnly(type: 'bottom', performers: bottomPerformers, onRefresh: onRefresh),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PerformerTableOnly extends StatelessWidget {
  final String type;
  final List<HrPerformer> performers;
  final VoidCallback onRefresh;

  const _PerformerTableOnly({required this.type, required this.performers, required this.onRefresh});

  void _openAddDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _AddPerformersDialog(type: type, currentCount: performers.length, onRefresh: onRefresh);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isTop = type == 'top';
    Color themeColor = isTop ? Colors.green : Colors.red;

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
              Text(
                "${isTop ? 'Top' : 'Bottom'} Performers List",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: performers.length >= 5 ? null : () => _openAddDialog(context),
                icon: const Icon(Icons.add, color: Colors.white, size: 18),
                label: Text("Add ${isTop ? 'Top' : 'Bottom'}"),
                style: ElevatedButton.styleFrom(backgroundColor: themeColor),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (performers.length >= 5)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text("Limit of 5 performers reached.", style: TextStyle(color: Colors.amber.shade800, fontWeight: FontWeight.bold)),
            ),
          // Data Table
          Container(
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
            child: DataTable(
              columns: const [
                DataColumn(label: Text("Name")),
                DataColumn(label: Text("Designation")),
                DataColumn(label: Text("Department")),
              ],
              rows: performers.map((p) => DataRow(cells: [
                DataCell(Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text(p.designation)),
                DataCell(Text(p.department)),
              ])).toList(),
            ),
          )
        ],
      ),
    );
  }
}

// --- HELPER & DIALOG ---
class PerformerControllers {
  final TextEditingController name = TextEditingController();
  final TextEditingController desig = TextEditingController();
  final TextEditingController dept = TextEditingController();
  void dispose() { name.dispose(); desig.dispose(); dept.dispose(); }
}

class _AddPerformersDialog extends StatefulWidget {
  final String type;
  final int currentCount;
  final VoidCallback onRefresh;
  const _AddPerformersDialog({required this.type, required this.currentCount, required this.onRefresh});

  @override
  State<_AddPerformersDialog> createState() => _AddPerformersDialogState();
}

class _AddPerformersDialogState extends State<_AddPerformersDialog> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final List<PerformerControllers> _entries = [PerformerControllers()];
  bool _isSubmitting = false;

  @override
  void dispose() {
    for (var entry in _entries) { entry.dispose(); }
    super.dispose();
  }

  void _addEntry() {
    if (_entries.length < (5 - widget.currentCount)) {
      setState(() => _entries.add(PerformerControllers()));
    }
  }

  Future<void> _submitBatch() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final payload = _entries.map((e) => {"name": e.name.text, "designation": e.desig.text, "department": e.dept.text}).toList();
      final success = await _apiService.addHrPerformer({"type": widget.type, "performers": payload});

      if (success) {
        widget.onRefresh();
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Performers added!")));
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
    bool isTop = widget.type == 'top';
    Color themeColor = isTop ? Colors.green : Colors.red;
    int maxAllowed = 5 - widget.currentCount;

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
                  Text("Add ${isTop ? 'Top' : 'Bottom'} Performers", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                            Expanded(child: TextFormField(controller: entry.name, decoration: InputDecoration(labelText: "Name #${index + 1}", border: const OutlineInputBorder()), validator: (v) => v!.isEmpty ? "Req" : null)),
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
                    onPressed: _entries.length < maxAllowed ? _addEntry : null,
                    icon: const Icon(Icons.add), label: Text("Add Row (${maxAllowed - _entries.length} left)")
                  ),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitBatch,
                    style: ElevatedButton.styleFrom(backgroundColor: themeColor),
                    child: _isSubmitting ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text("Save (${_entries.length})", style: const TextStyle(color: Colors.white)),
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