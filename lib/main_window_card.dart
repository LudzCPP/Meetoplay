import 'package:flutter/material.dart';
import 'package:meetoplay/global_variables.dart';

class MainWindowCard extends StatelessWidget {
  final String cardText;
  final double cardHeight;
  final Icon cardIcon;

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
            cardText != 'MAPA WYDARZEŃ'
                ? cardIcon
                : const Placeholder(
                    fallbackHeight: 213,
                  ),
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
