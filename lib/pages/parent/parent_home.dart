import 'package:bogcha_time/pages/parent/activates/activates.dart';
import 'package:bogcha_time/pages/parent/children/children_page.dart';
import 'package:bogcha_time/pages/parent/profil/profil.dart';
import 'package:bogcha_time/pages/parent/food/food.dart';
import 'package:flutter/material.dart';
import 'package:bogcha_time/common/style/app_colors.dart';

class ParentsPage extends StatefulWidget {
  const ParentsPage({super.key});

  @override
  _ParentsPageState createState() => _ParentsPageState();
}

class _ParentsPageState extends State<ParentsPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    ChildrenPage(),
    FoodPage(),
    Activates(),
    Profil(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(3, 3),
              blurRadius: 5,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.8),
              offset: const Offset(-3, -3),
              blurRadius: 5,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: AppColors.defoltColor1,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                _currentIndex == 0
                    ? Icons.child_care_rounded
                    : Icons.child_care_outlined,
              ),
              label: "Bolalar",
            ),
            BottomNavigationBarItem(
              icon: Icon(
                _currentIndex == 1
                    ? Icons.fastfood_rounded
                    : Icons.fastfood_outlined,
              ),
              label: "Taomnoma",
            ),
            BottomNavigationBarItem(
              icon: Icon(
                _currentIndex == 2
                    ? Icons.school_rounded
                    : Icons.school_outlined,
              ),
              label: "Mashg‘ulotlar",
            ),
            BottomNavigationBarItem(
              icon: Icon(
                _currentIndex == 3
                    ? Icons.person_rounded
                    : Icons.person_outline,
              ),
              label: "Profil",
            ),
          ],
        ),
      ),
    );
  }
}
