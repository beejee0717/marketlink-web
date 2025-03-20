import 'package:flutter/material.dart';
import 'package:marketlinkweb/components/header.dart';
import 'package:marketlinkweb/components/sidebar.dart';
import 'package:marketlinkweb/pages/customers.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget _selectedPage = const Customers(); // Default page

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
                  onPageSelected: _navigateToPage, // Pass the function to Sidebar
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
