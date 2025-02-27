import 'package:bogcha_time/common/style/app_colors.dart';
import 'package:bogcha_time/pages/auth/account_screen.dart';
import 'package:bogcha_time/pages/garden/children/groups_page.dart';
import 'package:bogcha_time/pages/garden/food/eating.dart';
import 'package:bogcha_time/pages/garden/home/garden.dart';
import 'package:flutter/material.dart';

class GardenPage extends StatefulWidget {
  const GardenPage({super.key});

  @override
  _GardenPageState createState() => _GardenPageState();
}

class _GardenPageState extends State<GardenPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeGarden(),
    const EatingGarden(),
    const GroupsPage(),
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


      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue, 
        unselectedItemColor: Colors.grey, 
        showUnselectedLabels: true, 
        type: BottomNavigationBarType.fixed, 
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu_rounded),
            activeIcon: Icon(Icons.restaurant_rounded),
            label: 'Eating',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library_outlined),
            activeIcon: Icon(Icons.photo_library_rounded),
            label: 'Mashg‘ulotlar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
