import 'package:flutter/material.dart';

class AppColors{

  static const Color purple = Color(0xFF3D1E6D);
  
}

Widget refreshButton (VoidCallback onTap){
  return
        GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
          Color(0xFF6DC8F3), 
          Color(0xFF73A1F9), 
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
          color: Colors.blue.withOpacity(0.3),
          blurRadius: 6,
          offset: const Offset(2, 4),
                ),
              ],
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
          Icon(Icons.refresh, color: Colors.white, size: 20),
          SizedBox(width: 8),
          Text(
            'Refresh',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 1.0,
            ),
          ),
                ],
              ),
            ),
          ),
        );
}