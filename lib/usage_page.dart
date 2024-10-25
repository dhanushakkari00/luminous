import 'dart:math';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';  // For localization
import 'analytics_page.dart';

class UsagePage extends StatefulWidget {
  @override
  _UsagePageState createState() => _UsagePageState();
}

class _UsagePageState extends State<UsagePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> appliances = [
    {'type': 'Refrigerator', 'brand': 'Samsung', 'powerRating': '200W', 'solarUsed': '100W', 'electricUsed': '100W'},
    {'type': 'Washing Machine', 'brand': 'LG', 'powerRating': '500W', 'solarUsed': '300W', 'electricUsed': '200W'},
    {'type': 'Air Conditioner', 'brand': 'Daikin', 'powerRating': '1500W', 'solarUsed': '500W', 'electricUsed': '1000W'},
    {'type': 'Dishwasher', 'brand': 'Bosch', 'powerRating': '1200W', 'solarUsed': '600W', 'electricUsed': '600W'},
    {'type': 'TV', 'brand': 'Sony', 'powerRating': '150W', 'solarUsed': '50W', 'electricUsed': '100W'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddApplianceDialog() {
    String type = '';
    String brand = '';
    String powerRating = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(tr('add_appliance')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: tr('appliance_type')),
                onChanged: (value) {
                  type = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: tr('brand')),
                onChanged: (value) {
                  brand = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: tr('power_rating_w')),
                onChanged: (value) {
                  powerRating = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text(tr('cancel')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text(tr('add')),
              onPressed: () {
                setState(() {
                  // Randomly generating solar and electric power consumption values
                  var random = Random();
                  String solarUsed = '${random.nextInt(500)}W';
                  String electricUsed = '${random.nextInt(500)}W';

                  appliances.add({
                    'type': type,
                    'brand': brand,
                    'powerRating': '$powerRating W',
                    'solarUsed': solarUsed,
                    'electricUsed': electricUsed,
                  });
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _removeAppliance(int index) {
    setState(() {
      appliances.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(tr('usage_details'))),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddApplianceDialog, // Move "Add Appliance" button to AppBar
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blueGrey,
          labelColor: Colors.blueGrey,
          tabs: [
            Tab(text: tr('current_usage')),
            Tab(text: tr('analytics')),
          ],
        ),
      ),
      backgroundColor: Colors.grey[200],
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCurrentUsagePage(),
          AnalyticsPage(appliances: appliances),  // Passing appliances to AnalyticsPage
        ],
      ),
    );
  }

  Widget _buildCurrentUsagePage() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildPowerPanels(),
          SizedBox(height: 20),
          _buildApplianceHeader(),
          _buildAppliancesList(),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPowerPanels() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildPowerPanel(
            title: tr('electric_power_consumption'),
            value: '600 kWh',
            gradient: LinearGradient(
              colors: [Colors.redAccent.withOpacity(0.6), Colors.redAccent.withOpacity(0.4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          _buildPowerPanel(
            title: tr('solar_power_produced'),
            value: '400 kWh',
            gradient: LinearGradient(
              colors: [Colors.orangeAccent.withOpacity(0.6), Colors.orangeAccent.withOpacity(0.4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPowerPanel({required String title, required String value, required Gradient gradient}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildApplianceHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(tr('appliance'), style: TextStyle(fontWeight: FontWeight.bold)),
          Text(tr('brand'), style: TextStyle(fontWeight: FontWeight.bold)),
          Text(tr('power_rating'), style: TextStyle(fontWeight: FontWeight.bold)),
          Text(tr('solar_power_used'), style: TextStyle(fontWeight: FontWeight.bold)),
          Text(tr('electric_power_used'), style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAppliancesList() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: appliances.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> appliance = entry.value;
          return _buildApplianceItem(appliance, index);
        }).toList(),
      ),
    );
  }

  Widget _buildApplianceItem(Map<String, dynamic> appliance, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(appliance['type'], style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(appliance['brand']),
          Text(appliance['powerRating']),
          Text(appliance['solarUsed']),
          Text(appliance['electricUsed']),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () => _removeAppliance(index),
          ),
        ],
      ),
    );
  }
}
