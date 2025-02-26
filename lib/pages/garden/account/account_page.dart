import 'package:bogcha_time/common/style/app_colors.dart';
import 'package:flutter/material.dart';

class AccountGarden extends StatelessWidget {
  const AccountGarden({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: Text('Account'),
      ),
      body: Column(children: [],)
    );
  }
}