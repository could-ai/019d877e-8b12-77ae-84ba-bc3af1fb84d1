import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';
import 'screens/threat_scanner_screen.dart';
import 'screens/network_monitor_screen.dart';

void main() {
  runApp(const DefenseShieldApp());
}

class DefenseShieldApp extends StatelessWidget {
  const DefenseShieldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Defense Shield',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF00FFCC), // Cyber cyan
        scaffoldBackgroundColor: const Color(0xFF0A0E17), // Deep dark blue/black
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00FFCC),
          secondary: Color(0xFFFF3366), // Alert red/pink
          surface: Color(0xFF151A28),
          background: Color(0xFF0A0E17),
        ),
        fontFamily: 'Roboto', // Default, but we'll style it to look modern
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A0E17),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Color(0xFF00FFCC),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF151A28),
          selectedItemColor: Color(0xFF00FFCC),
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF151A28),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF2A324A), width: 1),
          ),
          elevation: 4,
        ),
      ),
      home: const MainNavigator(),
    );
  }
}

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const ThreatScannerScreen(),
    const NetworkMonitorScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.security_outlined),
            activeIcon: Icon(Icons.security),
            label: 'Scanner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.network_check_outlined),
            activeIcon: Icon(Icons.network_check),
            label: 'Network',
          ),
        ],
      ),
    );
  }
}
