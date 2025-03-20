import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

class Riders extends StatelessWidget {
  const Riders({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 255, 239, 249),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: FadeInLeft(
                child: const Text(
                  'Riders',
                  style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SingleChildScrollView(


            )
          ],
        ));
  
  }
}
