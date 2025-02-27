import 'package:bogcha_time/app/router.dart';
import 'package:bogcha_time/common/style/app_colors.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeGarden extends StatelessWidget {
  const HomeGarden({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: Text('Garden'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
        
            SizedBox(height: 30),
          
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

