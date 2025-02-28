import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bogcha_time/common/style/app_colors.dart';
import 'package:bogcha_time/common/style/app_style.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FoodPage extends StatefulWidget {
  const FoodPage({super.key});

  @override
  _FoodPageState createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  String? _gardenId;
  bool _isLoading = true;
  String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _loadGardenId();
  }

  /// ✅ **SharedPreferences orqali bog‘cha ID ni olish**
  Future<void> _loadGardenId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? gardenId = prefs.getString('garden_id');

    if (gardenId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _gardenId = gardenId;
    });

    setState(() {
      _isLoading = false;
    });
  }

  /// ✅ **Real vaqt rejimida bugungi taomlarni olish**
  Stream<QuerySnapshot> _getTodayMeals() {
    if (_gardenId == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('garden')
        .doc(_gardenId)
        .collection('meals')
        .doc(today)
        .collection('items')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: const Text("🍽 Bugungi Taomnoma"),
        backgroundColor: AppColors.defoltColor1,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: _getTodayMeals(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "Bugungi taomnoma mavjud emas!",
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: snapshot.data!.docs.map((doc) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: ListTile(
                        leading: const Icon(Icons.fastfood, color: Colors.orange),
                        title: Text(
                          doc['name'],
                          style: AppStyle.fontStyle.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("⏰ ${doc['time']}", style: AppStyle.fontStyle),
                            if (doc['image'].isNotEmpty) ...[
                              const SizedBox(height: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.network(
                                  doc['image'],
                                  height: 120,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
    );
  }
}
