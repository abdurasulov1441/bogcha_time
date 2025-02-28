import 'package:bogcha_time/common/style/app_colors.dart';
import 'package:flutter/material.dart';

class ActivitiesGarden extends StatelessWidget {
  const ActivitiesGarden({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: const Text('Детский сад'),
      ),
      body: const Center(
        child: Text('Активности детского сада'),
      ),
    );
  }
}