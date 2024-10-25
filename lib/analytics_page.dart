import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import 'package:easy_localization/easy_localization.dart';  // For translations

class AnalyticsPage extends StatefulWidget {
  final List<Map<String, dynamic>> appliances; // To get appliances from usage page

  AnalyticsPage({required this.appliances});

  @override
  _AnalyticsPageState createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  String selectedTimeFrame = '1 Day';  // Default time frame
  String selectedAppliance = 'Total Power Consumption'; // Default selected appliance
  List<FlSpot> electricData = [];
  List<FlSpot> solarData = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    updateGraphData(selectedTimeFrame, selectedAppliance);
    // Setup a timer to simulate real-time data updates every 30 minutes
    _timer = Timer.periodic(Duration(minutes: 30), (_) => updateGraphData(selectedTimeFrame, selectedAppliance));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Method to generate random graph data based on appliance and time frame
  void updateGraphData(String timeframe, String appliance) {
    int count = (timeframe == '1 Day') ? 24 : (timeframe == '1 Week') ? 7 : 30; // Different data points based on timeframe
    Random random = Random();

    setState(() {
      // Generating random data for the selected appliance
      electricData = List.generate(count, (index) => FlSpot(index.toDouble(), random.nextInt(20) + 5.0));
      solarData = List.generate(count, (index) => FlSpot(index.toDouble(), random.nextInt(15) + 3.0));

      // If "Total Power Consumption" is selected, combine electric and solar data
      if (appliance == 'Total Power Consumption') {
        electricData = List.generate(count, (index) => FlSpot(index.toDouble(), random.nextInt(50) + 10.0));
        solarData = List.generate(count, (index) => FlSpot(index.toDouble(), random.nextInt(40) + 8.0));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('analytics')), // Translated title
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => updateGraphData(selectedTimeFrame, selectedAppliance),  // Manually refresh data
          ),
          IconButton(
            icon: Icon(Icons.language),
            onPressed: () => _showLanguageDialog(context),  // Language switch dialog
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildDropdownSection(),
              SizedBox(height: 20),
              timeFrameSelector(),
              SizedBox(height: 20),
              buildGraphWithTitle(electricData, tr('electric_power_usage') + ' $selectedAppliance (kWh)', Colors.blue),
              SizedBox(height: 20),
              buildGraphWithTitle(solarData, tr('solar_power_usage') + ' $selectedAppliance (kWh)', Colors.orange),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr('select_appliance'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), // Translated label
          SizedBox(height: 10),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: tr('select_appliance'),  // Translated label
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white.withOpacity(0.9),
            ),
            items: [
              DropdownMenuItem(
                value: 'Total Power Consumption',
                child: Text(tr('total_power_consumption')),  // Translated option
              ),
              ...widget.appliances.map<DropdownMenuItem<String>>((appliance) {
                return DropdownMenuItem<String>(
                  value: appliance['type'],
                  child: Text(appliance['type']),
                );
              }).toList(),
            ],
            value: selectedAppliance,
            onChanged: (String? value) {
              setState(() {
                selectedAppliance = value!;
                updateGraphData(selectedTimeFrame, selectedAppliance);  // Update graph data on appliance selection
              });
            },
          ),
        ],
      ),
    );
  }

  Widget timeFrameSelector() {
    List<String> options = [tr('1_day'), tr('1_week'), tr('1_month')]; // Translated options
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: options.map((frame) => ChoiceChip(
        label: Text(frame),
        selected: selectedTimeFrame == frame,
        onSelected: (selected) {
          if (selected) {
            setState(() {
              selectedTimeFrame = frame;
              updateGraphData(frame, selectedAppliance);
            });
          }
        },
      )).toList(),
    );
  }

  Widget buildGraphWithTitle(List<FlSpot> data, String title, Color color) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        Container(
          height: 220,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) => Text('${value.toInt()}', style: TextStyle(color: Colors.grey)),
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) => Text('${value.toInt()}', style: TextStyle(color: Colors.grey)),
                  ),
                ),
              ),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots: data,
                  isCurved: true,
                  color: color,
                  barWidth: 2,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(show: true, color: color.withOpacity(0.3)),
                )
              ],
              minX: 0,
              maxX: data.length.toDouble() - 1,
              minY: 0,
              maxY: data.reduce((a, b) => a.y > b.y ? a : b).y + 2, // Ensure y-axis is properly scaled
            ),
          ),
        ),
      ],
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(tr('select_language')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _languageButton(context, Locale('en'), 'English'),
              _languageButton(context, Locale('hi'), 'हिन्दी'),
              _languageButton(context, Locale('ta'), 'தமிழ்'),
              _languageButton(context, Locale('te'), 'తెలుగు'),
              _languageButton(context, Locale('kn'), 'ಕನ್ನಡ'),
              _languageButton(context, Locale('ml'), 'മലയാളം'),
              _languageButton(context, Locale('bn'), 'বাংলা'),
              _languageButton(context, Locale('gu'), 'ગુજરાતી'),
            ],
          ),
        );
      },
    );
  }

  Widget _languageButton(BuildContext context, Locale locale, String language) {
    return ListTile(
      title: Text(language),
      onTap: () {
        _changeLanguage(context, locale);
        Navigator.of(context).pop();  // Close the dialog after selection
      },
    );
  }

  void _changeLanguage(BuildContext context, Locale locale) {
    EasyLocalization.of(context)!.setLocale(locale);  // Change language using EasyLocalization
  }
}
