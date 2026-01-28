import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:project_frontend/providers/home_provider.dart';
import 'package:project_frontend/providers/user_stage_provider.dart';
import 'package:project_frontend/screens/mother/home/widgets/postnatal_visual.dart';
import 'package:project_frontend/screens/mother/home/widgets/pregnancy_tracker.dart';
import 'package:project_frontend/screens/mother/home/widgets/pregnancy_visual.dart';
import 'package:project_frontend/screens/mother/home/widgets/error_placeholder.dart';
import 'package:project_frontend/screens/mother/home/widgets/no_baby_placeholder.dart';
import 'package:project_frontend/screens/mother/home/widgets/recovery_tracker.dart';
import 'package:project_frontend/screens/mother/home/widgets/sos_quick_access.dart';
import 'package:project_frontend/screens/mother/home/widgets/week_progress.dart';
import 'package:project_frontend/screens/mother/signup_details.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserStageProvider>().loadProfile();
      context.read<HomeProvider>().fetchAdditionalStats();
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    return "Good Evening";
  }

  String _getSubtitle(
    bool isPregnant,
    bool hasBaby,
    int? pregnancyWeek,
    int babyAgeWeeks,
  ) {
    if (isPregnant && pregnancyWeek != null) {
      final weeksLeft = context.read<HomeProvider>().getWeeksRemaining(
        pregnancyWeek,
      );
      return "In $weeksLeft weeks you're going to meet your baby! 💕";
    } else if (!isPregnant && hasBaby) {
      final weeks = babyAgeWeeks;
      return "Your baby is $weeks week${weeks == 1 ? '' : 's'} old! 👶";
    } else if (!isPregnant && !hasBaby) {
      return "Congratulations on your delivery! 🎉";
    }
    return "Welcome to your pregnancy journey";
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserStageProvider>(
      builder: (context, provider, _) {
        // We also need HomeProvider for loading state if we want to show global loading
        final homeProvider = context.watch<HomeProvider>();

        if (provider.isLoading || homeProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Handle network errors
        if (provider.hasError) {
          return Scaffold(
            body: Container(
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFCE4EC),
                    const Color(0xFFE1BEE7),
                    const Color(0xFFE8EAF6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: ErrorPlaceholder(
                      errorMessage: provider.errorMessage,
                      onRetry: () {
                        context.read<UserStageProvider>().loadProfile();
                        context.read<HomeProvider>().fetchAdditionalStats();
                      },
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        // Handle case where profile doesn't exist (404)
        if (provider.profileNotFound) {
          // Schedule navigation to signup details screen after build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const SignupDetails()),
            );
          });
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Setting up your profile...'),
                ],
              ),
            ),
          );
        }

        final profile = provider.motherProfile;
        final name = profile?['name'] ?? "Mom";
        final isPregnant = provider.isPregnant;
        final pregnancyWeek = profile?['pregnancy_week'];
        final babies = provider.babies;
        final hasBaby = provider.hasBaby;

        // Trigger baby stats load if needed
        if (!isPregnant && hasBaby && provider.selectedBabyId != null) {
          // We can check if we should load in HomeProvider
          // Defer to next frame to avoid setState during build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<HomeProvider>().loadBabyStats(
              provider.selectedBabyId!,
            );
          });
        }

        // Calculate baby age from selected baby's birth_date
        int babyAgeWeeks = 0;
        if (hasBaby && provider.selectedBaby != null) {
          final dob = provider.selectedBaby?['birth_date'];
          if (dob != null) {
            final birthDate = DateTime.tryParse(dob.toString());
            if (birthDate != null) {
              babyAgeWeeks = DateTime.now().difference(birthDate).inDays ~/ 7;
            }
          }
        }

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: isPregnant || !hasBaby
                ? Text(
                    '${_getGreeting()}, $name',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: provider.selectedBabyId,
                      hint: Text(
                        '${_getGreeting()}, $name',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      icon: const Icon(
                        Iconsax.arrow_down_1,
                        color: Colors.black,
                      ),
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                      items: babies.map<DropdownMenuItem<String>>((baby) {
                        return DropdownMenuItem<String>(
                          value: baby['_id'],
                          child: Text(baby['name'] ?? 'Baby'),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          provider.selectBaby(newValue);
                          // Force refresh baby stats when baby changes
                          context.read<HomeProvider>().clearBabyStatsCache();
                          context.read<HomeProvider>().loadBabyStats(
                            newValue,
                            forceRefresh: true,
                          );
                        }
                      },
                    ),
                  ),
            actions: [
              IconButton(
                icon: const Icon(Iconsax.refresh, color: Colors.black54),
                onPressed: () {
                  context.read<UserStageProvider>().loadProfile();
                  context.read<HomeProvider>().fetchAdditionalStats();
                },
              ),
            ],
          ),
          body: Container(
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isPregnant
                    ? [
                        const Color.fromARGB(255, 158, 204, 200),
                        const Color.fromARGB(255, 226, 223, 222),
                        const Color(0xffeecde6),
                      ]
                    : [
                        const Color(0xFFFCE4EC),
                        const Color(0xFFE1BEE7),
                        const Color(0xFFE8EAF6),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  // Added ScrollView for better layout
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getSubtitle(
                          isPregnant,
                          hasBaby,
                          pregnancyWeek,
                          babyAgeWeeks,
                        ),
                        style: const TextStyle(
                          color: Color.fromARGB(255, 103, 109, 103),
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (isPregnant) ...[
                        WeekProgress(week: pregnancyWeek),
                        const SizedBox(height: 12),
                      ],
                      // Removed Expanded/flex as we are in SingleChildScrollView now.
                      // If specific height is needed, Wrap in Container/SizedBox
                      // Original code used Expanded flex:3.
                      // We can give it a bounded height or let it take necessary space.
                      // Let's use a fixed height roughly equivalent or AspectRatio
                      if (isPregnant) ...[
                        SizedBox(
                          height: 350,
                          child: PregnancyVisual(week: pregnancyWeek),
                        ),
                        const SizedBox(height: 12),
                        const PregnancyTracker(),
                      ] else if (hasBaby) ...[
                        SizedBox(
                          height: 350,
                          child: PostnatalVisual(babyAgeWeeks: babyAgeWeeks),
                        ),
                        const SizedBox(height: 12),
                        const RecoveryTracker(),
                      ] else ...[
                        // No baby registered - show placeholder
                        const NoBabyPlaceholder(),
                      ],
                      const SizedBox(height: 12),
                      const SOSQuickAccess(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
