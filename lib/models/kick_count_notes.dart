// Kick count notes and guidance for expecting mothers
class KickCountNotes {
  final String title;
  final String message;
  final String icon;
  final KickCountStatus status;

  KickCountNotes({
    required this.title,
    required this.message,
    required this.icon,
    required this.status,
  });
}

enum KickCountStatus {
  excellent, // 10+ kicks in time period
  good, // 8-9 kicks
  monitor, // 5-7 kicks
  concerning, // < 5 kicks
}

class KickCountGuidance {
  // Get guidance based on kick count and duration
  // durationSeconds: total time in seconds from when the timer started
  static KickCountNotes getKickCountNotes(
    int kickCount,
    int durationSeconds, {
    int pregnancyWeek = 28,
  }) {
    // ACOG recommendation: 10 movements within 2 hours (120 minutes) is normal
    // Normalize all measurements to the 2-hour (7200 seconds) standard
    final normalized = _normalizeKicks(kickCount, durationSeconds);

    if (normalized >= 10) {
      final displayMinutes = (durationSeconds / 60).toStringAsFixed(1);
      return KickCountNotes(
        title: '✅ Excellent Kick Count!',
        message:
            'You felt $kickCount kicks in $displayMinutes minutes. This is excellent! Your baby is very active and showing healthy movement patterns. Keep monitoring as you normally would.',
        icon: '👶',
        status: KickCountStatus.excellent,
      );
    } else if (normalized >= 8) {
      final displayMinutes = (durationSeconds / 60).toStringAsFixed(1);
      return KickCountNotes(
        title: '✅ Good Kick Count',
        message:
            'You felt $kickCount kicks in $displayMinutes minutes. This shows healthy fetal movement. Continue regular kick counting to track your baby\'s patterns.',
        icon: '👶',
        status: KickCountStatus.good,
      );
    } else if (normalized >= 5) {
      final displayMinutes = (durationSeconds / 60).toStringAsFixed(1);
      return KickCountNotes(
        title: '⏱️ Monitor Kick Count',
        message:
            'You felt $kickCount kicks in $displayMinutes minutes. While this is acceptable, every baby is different. Try again in a few hours, especially after:\n'
            '• Eating a meal\n'
            '• Drinking something sweet (juice)\n'
            '• Taking a short walk\n'
            '• Lying on your left side\n\n'
            'If you continue to feel fewer kicks than usual, contact your healthcare provider.',
        icon: '⏰',
        status: KickCountStatus.monitor,
      );
    } else {
      final displayMinutes = (durationSeconds / 60).toStringAsFixed(1);
      return KickCountNotes(
        title: '⚠️ Low Kick Count',
        message:
            'You felt $kickCount kicks in $displayMinutes minutes. This is below the typical range. Try these methods to wake up your baby:\n'
            '• Eat a snack or drink juice\n'
            '• Take a walk or move around\n'
            '• Listen to music\n'
            '• Lie on your left side\n\n'
            'If after 2 hours you still don\'t feel at least 10 kicks, contact your healthcare provider right away. It\'s always better to be safe than sorry!',
        icon: '⚠️',
        status: KickCountStatus.concerning,
      );
    }
  }

  // Normalize kick count to 2-hour (7200 second) equivalent
  // Mathematical formula: (kickCount / durationSeconds) * 7200
  // This gives the equivalent kicks you'd feel in 2 hours at current rate
  static double _normalizeKicks(int kickCount, int durationSeconds) {
    // Handle edge case: if duration is 0, return 0
    if (durationSeconds <= 0) return 0;
    
    // Normalize to 2-hour (7200 second) standard
    // If 10 kicks in 10 seconds: (10 / 10) * 7200 = 7200 (Excellent!)
    // If 10 kicks in 60 seconds: (10 / 60) * 7200 = 1200 (Excellent!)
    // If 10 kicks in 600 seconds (10 mins): (10 / 600) * 7200 = 120 (Excellent!)
    // If 10 kicks in 7200 seconds (2 hours): (10 / 7200) * 7200 = 10 (Excellent!)
    return (kickCount / durationSeconds) * 7200;
  }

  // Get tips for kick counting
  static const String kickCountingTips = '''
📋 KICK COUNTING TIPS

When to Start:
• Begin kick counting at 28 weeks of pregnancy (third trimester)
• Earlier if you feel comfortable and can distinguish movements

How Often to Count:
• Once daily, at the same time each day
• When your baby is typically more active
• ACOG recommends tracking how long it takes to feel 10 movements

What Counts as a Movement:
✓ Kicks
✓ Flutters
✓ Rolls
✓ Jabs
✓ Swishes
✗ Hiccups (don't count these)

Best Times to Count:
• After meals (babies respond to glucose increase)
• Evenings before bed
• When you're resting and can focus
• Avoid counting when you're busy or distracted

Baby Activity Patterns:
• Each baby has its own unique movement pattern
• It's normal for activity to vary throughout the day
• Babies sleep 20-40 minutes at a time
• Movement typically increases in the third trimester

What NOT to Worry About:
• Different types of movements (rolls vs. kicks)
• Variation from day to day
• Slower movement before labor (just fewer kicks, more rolls)

When to Contact Your Doctor:
• Significant decrease in normal movement patterns
• Fewer than 10 movements in 2 hours (after 2nd attempt)
• Any unusual changes in movement
• Any concerns or questions

Remember: You know your baby best. Trust your instincts!
''';

  // Get tips based on pregnancy week
  static String getTipsForWeek(int pregnancyWeek) {
    if (pregnancyWeek < 20) {
      return 'Movements may be faint and hard to distinguish. Don\'t worry if you\'re not feeling them yet. Most mothers start feeling kicks around 20 weeks.';
    } else if (pregnancyWeek < 24) {
      return 'Movements are becoming more noticeable. You might feel flutters or butterflies. Keep tracking to understand your baby\'s patterns.';
    } else if (pregnancyWeek < 28) {
      return 'Movements are more distinct now. Begin regular kick counting to establish your baby\'s normal patterns.';
    } else {
      return 'You\'re in the third trimester! Daily kick counting is recommended. You should know your baby\'s activity patterns well by now.';
    }
  }

  // Get what kick count feels like
  static const String kickCountFeels = '''
WHAT DO FETAL KICKS FEEL LIKE?

Different Sensations:
🦶 Kicks - Sharp, localized movements
🌊 Rolls - Waves or flowing movements across your belly
✨ Flutters - Butterfly-like sensations, especially early
💫 Jabs - Poking or jabbing motions
🎯 Swishes - Swooshing movements

First Movements:
• May feel like gas, muscle spasms, or butterflies
• Can be hard to distinguish at first
• Become clearer as pregnancy progresses
• More noticeable after meals or when resting

Third Trimester Changes:
• Movements become stronger and more organized
• You'll see your belly visibly change shape
• Some movements might be uncomfortable
• Fewer kicks but more rolls (baby is bigger)
• Distinct patterns emerge

Location:
• Movements felt in different areas depending on baby's position
• Can feel near the sides, center, or lower abdomen
• May be stronger on one side if baby is positioned that way

Tips for Feeling Kicks:
1. Lie on your left side for better blood flow
2. Place your hands on your belly
3. Avoid caffeine/stimulants before counting
4. Choose a quiet time with fewer distractions
5. Count at the same time each day
''';
}
