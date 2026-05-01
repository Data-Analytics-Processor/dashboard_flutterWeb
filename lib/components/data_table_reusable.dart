// lib/components/data_table_reusable.dart
import 'package:flutter/material.dart';

class ReusableDataTable<T> extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<String> columns;
  final List<T> data;
  final List<DataCell> Function(T item) buildCells;
  final String addActionLabel;
  final VoidCallback? onAdd;
  final void Function(T item)? onEdit;
  final void Function(T item)? onDelete;

  const ReusableDataTable({
    super.key,
    required this.title,
    this.subtitle,
    required this.columns,
    required this.data,
    required this.buildCells,
    this.addActionLabel = "Add New",
    this.onAdd,
    this.onEdit,
    this.onDelete,
  });

  // --- DARK THEME COLORS ---
  static const Color _surfaceDark = Color(0xFF1E1E1E);
  static const Color _primaryAccent = Color(0xFF4361EE);
  static const Color _textWhite = Color(0xFFFFFFFF);
  static const Color _textGrey = Color(0xFFB3B3B3);
  static const Color _borderColor = Color(0xFF333333);
  static const Color _errorRed = Color(0xFFEF4444);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _textWhite,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _primaryAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _primaryAccent,
                      ),
                    ),
                  ),
                ]
              ],
            ),
            if (onAdd != null)
              ElevatedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add, color: Colors.white, size: 18),
                label: Text(
                  addActionLabel,
                  style: const TextStyle(color: Colors.white),
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
              columns: [
                ...columns.map((col) => DataColumn(label: Text(col))),
                if (onEdit != null || onDelete != null)
                  const DataColumn(label: Text("Actions")),
              ],
              rows: data.map((item) {
                final cells = buildCells(item);
                if (onEdit != null || onDelete != null) {
                  cells.add(
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (onEdit != null)
                            IconButton(
                              icon: const Icon(Icons.edit, color: _primaryAccent, size: 20),
                              onPressed: () => onEdit!(item),
                            ),
                          if (onDelete != null)
                            IconButton(
                              icon: const Icon(Icons.delete, color: _errorRed, size: 20),
                              onPressed: () => onDelete!(item),
                            ),
                        ],
                      ),
                    ),
                  );
                }
                return DataRow(cells: cells);
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}