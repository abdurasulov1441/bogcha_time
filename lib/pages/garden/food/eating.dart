import 'package:bogcha_time/app/router.dart';
import 'package:bogcha_time/pages/garden/food/eat_add.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        leading: IconButton(onPressed: (){
          context.push(Routes.eatingAddPage);
        }, icon: Icon(Icons.add)),
        title: const Text("Еда на сегодня")),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getTodayMeals(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Нет данных о питании на сегодня."));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: snapshot.data!.docs.map((doc) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    ListTile(
                      title: Text(doc['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("⏰ Время: ${doc['time']}"),
                    ),
                    if (doc['image'].isNotEmpty)
                      Image.network(doc['image'], height: 150, fit: BoxFit.cover),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
  
    );
  }
}
