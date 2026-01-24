import 'dart:math';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:project_frontend/screens/mother/home/widgets/info_card.dart';

class PregnancyVisual extends StatelessWidget {
  final int? week;

  const PregnancyVisual({super.key, this.week});

  Map<String, String> _getBabySizeInfo(int? week) {
    final w = week ?? 0;
    if (w <= 8) return {"size": "Raspberry", "emoji": "🫐", "length": "1.6cm"};
    if (w <= 12) return {"size": "Lime", "emoji": "🍋", "length": "5.4cm"};
    if (w <= 16) return {"size": "Avocado", "emoji": "🥑", "length": "11.6cm"};
    if (w <= 20) return {"size": "Banana", "emoji": "🍌", "length": "16.5cm"};
    if (w <= 24) return {"size": "Corn", "emoji": "🌽", "length": "30cm"};
    if (w <= 28) return {"size": "Eggplant", "emoji": "🍆", "length": "37.6cm"};
    if (w <= 32) return {"size": "Coconut", "emoji": "🥥", "length": "42.4cm"};
    if (w <= 36) return {"size": "Honeydew", "emoji": "🍈", "length": "47.4cm"};
    return {"size": "Watermelon", "emoji": "🍉", "length": "51cm"};
  }

  @override
  Widget build(BuildContext context) {
    final babyInfo = _getBabySizeInfo(week);

    return Stack(
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.all(40),
            child: Image.asset(
              'assets/images/fetus.jpg',
              width: 180,
              height: 180,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.pink.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Iconsax.happyemoji,
                  size: 80,
                  color: Colors.pink.shade200,
                ),
              ),
            ),
          ),
        ),
        // Baby size card
        Positioned(
          top: 20,
          right: 20,
          child: Transform.rotate(
            angle: 15 * pi / 180,
            child: InfoCard(
              icon: babyInfo['emoji']!,
              title: "Size of a",
              value: babyInfo['size']!,
              subtitle: babyInfo['length'],
            ),
          ),
        ),
        // Week indicator
        Positioned(
          bottom: 20,
          left: 20,
          child: Transform.rotate(
            angle: -10 * pi / 180,
            child: InfoCard(
              icon: "📅",
              title: "Week",
              value: "${week ?? '-'}",
              subtitle: "of 40",
            ),
          ),
        ),
      ],
    );
  }
}
