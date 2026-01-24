import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:project_frontend/providers/home_provider.dart';
import 'package:project_frontend/screens/mother/home/widgets/tracker_card.dart';

class PregnancyTracker extends StatelessWidget {
  const PregnancyTracker({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, _) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 233, 213, 228),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              const BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Your Health",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 100, 80, 95),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TrackerCard(
                      icon: Iconsax.weight,
                      title: 'Weight',
                      value: provider.latestWeight != null
                          ? '${provider.latestWeight!.toStringAsFixed(1)} kg'
                          : '-',
                      bgColor: const Color(0xffeecde6),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TrackerCard(
                      icon: Iconsax.happyemoji,
                      title: 'Last Kicks',
                      value: provider.lastKickCount != null
                          ? '${provider.lastKickCount}'
                          : '-',
                      bgColor: const Color(0xffeecde6),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TrackerCard(
                      icon: Iconsax.health,
                      title: 'Symptoms',
                      value: provider.symptomCount != null
                          ? '${provider.symptomCount} noted'
                          : '-',
                      bgColor: const Color(0xffeecde6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
