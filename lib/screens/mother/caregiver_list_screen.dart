import 'package:flutter/material.dart';

class CaregiverListScreen extends StatelessWidget {
  const CaregiverListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Caregiver'),
      ),
      body: ListView.separated(
        itemBuilder: (context, index) => Container(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  spacing: 12,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 0, 0, 0),
                        borderRadius: BorderRadius.circular(200),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 2,
                      children: [
                        Text(
                          'selena gomez',

                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Stems Morazha',

                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 136, 239, 135),
                    elevation: 0,
                  ),
                  onPressed: () => {},
                  child: Text(
                    'BOOK NOW!',

                    style: TextStyle(
                      fontSize: 10,
                      color: const Color.fromARGB(255, 248, 247, 247),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        separatorBuilder: (context, index) => Divider(),
        itemCount: 100,
      ),
    );
  }
}
