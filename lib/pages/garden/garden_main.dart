import 'package:bogcha_time/pages/garden/account/account_page.dart';
import 'package:bogcha_time/pages/garden/activities/activities.dart';
import 'package:bogcha_time/pages/garden/food/eating.dart';
import 'package:bogcha_time/pages/garden/home/garden.dart';
import 'package:flutter/material.dart';
import 'package:water_drop_nav_bar/water_drop_nav_bar.dart';

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
    const ActivitiesGarden(),
    const AccountGarden(),
  ];


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(title: const Text('Bog\'cha vaqtini boshqarish')),

      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      bottomNavigationBar: WaterDropNavBar(
        iconSize: 3,
        backgroundColor: Colors.white, 
        waterDropColor: Colors.blue,
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemTapped,
        barItems:  [
          BarItem(
            filledIcon: Icons.home_rounded,
            outlinedIcon: Icons.home_outlined,
          ),
          BarItem(
            filledIcon: Icons.restaurant_rounded,
            outlinedIcon: Icons.restaurant_menu_rounded,
          ),
          BarItem(
            filledIcon: Icons.photo_library_rounded,
            outlinedIcon: Icons.photo_library_outlined,
          ),
          BarItem(
            filledIcon: Icons.person_rounded,
            outlinedIcon: Icons.person_outline_rounded,
          ),
        ],
      ),
    );
  }
}
