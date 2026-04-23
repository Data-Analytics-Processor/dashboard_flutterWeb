// lib/listView/outstandingListView.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'package:adminapp/ReusableConstants/constants.dart';
import '../models/outstandingReports_model.dart';
class OutstandingListView extends StatelessWidget {
  final List<OutstandingReport> outstandingReports;
  final Function(OutstandingReport)? onTap;

  const OutstandingListView({
    super.key,
    required this.outstandingReports,
    this.onTap,
  });

  // --- DARK THEME ---
  static const Color _surfaceDark = Color(0xFF1E1E1E);
  static const Color _primaryAccent = Color(0xFF4361EE);
  static const Color _textWhite = Color(0xFFFFFFFF);
  static const Color _textGrey = Color(0xFFB3B3B3);
  static const Color _borderColor = Color(0xFF333333);

  Map<String, dynamic> _getHighestAging(OutstandingReport item) {
    if (item.greaterThan90Days > 0) return {'label': '>90 Days', 'amt': item.greaterThan90Days, 'critical': true};
    if (item.days75To90 > 0) return {'label': '75-90 Days', 'amt': item.days75To90, 'critical': true};
    if (item.days60To75 > 0) return {'label': '60-75 Days', 'amt': item.days60To75, 'critical': true};
    if (item.days45To60 > 0) return {'label': '45-60 Days', 'amt': item.days45To60, 'critical': false};
    return {'label': 'Pending', 'amt': item.pendingAmt, 'critical': false};
  }

  @override
  Widget build(BuildContext context) {
    if (outstandingReports.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            "No outstanding reports found for this selection.",
            style: TextStyle(color: _textGrey),
          ),
        ),
      );
    }

    final currency = NumberFormat.simpleCurrency(locale: 'en_IN', decimalDigits: 0);

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: outstandingReports.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: _borderColor),
      itemBuilder: (context, index) {
        final item = outstandingReports[index];
        final isOverdue = item.isOverdue;
        final agingInfo = _getHighestAging(item);

        // --- NAME LOGIC ---
        String titleText;
        bool isUnverified = false;

        if (item.dealerPartyName != null && item.dealerPartyName!.isNotEmpty) {
          titleText = item.dealerPartyName!;
        } else if (item.tempDealerName != null && item.tempDealerName!.isNotEmpty) {
          titleText = item.tempDealerName!;
          isUnverified = true;
        } else if (item.dealerCode != null && item.dealerCode!.isNotEmpty) {
          titleText = item.dealerCode!;
          isUnverified = true;
        } else {
          titleText = item.isAccountJsbJud
              ? "Unverified JSB Account"
              : "Unverified JUD Account";
          isUnverified = true;
        }

        // --- VISUAL STATES ---
        final Color iconColor;
        final Color bgColor;
        final IconData iconData;

        if (isUnverified) {
          iconColor = Colors.amber;
          bgColor = Colors.amber.withOpacity(0.15);
          iconData = Icons.question_mark_rounded;
        } else if (isOverdue) {
          iconColor = Colors.redAccent;
          bgColor = Colors.redAccent.withOpacity(0.15);
          iconData = Icons.warning_amber_rounded;
        } else {
          iconColor = _primaryAccent;
          bgColor = _primaryAccent.withOpacity(0.15);
          iconData = Icons.account_balance_wallet_rounded;
        }

        final amountColor = isOverdue ? Colors.redAccent : Colors.orangeAccent;

        return ListTile(
          onTap: () => onTap?.call(item),
          contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),

          // --- ICON ---
          leading: CircleAvatar(
            backgroundColor: bgColor,
            radius: 20,
            child: Icon(iconData, color: iconColor, size: 18),
          ),

          // --- TITLE ---
          title: Text(
            titleText,
            style: TextStyle(
              color: isUnverified ? _textGrey : _textWhite,
              fontWeight: FontWeight.w600,
              fontSize: 14,
              fontStyle: isUnverified ? FontStyle.italic : FontStyle.normal,
            ),
            overflow: TextOverflow.ellipsis,
          ),

          // --- SUBTITLE ---
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),

              Row(
                children: [
                  if (agingInfo['critical'])
                    const Padding(
                      padding: EdgeInsets.only(right: 4),
                      child: Icon(Icons.access_time_filled,
                          color: Colors.redAccent, size: 12),
                    ),
                  Text(
                    "${agingInfo['label']}: ${currency.format(agingInfo['amt'])}",
                    style: TextStyle(
                      color: agingInfo['critical']
                          ? Colors.redAccent
                          : _textGrey,
                      fontSize: 11,
                      fontWeight: agingInfo['critical']
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 2),

              Text(
                item.reportDate != null
                    ? "As of: ${item.reportDate}"
                    : "Date unavailable",
                style: const TextStyle(color: _textGrey, fontSize: 10),
              ),
            ],
          ),

          // --- TRAILING ---
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currency.format(item.pendingAmt),
                style: TextStyle(
                  color: amountColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _surfaceDark,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isOverdue
                        ? Colors.redAccent.withOpacity(0.5)
                        : _borderColor,
                  ),
                ),
                child: Text(
                  item.zone ?? (item.isAccountJsbJud ? "JSB" : "JUD"),
                  style: TextStyle(
                    color: isOverdue ? Colors.redAccent : _textGrey,
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