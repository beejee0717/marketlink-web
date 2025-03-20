import 'package:flutter/material.dart';
import 'package:marketlinkweb/components/components.dart';
import 'package:marketlinkweb/pages/customers.dart';
import 'package:marketlinkweb/pages/products.dart';
import 'package:marketlinkweb/pages/riders.dart';
import 'package:marketlinkweb/pages/sellers.dart';

class Sidebar extends StatelessWidget {
  final double width;
  final Function(Widget) onPageSelected; // Callback function

  const Sidebar({super.key, required this.width, required this.onPageSelected});

  @override
  Widget build(BuildContext context) {
    
    final size = MediaQuery.of(context).size;
    final bool isWeb = size.width > 600;
    return Drawer(
      backgroundColor: AppColors.purple,
      width: width,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SidebarButton(label: isWeb? 'Customer':'', icon: Icons.person, page: const Customers(), onPageSelected: onPageSelected),
            SidebarButton(label: isWeb? 'Products':'', icon: Icons.sell, page: const Products(), onPageSelected: onPageSelected),
            SidebarButton(label: isWeb? 'Sellers':'', icon: Icons.store, page: const Sellers(), onPageSelected: onPageSelected),
            SidebarButton(label: isWeb? 'Riders':'', icon: Icons.motorcycle, page: const Riders(), onPageSelected: onPageSelected),

          ],
        ),
      ),
    );
  }
}

class SidebarButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Widget page;
  final Function(Widget) onPageSelected;

  const SidebarButton({super.key, required this.label, required this.icon, required this.page, required this.onPageSelected});

  @override
  Widget build(BuildContext context) {
    
    return GestureDetector(
      onTap: () {
        onPageSelected(page); // Update the page in HomePage
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: Icon(icon, size: 30, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(fontSize: 15, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
