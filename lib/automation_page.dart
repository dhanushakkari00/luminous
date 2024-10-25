import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';  // For language localization

class AutomationPage extends StatefulWidget {
  @override
  _AutomationPageState createState() => _AutomationPageState();
}

class _AutomationPageState extends State<AutomationPage> {
  double _currentElectricPrice = 20.0;
  Timer? _priceTimer;
  bool _autoSwitchEnabled = false;

  // Appliances List with a map to keep track of power source (true = Solar, false = Electric)
  List<Map<String, dynamic>> appliances = [
    {'name': 'Refrigerator', 'powerSource': true},
    {'name': 'Washing Machine', 'powerSource': true},
    {'name': 'Air Conditioner', 'powerSource': true},
  ];

  // Selected appliances for custom automation
  List<String> selectedAppliances = [];

  // Custom automation management
  List<String> customAutomations = ['Automatic'];
  String? selectedCustomAutomation = 'Automatic';
  String? customAutomationName;

  @override
  void initState() {
    super.initState();
    _startPriceUpdate();
  }

  @override
  void dispose() {
    _priceTimer?.cancel();
    super.dispose();
  }

  // Update price every 5 seconds
  void _startPriceUpdate() {
    _priceTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      setState(() {
        _currentElectricPrice = _generateRandomPrice();
      });
    });
  }

  double _generateRandomPrice() {
    Random random = Random();
    return 15.0 + random.nextDouble() * 10.0;
  }

  // Show Popup for Custom Automation
  void _showCustomAutomationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text(tr('create_custom_automation')),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tr('select_appliances')),
                  SizedBox(height: 10),
                  Column(
                    children: appliances.map((appliance) {
                      return CheckboxListTile(
                        title: Text(appliance['name']),
                        value: selectedAppliances.contains(appliance['name']),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value!) {
                              selectedAppliances.add(appliance['name']);
                            } else {
                              selectedAppliances.remove(appliance['name']);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(labelText: tr('custom_automation_name')),
                    onChanged: (value) {
                      setState(() {
                        customAutomationName = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: Text(tr('cancel')),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                child: Text(tr('create')),
                onPressed: () {
                  if (customAutomationName != null && customAutomationName!.isNotEmpty) {
                    setState(() {
                      customAutomations.add(customAutomationName!);
                    });
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(tr('automation_control'), style: TextStyle(color: Colors.black))),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Row(
            children: [
              Text(
                tr('custom_automation'),
                style: TextStyle(color: Colors.blueAccent, fontSize: 16),
              ),
              IconButton(
                icon: Icon(Icons.add_circle_outline),
                onPressed: _showCustomAutomationDialog, // Icon to open the custom automation popup
              ),
              IconButton(
                icon: Icon(Icons.language),
                onPressed: () => _showLanguageDialog(context),  // Language switch dialog
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPricePanel(),
              SizedBox(height: 20),
              _buildAutoSwitchToggle(),
              SizedBox(height: 20),
              _buildAutomationDropdown(),
              SizedBox(height: 20),
              _buildApplianceTitleRow(), // Appliance Titles
              if (selectedCustomAutomation == 'Automatic') _buildApplianceList(),
              if (selectedCustomAutomation != 'Automatic') _buildCustomApplianceList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPricePanel() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 3,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(tr('current_electric_price'), style: TextStyle(fontSize: 18, color: Colors.white)),
            SizedBox(height: 10),
            Text(
              '₹${_currentElectricPrice.toStringAsFixed(2)} / kWh',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAutoSwitchToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          tr('enable_auto_switch_based_on_price'),
          style: TextStyle(fontSize: 16),
        ),
        Switch(
          value: _autoSwitchEnabled,
          onChanged: (bool value) {
            setState(() {
              _autoSwitchEnabled = value;
            });
          },
        ),
      ],
    );
  }

  // Appliance Title Row
  Widget _buildApplianceTitleRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(tr('appliance'), style: TextStyle(fontWeight: FontWeight.bold)),
          Text(tr('current_power_source'), style: TextStyle(fontWeight: FontWeight.bold)),
          Text(tr('electric_solar'), style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAutomationDropdown() {
    return Row(
      children: [
        Text(
          tr('select_automation') + ": ",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(width: 16),
        DropdownButton<String>(
          value: selectedCustomAutomation,
          items: customAutomations.map((automation) {
            return DropdownMenuItem<String>(
              value: automation,
              child: Text(automation),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedCustomAutomation = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildApplianceList() {
    return Column(
      children: appliances.map((appliance) {
        return _buildApplianceItem(appliance);
      }).toList(),
    );
  }

  Widget _buildCustomApplianceList() {
    return Column(
      children: selectedAppliances.map((appliance) {
        return _buildApplianceItem(
          appliances.firstWhere((ap) => ap['name'] == appliance),
        );
      }).toList(),
    );
  }

  Widget _buildApplianceItem(Map<String, dynamic> appliance) {
    return Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.devices_other),
              SizedBox(width: 10),
              Text(appliance['name'], style: TextStyle(fontSize: 16)),
            ],
          ),
          Text(appliance['powerSource'] ? 'Solar' : 'Electric', style: TextStyle(fontSize: 16, color: Colors.blueGrey)),
          Switch(
            value: appliance['powerSource'],
            onChanged: (value) {
              setState(() {
                appliance['powerSource'] = value;
              });
            },
          ),
        ],
      ),
    );
  }

 void _showLanguageDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(tr('choose_language')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('English'),
              onTap: () {
                context.setLocale(Locale('en', 'US'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Hindi'),
              onTap: () {
                context.setLocale(Locale('hi', 'IN'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Telugu'),
              onTap: () {
                context.setLocale(Locale('te', 'IN'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Tamil'),
              onTap: () {
                context.setLocale(Locale('ta', 'IN'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Bengali'),
              onTap: () {
                context.setLocale(Locale('bn', 'IN'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Malayalam'),
              onTap: () {
                context.setLocale(Locale('ml', 'IN'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Kannada'),
              onTap: () {
                context.setLocale(Locale('kn', 'IN'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Marathi'),
              onTap: () {
                context.setLocale(Locale('mr', 'IN'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    },
  );
}
}
