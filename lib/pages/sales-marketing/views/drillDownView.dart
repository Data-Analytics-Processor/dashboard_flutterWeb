// lib/pages/sales-marketing/views/drillDownView.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/sales_reports_model.dart';

// ==========================================
// SALES DRILL-DOWN VIEWS (District -> Area -> Dealer)
// ==========================================
class SalesZoneView extends StatelessWidget {
  final Map<String, Map<String, List<SalesData>>> groupedData;

  const SalesZoneView({
    super.key,
    required this.groupedData,
  });

  // --- DARK THEME ---
  static const Color _surfaceDark = Color(0xFF1E1E1E);
  static const Color _primaryAccent = Color(0xFF4361EE);
  static const Color _textWhite = Color(0xFFFFFFFF);
  static const Color _textGrey = Color(0xFFB3B3B3);
  static const Color _borderColor = Color(0xFF333333);

  @override
  Widget build(BuildContext context) {
    final districts = groupedData.keys.toList()..sort();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: districts.length,
      itemBuilder: (context, index) {
        String districtName = districts[index];
        var areasInDistrict = groupedData[districtName]!;

        double totalDistrictMT = areasInDistrict.values
            .expand((list) => list)
            .fold(0.0, (sum, item) => sum + item.total);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SalesAreaView(
                      districtName: districtName,
                      areaData: areasInDistrict,
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: _surfaceDark,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    // --- LEFT CONTENT ---
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            "District: $districtName",
                            style: const TextStyle(
                              color: _textWhite,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Total Sales: ${totalDistrictMT.toStringAsFixed(2)} MT",
                            style: const TextStyle(
                              color: _textGrey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // --- RIGHT CHEVRON ---
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _primaryAccent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.chevron_right_rounded,
                        color: _primaryAccent,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
class SalesAreaView extends StatelessWidget {
  final String districtName;
  final Map<String, List<SalesData>> areaData;

  const SalesAreaView({
    super.key,
    required this.districtName,
    required this.areaData,
  });

  // --- DARK THEME ---
  static const Color _bgDark = Color(0xFF121212);
  static const Color _surfaceDark = Color(0xFF1E1E1E);
  static const Color _primaryAccent = Color(0xFF4361EE);
  static const Color _textWhite = Color(0xFFFFFFFF);
  static const Color _textGrey = Color(0xFFB3B3B3);
  static const Color _borderColor = Color(0xFF333333);

  @override
  Widget build(BuildContext context) {
    final areas = areaData.keys.toList()..sort();

    return Scaffold(
      backgroundColor: _bgDark,
      appBar: AppBar(
        backgroundColor: _bgDark,
        elevation: 0,
        title: Text(
          "$districtName Areas",
          style: const TextStyle(
            color: _textWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: _textWhite),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: areas.length,
        itemBuilder: (context, index) {
          String areaName = areas[index];
          List<SalesData> dealersInArea = areaData[areaName]!;

          double totalAreaMT = dealersInArea.fold(
              0.0, (sum, item) => sum + item.total);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SalesDealerView(
                        areaName: areaName,
                        dealers: dealersInArea,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: _surfaceDark,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      // --- LEFT CONTENT ---
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Area: $areaName",
                              style: const TextStyle(
                                color: _textWhite,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Total Sales: ${totalAreaMT.toStringAsFixed(2)} MT",
                              style: const TextStyle(
                                color: _textGrey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // --- RIGHT ACTION ---
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color:
                              _primaryAccent.withOpacity(0.15),
                          borderRadius:
                              BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.chevron_right_rounded,
                          color: _primaryAccent,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
class SalesDealerView extends StatelessWidget {
  final String areaName;
  final List<SalesData> dealers;

  const SalesDealerView({
    super.key,
    required this.areaName,
    required this.dealers,
  });

  // --- DARK THEME ---
  static const Color _bgDark = Color(0xFF121212);
  static const Color _surfaceDark = Color(0xFF1E1E1E);
  // static const Color _primaryAccent = Color(0xFF4361EE);
  static const Color _textWhite = Color(0xFFFFFFFF);
  static const Color _textGrey = Color(0xFFB3B3B3);
  static const Color _borderColor = Color(0xFF333333);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      appBar: AppBar(
        backgroundColor: _bgDark,
        elevation: 0,
        title: Text(
          "$areaName Dealers",
          style: const TextStyle(
            color: _textWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: _textWhite),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: dealers.length,
        itemBuilder: (context, index) {
          var dealer = dealers[index];

          bool targetMet =
              (double.tryParse(
                          dealer.achievedPercentage.replaceAll('%', '')) ??
                      0) >=
                  100;

          final Color statusColor =
              targetMet ? const Color(0xFF22C55E) : Colors.orangeAccent;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: _surfaceDark,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Row(
                children: [
                  // --- LEFT CONTENT ---
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          dealer.dealerName,
                          style: const TextStyle(
                            color: _textWhite,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),

                        Text(
                          "Sales: ${dealer.total.toStringAsFixed(2)} MT | Target: ${dealer.target.toStringAsFixed(2)} MT",
                          style: const TextStyle(
                            color: _textGrey,
                            fontSize: 12,
                          ),
                        ),

                        const SizedBox(height: 2),

                        Text(
                          "Rep: ${dealer.responsiblePerson}",
                          style: const TextStyle(
                            color: _textGrey,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- STATUS BADGE ---
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: statusColor.withOpacity(0.5),
                      ),
                    ),
                    child: Text(
                      dealer.achievedPercentage,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ==========================================
// COLLECTION DRILL-DOWN VIEWS (Zone -> District -> Party)
// ==========================================
class CollectionZoneView extends StatelessWidget {
  final Map<String, Map<String, List<CollectionData>>> groupedData;

  const CollectionZoneView({
    super.key,
    required this.groupedData,
  });

  // --- DARK THEME ---
  static const Color _surfaceDark = Color(0xFF1E1E1E);
  static const Color _primaryAccent = Color(0xFF4361EE);
  static const Color _textWhite = Color(0xFFFFFFFF);
  static const Color _textGrey = Color(0xFFB3B3B3);
  static const Color _borderColor = Color(0xFF333333);
  static const Color _successGreen = Color(0xFF22C55E);

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    final zones = groupedData.keys.toList()..sort();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: zones.length,
      itemBuilder: (context, index) {
        String zoneName = zones[index];
        var districtsInZone = groupedData[zoneName]!;

        double totalZoneCollection = districtsInZone.values
            .expand((list) => list)
            .fold(0.0, (sum, item) => sum + item.amount);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CollectionDistrictView(
                      zoneName: zoneName,
                      districtData: districtsInZone,
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: _surfaceDark,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    // --- LEFT CONTENT ---
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Zone: $zoneName",
                            style: const TextStyle(
                              color: _textWhite,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Total Collections: ${currencyFormatter.format(totalZoneCollection)}",
                            style: const TextStyle(
                              color: _textGrey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // --- VALUE HIGHLIGHT + NAV ---
                    Row(
                      children: [
                        Text(
                          currencyFormatter
                              .format(totalZoneCollection),
                          style: const TextStyle(
                            color: _successGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color:
                                _primaryAccent.withOpacity(0.15),
                            borderRadius:
                                BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.chevron_right_rounded,
                            color: _primaryAccent,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
class CollectionDistrictView extends StatelessWidget {
  final String zoneName;
  final Map<String, List<CollectionData>> districtData;

  const CollectionDistrictView({
    super.key,
    required this.zoneName,
    required this.districtData,
  });

  // --- DARK THEME ---
  static const Color _bgDark = Color(0xFF121212);
  static const Color _surfaceDark = Color(0xFF1E1E1E);
  static const Color _primaryAccent = Color(0xFF4361EE);
  static const Color _textWhite = Color(0xFFFFFFFF);
  static const Color _textGrey = Color(0xFFB3B3B3);
  static const Color _borderColor = Color(0xFF333333);
  static const Color _successGreen = Color(0xFF22C55E);

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    final districts = districtData.keys.toList()..sort();

    return Scaffold(
      backgroundColor: _bgDark,
      appBar: AppBar(
        backgroundColor: _bgDark,
        elevation: 0,
        title: Text(
          "$zoneName Districts",
          style: const TextStyle(
            color: _textWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: _textWhite),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: districts.length,
        itemBuilder: (context, index) {
          String districtName = districts[index];
          List<CollectionData> partiesInDistrict =
              districtData[districtName]!;

          double totalDistrictCollection =
              partiesInDistrict.fold(
                  0.0, (sum, item) => sum + item.amount);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CollectionPartyView(
                        districtName: districtName,
                        parties: partiesInDistrict,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: _surfaceDark,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      // --- LEFT CONTENT ---
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              "District: $districtName",
                              style: const TextStyle(
                                color: _textWhite,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Total Collections: ${currencyFormatter.format(totalDistrictCollection)}",
                              style: const TextStyle(
                                color: _textGrey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // --- VALUE + NAV ---
                      Row(
                        children: [
                          Text(
                            currencyFormatter
                                .format(totalDistrictCollection),
                            style: const TextStyle(
                              color: _successGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: _primaryAccent
                                  .withOpacity(0.15),
                              borderRadius:
                                  BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.chevron_right_rounded,
                              color: _primaryAccent,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
class CollectionPartyView extends StatelessWidget {
  final String districtName;
  final List<CollectionData> parties;

  const CollectionPartyView({
    super.key,
    required this.districtName,
    required this.parties,
  });

  // --- DARK THEME ---
  static const Color _bgDark = Color(0xFF121212);
  static const Color _surfaceDark = Color(0xFF1E1E1E);
  static const Color _primaryAccent = Color(0xFF4361EE);
  static const Color _textWhite = Color(0xFFFFFFFF);
  static const Color _textGrey = Color(0xFFB3B3B3);
  static const Color _borderColor = Color(0xFF333333);
  static const Color _successGreen = Color(0xFF22C55E);

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    return Scaffold(
      backgroundColor: _bgDark,
      appBar: AppBar(
        backgroundColor: _bgDark,
        elevation: 0,
        title: Text(
          "$districtName Parties",
          style: const TextStyle(
            color: _textWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: _textWhite),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: parties.length,
        itemBuilder: (context, index) {
          var party = parties[index];

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: _surfaceDark,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- HEADER ---
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          party.partyName,
                          style: const TextStyle(
                            color: _textWhite,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // --- AMOUNT BADGE ---
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color:
                              _successGreen.withOpacity(0.15),
                          borderRadius:
                              BorderRadius.circular(10),
                          border: Border.all(
                            color: _successGreen
                                .withOpacity(0.5),
                          ),
                        ),
                        child: Text(
                          currencyFormatter
                              .format(party.amount),
                          style: const TextStyle(
                            color: _successGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // --- DETAILS ---
                  Text(
                    "Voucher: ${party.voucherNo}",
                    style: const TextStyle(
                      color: _textGrey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Date: ${party.date}",
                    style: const TextStyle(
                      color: _textGrey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Promoter: ${party.salesPromoter}",
                    style: TextStyle(
                      color: _primaryAccent.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}