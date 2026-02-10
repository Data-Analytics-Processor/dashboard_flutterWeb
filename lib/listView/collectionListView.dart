// lib/listView/collectionListView.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dashboard_flutter/ReusableConstants/constants.dart';
import '../models/collectionReports_model.dart';

class CollectionListView extends StatelessWidget {
  final List<CollectionReport> collections;

  const CollectionListView({super.key, required this.collections});

  @override
  Widget build(BuildContext context) {
    if (collections.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text("No data found for this selection.", style: TextStyle(color: kTextGrey)),
        ),
      );
    }

    final currency = NumberFormat.simpleCurrency(locale: 'en_IN', decimalDigits: 0);

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: collections.length,
      separatorBuilder: (_, __) => const Divider(height: 1, color: kBorderColor),
      itemBuilder: (context, index) {
        final item = collections[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          leading: CircleAvatar(
            backgroundColor: kBankSurfaceLight,
            radius: 20,
            child: const Icon(Icons.receipt_long_rounded, color: kTextGrey, size: 18),
          ),
          title: Text(
            item.partyName,
            style: const TextStyle(color: kTextWhite, fontWeight: FontWeight.w600, fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                "${DateFormat('dd MMM yyyy').format(item.voucherDate)} • ${item.voucherNo}",
                style: const TextStyle(color: kTextGrey, fontSize: 11),
              ),
              if (item.salesPromoterName != null)
                 Text(
                  "By: ${item.salesPromoterName}",
                  style: const TextStyle(color: kBankPrimary, fontSize: 10),
                ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currency.format(item.amount),
                style: const TextStyle(color: kSuccessGreen, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: kBankSurfaceLight,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: kBorderColor)
                ),
                child: Text(
                  item.institution, 
                  style: const TextStyle(color: kTextGrey, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}