import 'dart:math';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Hello, Fathima',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 158, 204, 200),
              Color.fromARGB(255, 226, 223, 222),
              Color(0xffeecde6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'In 26 weeks you are going to meet your baby',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 103, 109, 103),
                  ),
                ),
                SizedBox(height: 20),
                GrowthTrackingWidget(),
                FetusWithCardsWidgets(),
                SizedBox(height: 20),
                MammaTracker(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MammaTracker extends StatelessWidget {
  const MammaTracker({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 233, 213, 228),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
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
            "MammaTracker",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 217, 163, 202),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _ChildInfoCard(
                  icon: Icons.monitor_weight,
                  title: 'Weight Track',
                  value: '70',
                  bgColor: Color(0xffeecde6),
                  fgColor: Colors.black,
                  valueColor: Colors.black,
                  onTap: () {
                    print("Weight Track");
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ChildInfoCard(
                  icon: Icons.favorite,
                  title: 'BP Track',
                  value: '120/80',
                  bgColor: Color(0xffeecde6),
                  fgColor: Colors.black,
                  valueColor: Colors.black,
                  onTap: () {
                    print("BP Track");
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ChildInfoCard(
                  icon: Icons.sick,
                  title: 'Symptoms',
                  value: '2 noted',
                  bgColor: Color(0xffeecde6),
                  fgColor: Colors.black,
                  valueColor: Colors.black,
                  onTap: () {
                    print("symptoms");
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChildInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color bgColor;
  final Color fgColor;
  final Color? valueColor;
  final VoidCallback? onTap;

  const _ChildInfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.bgColor,
    required this.fgColor,
    this.valueColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 28, color: fgColor),
            Text(
              title,
              style: TextStyle(
                color: fgColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              value.isNotEmpty ? value : "-",
              style: TextStyle(
                color: valueColor ?? fgColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GrowthTrackingWidget extends StatelessWidget {
  const GrowthTrackingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final widgetWidth = constraints.maxWidth;
            final singleItemWidth = widgetWidth / 41;
            final containerWidth = singleItemWidth / 3;
            final margin = (singleItemWidth / 3);
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (int i = 1; i <= 25; i++)
                  Container(
                    width: containerWidth,
                    height: 30,
                    margin: EdgeInsets.only(right: margin, left: margin),
                    color: const Color.fromRGBO(230, 151, 212, 1),
                  ),
                Container(
                  width: containerWidth,
                  height: 40,
                  margin: EdgeInsets.only(right: margin, left: margin),
                  color: const Color.fromARGB(208, 230, 134, 190),
                ),
                for (int i = 1; i <= (40 - 26); i++)
                  Container(
                    width: containerWidth,
                    height: 30,
                    margin: EdgeInsets.only(right: margin, left: margin),
                    color: const Color.fromARGB(255, 121, 120, 121),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class FetusWithCardsWidgets extends StatelessWidget {
  const FetusWithCardsWidgets({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(80.0),
              child: Image.asset(
                'assets/images/fetus.jpg',
                width: 200,
              ),
            ),
          ),
        ),
        Positioned(
          top: 200,
          left: 21,
          child: Transform.rotate(
            angle: -pi / 6,
            child: Container(
              width: 120,
              height: 100,
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: const Color.fromARGB(199, 233, 233, 233),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color.fromARGB(
                          255,
                          240,
                          239,
                          236,
                        ),
                        child: Image.asset(
                          'assets/images/bone.png',
                          width: 20,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Av.weight',
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              color: const Color.fromARGB(255, 158, 150, 150),
                            ),
                          ),
                          Text(
                            '900g',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: const Color.fromARGB(255, 24, 24, 24),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 110,
          right: 21,
          child: Transform.rotate(
            angle: 30 * pi / 180,
            child: Container(
              width: 120,
              height: 100,
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: const Color.fromARGB(199, 233, 233, 233),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color.fromARGB(
                          255,
                          245,
                          242,
                          236,
                        ),
                        child: Image.asset(
                          'assets/images/height.png',
                          width: 20,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Av.height',
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              color: const Color.fromARGB(
                                255,
                                158,
                                150,
                                150,
                              ),
                            ),
                          ),
                          Text(
                            '1.1cm',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
