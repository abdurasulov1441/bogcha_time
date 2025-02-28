import 'package:bogcha_time/common/style/app_colors.dart';
import 'package:bogcha_time/pages/auth/account_screen.dart';
import 'package:bogcha_time/pages/garden/activities/activities.dart';
import 'package:bogcha_time/pages/garden/groups/groups_page.dart';
import 'package:bogcha_time/pages/garden/food/eating.dart';
import 'package:flutter/material.dart';

class GardenPage extends StatefulWidget {
  const GardenPage({super.key});

  @override
  _GardenPageState createState() => _GardenPageState();
}

class _GardenPageState extends State<GardenPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const GroupsPage(),
    const MealsPage(),
    const ActivitiesGarden(),
    const AccountScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundColor,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                offset: const Offset(3, 3),
                blurRadius: 6,
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.7),
                offset: const Offset(-3, -3),
                blurRadius: 6,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              backgroundColor: AppColors.backgroundColor,
              selectedItemColor: AppColors.defoltColor1,
              unselectedItemColor: Colors.black45,
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.groups_outlined),
                  activeIcon: Icon(Icons.groups_rounded),
                  label: 'Guruhlar',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.fastfood_outlined),
                  activeIcon: Icon(Icons.fastfood_rounded),
                  label: 'Taomnoma',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.event_note_outlined),
                  activeIcon: Icon(Icons.event_note_rounded),
                  label: 'Mashg‘ulotlar',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_circle_outlined),
                  activeIcon: Icon(Icons.account_circle_rounded),
                  label: 'Profil',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
