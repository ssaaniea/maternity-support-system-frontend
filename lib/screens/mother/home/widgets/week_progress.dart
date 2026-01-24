import 'package:flutter/material.dart';

class WeekProgress extends StatelessWidget {
  final int? week;

  const WeekProgress({super.key, this.week});

  @override
  Widget build(BuildContext context) {
    final currentWeek = week ?? 0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final widgetWidth = constraints.maxWidth;
        // Calculate width so all 40 items fit within available space
        // Total items = 40, we need gaps between them (39 gaps)
        // item_width * 40 + gap * 39 <= widgetWidth
        const totalItems = 40;
        // Set gap as 20% of item width
        // item_width * 40 + item_width * 0.2 * 39 <= widgetWidth
        // item_width * (40 + 7.8) <= widgetWidth
        // item_width <= widgetWidth / 47.8
        final itemWidth = widgetWidth / 50; // Slightly smaller to ensure fit
        final gap = itemWidth * 0.25;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 1; i <= totalItems; i++) ...[
              Container(
                width: itemWidth,
                height: i == currentWeek ? 40 : 30,
                decoration: BoxDecoration(
                  color: i < currentWeek
                      ? const Color.fromRGBO(230, 151, 212, 1)
                      : i == currentWeek
                      ? const Color.fromARGB(255, 230, 134, 190)
                      : const Color.fromARGB(255, 180, 180, 180),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              if (i < totalItems) SizedBox(width: gap),
            ],
          ],
        );
      },
    );
  }
}
