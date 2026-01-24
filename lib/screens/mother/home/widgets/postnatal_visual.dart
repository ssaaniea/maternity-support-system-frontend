import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:project_frontend/providers/user_stage_provider.dart';

class PostnatalVisual extends StatelessWidget {
  final int babyAgeWeeks;

  const PostnatalVisual({super.key, required this.babyAgeWeeks});

  String _getPostnatalTip(int weeks) {
    if (weeks < 2) {
      return "Rest is essential. Accept help from family and friends.";
    }
    if (weeks < 6) return "Remember to attend your postnatal checkup.";
    if (weeks < 12) return "Gentle walks can help with recovery.";
    return "You're doing amazing! Take care of yourself too.";
  }

  List<Map<String, String>> _getMilestones(int weeks) {
    if (weeks < 2) {
      return [
        {"icon": "👁️", "title": "Focuses", "subtitle": "on faces"},
        {"icon": "🎵", "title": "Startles", "subtitle": "at sounds"},
        {"icon": "🤲", "title": "Grasps", "subtitle": "fingers"},
      ];
    }
    if (weeks < 4) {
      return [
        {"icon": "👀", "title": "Tracks", "subtitle": "objects"},
        {"icon": "🗣️", "title": "Coos", "subtitle": "& gurgles"},
        {"icon": "💪", "title": "Lifts", "subtitle": "head briefly"},
      ];
    }
    if (weeks < 8) {
      return [
        {"icon": "😊", "title": "Social", "subtitle": "smiling"},
        {"icon": "🎯", "title": "Better", "subtitle": "eye tracking"},
        {"icon": "💪", "title": "Stronger", "subtitle": "neck control"},
      ];
    }
    if (weeks < 12) {
      return [
        {"icon": "😄", "title": "Laughs", "subtitle": "out loud"},
        {"icon": "🖐️", "title": "Opens", "subtitle": "hands more"},
        {"icon": "🎵", "title": "Turns to", "subtitle": "sounds"},
      ];
    }
    if (weeks < 16) {
      return [
        {"icon": "🔄", "title": "Rolls", "subtitle": "tummy to back"},
        {"icon": "🧸", "title": "Reaches", "subtitle": "for toys"},
        {"icon": "👋", "title": "Brings hands", "subtitle": "together"},
      ];
    }
    if (weeks < 24) {
      return [
        {"icon": "🪑", "title": "Sits with", "subtitle": "support"},
        {"icon": "🍼", "title": "Ready for", "subtitle": "solids"},
        {"icon": "🗣️", "title": "Babbles", "subtitle": "consonants"},
      ];
    }
    if (weeks < 36) {
      return [
        {"icon": "🐛", "title": "Crawling", "subtitle": "attempts"},
        {"icon": "👋", "title": "Waves", "subtitle": "bye-bye"},
        {"icon": "🧍", "title": "Pulls to", "subtitle": "stand"},
      ];
    }
    return [
      {"icon": "🚶", "title": "First", "subtitle": "steps"},
      {"icon": "🗣️", "title": "Says", "subtitle": "mama/dada"},
      {"icon": "🎉", "title": "Claps", "subtitle": "hands"},
    ];
  }

  String _getWeeklyHighlight(int weeks) {
    if (weeks < 2) return "Baby is adjusting to life outside the womb";
    if (weeks < 4) return "Your baby may start recognizing your voice";
    if (weeks < 6) return "Watch for the first real smiles!";
    if (weeks < 8) return "Baby's neck muscles are getting stronger";
    if (weeks < 12) return "More interactive and playful each day";
    if (weeks < 16) return "Movement and exploration increasing";
    if (weeks < 24) return "Preparing for exciting new foods";
    if (weeks < 36) return "Mobility adventures ahead!";
    return "Almost a toddler - so much growth!";
  }

  @override
  Widget build(BuildContext context) {
    final userStageProvider = context.watch<UserStageProvider>();
    final selectedBaby = userStageProvider.selectedBaby;
    final babyName = selectedBaby?['name'] ?? 'Baby';
    final milestones = _getMilestones(babyAgeWeeks);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with baby info
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Text("👶", style: TextStyle(fontSize: 28)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      babyName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "$babyAgeWeeks week${babyAgeWeeks == 1 ? '' : 's'} old",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Iconsax.heart5,
                      size: 16,
                      color: Colors.green.shade400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Healthy",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Weekly highlight
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade50, Colors.pink.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Iconsax.star1, size: 18, color: Colors.purple.shade400),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getWeeklyHighlight(babyAgeWeeks),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.purple.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Milestones section
          Text(
            "Current Milestones",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),

          // Milestone cards row
          Row(
            children: milestones.map((milestone) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    right: milestone != milestones.last ? 8 : 0,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Text(
                        milestone['icon']!,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        milestone['title']!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        milestone['subtitle']!,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 10),

          // Postnatal tip
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Iconsax.lamp_on, color: Colors.amber.shade700, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getPostnatalTip(babyAgeWeeks),
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
