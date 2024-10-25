import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:easy_localization/easy_localization.dart';  // Import for easy_localization
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<FlSpot> _dataPoints = [];
  List<String> _xLabels = [];
  double _minY = 0;
  double _maxY = 100;
  Timer? _timer;
  double _currentPrice = 0.0;
  String _selectedTimeRange = '1 Day';

  double _currentTemperature = 0;
  double _currentHumidity = 0;
  double _precipitation = 0;
  double _windSpeed = 0;
  double _visibility = 0;
  String _weatherDescription = '';
  String _weatherIcon = '';

  double _estimatedPowerSaved = 500;
  double _totalSolarProduction = 750;
  double _powerConsumption = 600;

  String _apiKey = "fb707a0b5eec8584617e653ae680ff6e";  // Replace with your actual OpenWeather API key
  String _weatherUrl = 'https://api.openweathermap.org/data/2.5/weather';

  @override
  void initState() {
    super.initState();
    _updateGraphForTimeRange(_selectedTimeRange);
    _fetchWeatherData();
    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      _simulatePriceChange();
      _fetchWeatherData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchWeatherData() async {
    try {
      Position position = await _determinePosition();
      String url =
          '$_weatherUrl?lat=${position.latitude}&lon=${position.longitude}&appid=$_apiKey&units=metric';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        setState(() {
          _currentTemperature = data['main']['temp'];
          _currentHumidity = data['main']['humidity'];
          _precipitation = data['rain'] != null ? data['rain']['1h'] : 0;
          _windSpeed = data['wind']['speed'];
          _visibility = data['visibility'] / 1000;  // Convert to km
          _weatherDescription = data['weather'][0]['description'];
          _weatherIcon = data['weather'][0]['icon'];
        });
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      print('Error fetching weather: $e');
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition();
  }

  void _simulatePriceChange() {
    setState(() {
      double priceChange = (Random().nextDouble() - 0.5) * 5;  // Generate random price changes
      _currentPrice += priceChange;
      _currentPrice = _currentPrice.clamp(10, 150);  // Keep price within range
    });
  }

  void _updateGraphForTimeRange(String timeRange) {
    setState(() {
      _dataPoints.clear();
      _xLabels.clear();
      DateTime now = DateTime.now();
      double minPrice = 50;
      double maxPrice = 150;
      Random random = Random();

      if (timeRange == '1 Day') {
        for (int i = 0; i <= 23; i++) {
          double simulatedPrice = minPrice + random.nextDouble() * (maxPrice - minPrice);
          _dataPoints.add(FlSpot(i.toDouble(), simulatedPrice));
          _xLabels.add('${i}h');
        }
      } else if (timeRange == '1 Week') {
        DateTime startOfWeek = now.subtract(Duration(days: 7));
        for (int i = 0; i < 7; i++) {
          double simulatedPrice = minPrice + random.nextDouble() * (maxPrice - minPrice);
          _dataPoints.add(FlSpot(i.toDouble(), simulatedPrice));
          _xLabels.add(DateFormat('E').format(startOfWeek.add(Duration(days: i))));
        }
      } else if (timeRange == '1 Month') {
        DateTime startDate = now.subtract(Duration(days: 30));
        for (int i = 0; i <= 30; i++) {
          double simulatedPrice = minPrice + random.nextDouble() * (maxPrice - minPrice);
          _dataPoints.add(FlSpot(i.toDouble(), simulatedPrice));
          _xLabels.add(DateFormat('d').format(startDate.add(Duration(days: i))));
        }
      }

      _currentPrice = _dataPoints.isNotEmpty ? _dataPoints.last.y : 0.0;
      _minY = minPrice;
      _maxY = maxPrice;
    });
  }

  void _changeLanguage(BuildContext context, Locale locale) {
    context.setLocale(locale);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildGraphSection(),
              SizedBox(height: 16),
              _buildCurrentPriceSection(),
              SizedBox(height: 16),
              _buildTimeRangeButtons(),
              SizedBox(height: 16),
              _buildPanel(tr('estimated_power_saved'), '${_estimatedPowerSaved} kWh', Icons.flash_on, Colors.green),
              SizedBox(height: 16),
              _buildPanel(tr('total_solar_production'), '${_totalSolarProduction} kWh', Icons.wb_sunny, Colors.orange),
              SizedBox(height: 16),
              _buildPanel(tr('power_consumption'), '${_powerConsumption} kWh', Icons.power, Colors.red),
              SizedBox(height: 16),
              _buildWeatherWidget(),
              SizedBox(height: 16),
              _buildEnergySavingsTips(),
              SizedBox(height: 16),
              _buildPriceSummary(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Center(
        child: Text(
          tr('energy_dashboard'),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.language),
          onPressed: () {
            _showLanguageDialog(context);  // Show language dialog
          },
        ),
      ],
      elevation: 0,
      backgroundColor: Colors.blueGrey,
    );
  }

  Widget _buildGraphSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr('real_time_price_monitoring'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: _dataPoints,
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [Colors.blue, Colors.lightBlueAccent],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [Colors.lightBlueAccent.withOpacity(0.4), Colors.blue.withOpacity(0.2)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    dotData: FlDotData(show: true),
                    barWidth: 3,
                    isStrokeCapRound: true,
                  ),
                ],
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (_xLabels.isNotEmpty && value.toInt() < _xLabels.length) {
                          return Text(_xLabels[value.toInt()], style: TextStyle(color: Colors.grey));
                        }
                        return Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text('₹${value.toInt()}kWh', style: TextStyle(color: Colors.grey));
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: true),
                minY: _minY,
                maxY: _maxY,
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((touchedSpot) {
                        final price = touchedSpot.y.toStringAsFixed(2);
                        return LineTooltipItem(
                          '₹$price kWh',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPriceSection() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      decoration: BoxDecoration(
        color: Colors.lightBlueAccent.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        '₹${_currentPrice.toStringAsFixed(2)} ${tr('per_kwh')}',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTimeRangeButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _timeRangeButton(tr('1_day')),
        SizedBox(width: 8),
        _timeRangeButton(tr('1_week')),
        SizedBox(width: 8),
        _timeRangeButton(tr('1_month')),
      ],
    );
  }

  Widget _timeRangeButton(String text) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedTimeRange = text;
          _updateGraphForTimeRange(text);
        });
      },
      child: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueGrey.withOpacity(0.9),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
    );
  }

  Widget _buildPanel(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.6), color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(icon, size: 36, color: Colors.white),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              Text(value, style: TextStyle(fontSize: 22, color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherWidget() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.withOpacity(0.5), Colors.lightBlue.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 3,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr('current_weather'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.network('https://openweathermap.org/img/w/$_weatherIcon.png', width: 30, height: 30),
                  SizedBox(width: 8),
                  Text('$_weatherDescription', style: TextStyle(fontSize: 16, color: Colors.white)),
                ],
              ),
              Text('${tr('temperature')}: $_currentTemperature°C', style: TextStyle(fontSize: 16, color: Colors.white)),
              Text('${tr('humidity')}: $_currentHumidity%', style: TextStyle(fontSize: 16, color: Colors.white)),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${tr('precipitation')}: $_precipitation mm', style: TextStyle(fontSize: 16, color: Colors.white)),
              Text('${tr('wind_speed')}: $_windSpeed km/h', style: TextStyle(fontSize: 16, color: Colors.white)),
              Text('${tr('visibility')}: $_visibility km', style: TextStyle(fontSize: 16, color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnergySavingsTips() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.withOpacity(0.5), Colors.greenAccent.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 3,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr('energy_savings_tips'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.white, size: 36),
              SizedBox(width: 10),
              Text(tr('turn_off_lights'), style: TextStyle(fontSize: 16, color: Colors.white)),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.energy_savings_leaf_outlined, color: Colors.white, size: 36),
              SizedBox(width: 10),
              Text(tr('use_energy_efficient_appliances'), style: TextStyle(fontSize: 16, color: Colors.white)),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.eco, color: Colors.white, size: 36),
              SizedBox(width: 10),
              Text(tr('leverage_natural_lighting'), style: TextStyle(fontSize: 16, color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummary() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.lightBlueAccent.withOpacity(0.5), Colors.blueAccent.withOpacity(0.5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 3,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _priceSummaryItem(tr('average_price'), '₹23.00', Icons.trending_up, Colors.yellow),
          _priceSummaryItem(tr('highest_price'), '₹41.00', Icons.arrow_upward, Colors.red),
          _priceSummaryItem(tr('lowest_price'), '₹5.00', Icons.trending_down, Colors.green),
        ],
      ),
    );
  }

  Widget _priceSummaryItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 36, color: color),
        SizedBox(height: 10),
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
        Text(value, style: TextStyle(fontSize: 22, color: Colors.white)),
      ],
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


  Widget _languageButton(BuildContext context, Locale locale, String language) {
    return ListTile(
      title: Text(language),
      onTap: () {
        _changeLanguage(context, locale);
        Navigator.of(context).pop();  // Close the dialog after selection
      },
    );
  }
}
