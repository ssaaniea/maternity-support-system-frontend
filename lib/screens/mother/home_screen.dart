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
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Icon(Icons.person_3_outlined),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 158, 204, 200), // First color
              Color.fromARGB(255, 226, 223, 222), // Second color
              Color(0xffeecde6), // Third color
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'in your 26 weeks you are going to meet your baby',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 103, 109, 103),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                GrowthTrackingWidget(),
                FetusWithCardsWidgets(),
                _WeightAndHeightRow(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WeightAndHeightRow extends StatelessWidget {
  const _WeightAndHeightRow({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ChildInfoCard(
            imagePath: 'assets/images/bone.png',
            title: 'Av.weight',
            value: '900g',
            bgColor: const Color.fromARGB(255, 251, 170, 197),
            fgColor: const Color.fromARGB(255, 245, 244, 244),
          ),
        ),
        SizedBox(
          width: 8,
        ),
        Expanded(
          child: _ChildInfoCard(
            imagePath: 'assets/images/height.png',
            title: 'Av.height',
            value: '1.1cm',
            bgColor: const Color.fromARGB(255, 242, 235, 235),
            fgColor: const Color.fromARGB(255, 18, 18, 18),
          ),
          // Container(
          //   decoration: BoxDecoration(
          //     borderRadius: BorderRadius.circular(15),
          //     color: const Color.fromARGB(255, 233, 141, 171),
          //   ),
          //   padding: EdgeInsets.all(36),
          //   child: Column(
          //     children: [
          //       Container(
          //         decoration: BoxDecoration(
          //           shape: BoxShape.circle,
          //           color: Colors.white.withOpacity(
          //             0.3,
          //           ),
          //         ),
          //         padding: EdgeInsets.all(36),
          //         child: Image.asset('assets/images/height.png'),
          //       ),

          //       Text('Av.height'),
          //       SizedBox(
          //         height: 5,
          //       ),
          //       Text('1.1cm'),
          //     ],
          //   ),
          // ),
        ),
      ],
    );
  }
}

class _ChildInfoCard extends StatelessWidget {
  const _ChildInfoCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.value,
    required this.bgColor,
    required this.fgColor,
  });

  final String imagePath;
  final String title;
  final String value;

  final Color bgColor;
  final Color fgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(15),
      ),
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(
                0.3,
              ),
            ),
            padding: EdgeInsets.all(12),
            child: Image.asset(
              imagePath,
              color: fgColor,
              width: 30,
              height: 30,
            ),
          ),
          SizedBox(
            height: 80,
          ),
          Text(
            title,
            style: TextStyle(color: fgColor),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            value,
            style: TextStyle(color: fgColor, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class GrowthTrackingWidget extends StatelessWidget {
  const GrowthTrackingWidget({
    super.key,
  });

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
  const FetusWithCardsWidgets({
    super.key,
  });

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

              padding: EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: const Color.fromARGB(199, 233, 233, 233),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '14',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      Icon(Icons.check_circle_rounded),
                    ],
                  ),
                  Text(
                    'Remaining week',
                    style: TextStyle(fontWeight: FontWeight.normal),
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

              padding: EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: const Color.fromARGB(199, 233, 233, 233),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '14',

                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),

                      Icon(Icons.check_circle_rounded),
                    ],
                  ),
                  Text(
                    'Remaining week',
                    style: TextStyle(fontWeight: FontWeight.normal),
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
