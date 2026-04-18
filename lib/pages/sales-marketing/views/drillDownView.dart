// lib/pages/sales-marketing/views/drillDownView.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/sales_reports_model.dart';

// ==========================================
// SALES DRILL-DOWN VIEWS (District -> Area -> Dealer)
// ==========================================

class SalesZoneView extends StatelessWidget {
  final Map<String, Map<String, List<SalesData>>> groupedData;

  const SalesZoneView({super.key, required this.groupedData});

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

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text("District: $districtName", style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("Total Sales: ${totalDistrictMT.toStringAsFixed(2)} MT"),
            trailing: const Icon(Icons.chevron_right),
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
          ),
        );
      },
    );
  }
}

class SalesAreaView extends StatelessWidget {
  final String districtName;
  final Map<String, List<SalesData>> areaData;

  const SalesAreaView({super.key, required this.districtName, required this.areaData});

  @override
  Widget build(BuildContext context) {
    final areas = areaData.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(title: Text("$districtName Areas")),
      body: ListView.builder(
        itemCount: areas.length,
        itemBuilder: (context, index) {
          String areaName = areas[index];
          List<SalesData> dealersInArea = areaData[areaName]!;
          
          double totalAreaMT = dealersInArea.fold(0.0, (sum, item) => sum + item.total);

          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text("Area: $areaName", style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("Total Sales: ${totalAreaMT.toStringAsFixed(2)} MT"),
              trailing: const Icon(Icons.chevron_right),
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

  const SalesDealerView({super.key, required this.areaName, required this.dealers});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("$areaName Dealers")),
      body: ListView.builder(
        itemCount: dealers.length,
        itemBuilder: (context, index) {
          var dealer = dealers[index];
          
          bool targetMet = (double.tryParse(dealer.achievedPercentage.replaceAll('%', '')) ?? 0) >= 100;

          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text(dealer.dealerName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Sales: ${dealer.total.toStringAsFixed(2)} MT | Target: ${dealer.target.toStringAsFixed(2)} MT"),
                  Text("Rep: ${dealer.responsiblePerson}"),
                ],
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: targetMet ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  dealer.achievedPercentage,
                  style: TextStyle(
                    color: targetMet ? Colors.green.shade700 : Colors.orange.shade800,
                    fontWeight: FontWeight.bold
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

// ==========================================
// COLLECTION DRILL-DOWN VIEWS (Zone -> District -> Party)
// ==========================================

class CollectionZoneView extends StatelessWidget {
  final Map<String, Map<String, List<CollectionData>>> groupedData;

  const CollectionZoneView({super.key, required this.groupedData});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
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

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text("Zone: $zoneName", style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("Total Collections: ${currencyFormatter.format(totalZoneCollection)}"),
            trailing: const Icon(Icons.chevron_right),
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
          ),
        );
      },
    );
  }
}

class CollectionDistrictView extends StatelessWidget {
  final String zoneName;
  final Map<String, List<CollectionData>> districtData;

  const CollectionDistrictView({super.key, required this.zoneName, required this.districtData});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final districts = districtData.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(title: Text("$zoneName Districts")),
      body: ListView.builder(
        itemCount: districts.length,
        itemBuilder: (context, index) {
          String districtName = districts[index];
          List<CollectionData> partiesInDistrict = districtData[districtName]!;
          
          double totalDistrictCollection = partiesInDistrict.fold(0.0, (sum, item) => sum + item.amount);

          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text("District: $districtName", style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("Total Collections: ${currencyFormatter.format(totalDistrictCollection)}"),
              trailing: const Icon(Icons.chevron_right),
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

  const CollectionPartyView({super.key, required this.districtName, required this.parties});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    return Scaffold(
      appBar: AppBar(title: Text("$districtName Parties")),
      body: ListView.builder(
        itemCount: parties.length,
        itemBuilder: (context, index) {
          var party = parties[index];

          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text(party.partyName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Amount: ${currencyFormatter.format(party.amount)}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
                  Text("Voucher: ${party.voucherNo} | Date: ${party.date}"),
                  Text("Promoter: ${party.salesPromoter}"),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}