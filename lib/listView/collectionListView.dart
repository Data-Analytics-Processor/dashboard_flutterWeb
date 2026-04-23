// lib/listView/collectionListView.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'package:adminapp/ReusableConstants/constants.dart';
import '../models/collectionReports_model.dart';
class CollectionListView extends StatelessWidget {
  final List<CollectionReport> collections;

  const CollectionListView({super.key, required this.collections});

  // --- DARK THEME ---
  static const Color _surfaceDark = Color(0xFF1E1E1E);
  static const Color _primaryAccent = Color(0xFF4361EE);
  static const Color _textWhite = Color(0xFFFFFFFF);
  static const Color _textGrey = Color(0xFFB3B3B3);
  static const Color _borderColor = Color(0xFF333333);
  static const Color _successGreen = Color(0xFF22C55E);

  @override
  Widget build(BuildContext context) {
    if (collections.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            "No data found for this selection.",
            style: TextStyle(color: _textGrey),
          ),
        ),
      );
    }

    final currency =
        NumberFormat.simpleCurrency(locale: 'en_IN', decimalDigits: 0);

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: collections.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: _borderColor),
      itemBuilder: (context, index) {
        final item = collections[index];

        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 0, vertical: 8),

          // --- LEADING ICON ---
          leading: CircleAvatar(
            backgroundColor: _surfaceDark,
            radius: 20,
            child: const Icon(
              Icons.receipt_long_rounded,
              color: _textGrey,
              size: 18,
            ),
          ),

          // --- TITLE ---
          title: Text(
            item.partyName,
            style: const TextStyle(
              color: _textWhite,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),

          // --- SUBTITLE ---
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                "${DateFormat('dd MMM yyyy').format(item.voucherDate)} • ${item.voucherNo}",
                style: const TextStyle(
                  color: _textGrey,
                  fontSize: 11,
                ),
              ),
              if (item.salesPromoterName != null)
                Text(
                  "By: ${item.salesPromoterName}",
                  style: const TextStyle(
                    color: _primaryAccent,
                    fontSize: 10,
                  ),
                ),
            ],
          ),

          // --- TRAILING ---
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currency.format(item.amount),
                style: const TextStyle(
                  color: _successGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _surfaceDark,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _borderColor),
                ),
                child: Text(
                  item.institution,
                  style: const TextStyle(
                    color: _textGrey,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}