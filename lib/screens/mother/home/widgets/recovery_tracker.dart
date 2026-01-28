import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:project_frontend/providers/home_provider.dart';
import 'package:project_frontend/providers/user_stage_provider.dart';
import 'package:project_frontend/screens/mother/baby/baby_dashboard.dart';
import 'package:project_frontend/screens/mother/baby/feeding_screen.dart';
import 'package:project_frontend/screens/mother/baby/sleep_screen.dart';
import 'package:project_frontend/screens/mother/baby/diaper_screen.dart';
import 'package:project_frontend/screens/mother/home/widgets/tracker_card.dart';

class RecoveryTracker extends StatelessWidget {
  const RecoveryTracker({super.key});

  void _navigateAndRefresh(BuildContext context, Widget screen) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
    // Refresh stats when returning
    if (context.mounted) {
      final provider = context.read<UserStageProvider>();
      final babyId = provider.selectedBabyId;
      if (babyId != null) {
        context.read<HomeProvider>().loadBabyStats(babyId, forceRefresh: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // We need both providers here
    return Consumer2<UserStageProvider, HomeProvider>(
      builder: (context, userStageProvider, homeProvider, _) {
        final selectedBaby = userStageProvider.selectedBaby;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.purple.shade50,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedBaby != null
                        ? "${selectedBaby['name'] ?? 'Baby'}'s Day"
                        : "Baby Tracking",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 100, 80, 120),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BabyDashboard()),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Open',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 2),
                          Icon(Iconsax.arrow_right_3, size: 14),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: TrackerCard(
                        icon: Iconsax.milk,
                        title: 'Feedings',
                        value:
                            '${homeProvider.todayFeedCount} today\n${homeProvider.lastFeedTime != null ? "Last: ${homeProvider.lastFeedTime}" : ""}',
                        bgColor: Colors.orange.shade100,
                        onTap: () => _navigateAndRefresh(
                          context,
                          const FeedingScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TrackerCard(
                        icon: Iconsax.moon,
                        title: 'Sleep',
                        value:
                            '${homeProvider.todaySleepHours.toStringAsFixed(1)}h',
                        bgColor: Colors.indigo.shade100,
                        onTap: () => _navigateAndRefresh(
                          context,
                          const SleepScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TrackerCard(
                        icon: Iconsax.drop,
                        title: 'Diapers',
                        value: '${homeProvider.todayDiaperCount}',
                        bgColor: Colors.teal.shade100,
                        onTap: () => _navigateAndRefresh(
                          context,
                          const DiaperScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
