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
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 238, 214, 214),
                        borderRadius: BorderRadius.circular(200),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 2,
                      children: [
                        Text(
                          'fathima ',

                          style: TextStyle(
                            fontSize: 15.5,
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
                    backgroundColor: const Color.fromARGB(255, 153, 241, 152),
                    elevation: 0,
                  ),
                  onPressed: () => {},
                  child: Text(
                    'BOOK NOW!',

                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
