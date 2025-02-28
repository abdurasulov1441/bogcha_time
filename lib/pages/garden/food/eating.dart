import 'package:bogcha_time/app/router.dart';
import 'package:bogcha_time/common/style/app_colors.dart';
import 'package:bogcha_time/common/style/app_style.dart';
import 'package:bogcha_time/common/my_custom_widgets/my_custom_container.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class MealsPage extends StatefulWidget {
  const MealsPage({super.key});

  @override
  _MealsPageState createState() => _MealsPageState();
}

class _MealsPageState extends State<MealsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

  /// 🔹 Получение еды на сегодня
  Stream<QuerySnapshot> _getTodayMeals() {
    final String? gardenId = _auth.currentUser?.uid;
    if (gardenId == null) return const Stream.empty();

    return _firestore
        .collection('garden')
        .doc(gardenId)
        .collection('meals')
        .doc(today)
        .collection('items')
        .snapshots();
  }

  /// 🔹 Удаление элемента
  Future<void> _deleteMeal(String mealId) async {
    final String? gardenId = _auth.currentUser?.uid;
    if (gardenId == null) return;

    bool confirmDelete = await _showDeleteConfirmation();
    if (!confirmDelete) return;

    try {
      await _firestore
          .collection('garden')
          .doc(gardenId)
          .collection('meals')
          .doc(today)
          .collection('items')
          .doc(mealId)
          .delete();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Блюдо удалено!")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Ошибка при удалении: $e")));
    }
  }

  /// 🔹 Подтверждение удаления
  Future<bool> _showDeleteConfirmation() async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text("Удалить блюдо?"),
                content: const Text(
                  "Вы уверены, что хотите удалить это блюдо?",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("Отмена"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text(
                      "Удалить",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
        ) ??
        false;
  }

  /// 🔹 Показать меню при долгом нажатии
  void _showMealOptions(
    String mealId,
    String mealName,
    String mealTime,
    String mealImage,
    String mealType,

  ) {
    showModalBottomSheet(
      backgroundColor: AppColors.backgroundColor,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Выберите действие",
                style: AppStyle.fontStyle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text("Редактировать"),
                onTap: () {
                  context.pop();
                  context.push(
                    Routes.editMealPage,
                    extra: {
                      'mealId': mealId,
                      'mealName': mealName,
                      'mealTime': mealTime,
                      'mealImage': mealImage,
                      'mealType': mealType,

                    },
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text("Удалить"),
                onTap: () {
                  Navigator.pop(context);
                  _deleteMeal(mealId);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.defoltColor1,
        actions: [
          IconButton(
            onPressed: () {
              context.push(Routes.eatingAddPage);
            },
            icon: Icon(Icons.add, color: AppColors.foregroundColor),
          ),
        ],
        centerTitle: true,
        title: Text(
          "food_for_today",
          style: AppStyle.fontStyle.copyWith(
            fontSize: 20,
            color: AppColors.foregroundColor,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getTodayMeals(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "Нет данных о питании на сегодня.",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children:
                snapshot.data!.docs.map((doc) {
                  return GestureDetector(
                    onLongPress:
                        () => _showMealOptions(
                          doc.id,
                          doc['name'],
                          doc['time'],
                          doc['image'],
                          doc['type'],

                        ),
                    child: NeumorphicContainer(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doc['name'],
                            style: AppStyle.fontStyle.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "⏰ Время: ${doc['time']}",
                            style: AppStyle.fontStyle.copyWith(fontSize: 16),
                          ),
                          if (doc['image'].isNotEmpty) ...[
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.network(
                                doc['image'],
                                height: 180,
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
