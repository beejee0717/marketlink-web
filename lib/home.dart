import 'package:flutter/material.dart';
import 'package:marketlinkweb/components/header.dart';
import 'package:marketlinkweb/components/sidebar.dart';
import 'package:marketlinkweb/pages/dashboard.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Widget _selectedPage;

  @override
  void initState() {
    super.initState();
    _selectedPage = Dashboard(onPageSelected: _navigateToPage);
    // _selectedPage = const Sellers();
  }

  void _navigateToPage(Widget page) {
    setState(() {
      _selectedPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Column(
        children: [
          const Header(),
          Expanded(
            child: Row(
              children: [
                Sidebar(
                  width: size.width * 0.13,
                  onPageSelected: _navigateToPage,
                ),
                Expanded(child: _selectedPage),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
