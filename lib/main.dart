import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';  // Import Easy Localization
import 'dashboard_page.dart';  // Import the DashboardPage
import 'usage_page.dart';  // Import the UsagePage
import 'automation_page.dart';  // Import the AutomationPage

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: [
        Locale('en', 'US'),  // English
        Locale('te', 'IN'),  // Telugu
        Locale('hi', 'IN'),  // Hindi
        Locale('ta', 'IN'),  // Tamil
        Locale('bn', 'IN'),  // Bengali
        Locale('ml', 'IN'),  // Malayalam
        Locale('gu', 'IN'),  // Gujarati
        Locale('mr', 'IN'),  // Marathi
      ],
      path: 'assets/translation',  // Path to your translation files
      fallbackLocale: Locale('en', 'US'),  // Fallback to English if translation not available
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Energy Dashboard'.tr(),  // Use translation for the title
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      localizationsDelegates: context.localizationDelegates,  // Localization delegates
      supportedLocales: context.supportedLocales,  // Supported locales
      locale: context.locale,  // Locale for the app
      home: HomeScreen(),  // Set the HomeScreen as the entry point
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // List of pages to navigate to
  final List<Widget> _pages = [
    DashboardPage(),  // Dashboard page
    UsagePage(),  // Usage page
    AutomationPage(),  // Automation page
  ];

  // Function to handle bottom nav bar tap
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],  // Display the selected page
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard'.tr(),  // Use translation for 'Dashboard'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Usage'.tr(),  // Use translation for 'Usage'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_input_component),
            label: 'Automation'.tr(),  // Use translation for 'Automation'
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        onTap: _onItemTapped,  // Switch pages on tap
      ),
    );
  }
}
