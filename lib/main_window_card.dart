import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:meetoplay/global_variables.dart';

class MainWindowCard extends StatelessWidget {
  final String cardText;
  final double cardHeight;
  final Widget cardIcon;

  const MainWindowCard({
    super.key,
    required this.cardText,
    required this.cardHeight,
    required this.cardIcon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: cardHeight,
      child: Card(
        elevation: 10,
        shadowColor: Colors.black.withOpacity(0.5),
        color: const Color.fromARGB(255, 30, 156, 240),
        child: Column(
          children: [
            cardIcon,
            Container(
              decoration: const BoxDecoration(
                color: orange,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(10),
                ),
              ),
              alignment: Alignment.center,
              width: double.infinity,
              child: Text(
                cardText,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
