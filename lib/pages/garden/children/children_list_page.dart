import 'package:bogcha_time/pages/garden/children/add_child.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

class ChildrenListPage extends StatelessWidget {
  final String groupId;

  const ChildrenListPage({super.key, required this.groupId});

  /// 🔹 Получение списка детей в группе
  Stream<QuerySnapshot> _getChildren() {
    final String? gardenId = FirebaseAuth.instance.currentUser?.uid;
    if (gardenId == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('garden')
        .doc(gardenId)
        .collection('children')
        .where('group_id', isEqualTo: groupId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Дети в группе")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddChildScreen(groupId: groupId)),
        ),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getChildren(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("В этой группе пока нет детей."));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              return ListTile(
                leading: CircleAvatar(child: Text(doc['child_name'][0])),
                title: Text("${doc['child_name']} ${doc['child_surname']}"),
                subtitle: Text("Дата рождения: ${doc['child_birthdate'] ?? 'Не указано'}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.qr_code, color: Colors.green),
                      onPressed: () => _showQRCode(context, doc['unique_code']),
                    ),
                    IconButton(
                      icon: const Icon(Icons.info, color: Colors.blue),
                      onPressed: () => _showChildDetails(context, doc),
                    ),
                    IconButton(
                      icon: const Icon(Icons.swap_horiz, color: Colors.orange),
                      onPressed: () => _changeGroup(context, doc.id),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  /// 🔹 Функция для отображения QR-кода ребенка
  void _showQRCode(BuildContext context, String uniqueCode) {
    showModalBottomSheet(
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
              const Text("QR-код для ребенка", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Container(
                width: 200,
                height: 200,
                child: PrettyQrView.data(
                  data: uniqueCode,
                  errorCorrectLevel: QrErrorCorrectLevel.H,
                  decoration: const PrettyQrDecoration(
                    shape: PrettyQrSmoothSymbol(color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SelectableText(uniqueCode, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Закрыть"),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 🔹 Функция для отображения информации о ребенке
  void _showChildDetails(BuildContext context, DocumentSnapshot child) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text("Информация о ребенке", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 15),
              _infoRow("👦 Имя", child['child_name']),
              _infoRow("📛 Фамилия", child['child_surname']),
              _infoRow("📅 Дата рождения", child['child_birthdate'] ?? "Не указано"),
              _infoRow("🧑‍⚕ Пол", child['child_gender']),
              _infoRow("🔢 Уникальный код", child['unique_code']),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Закрыть"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 🔹 Функция для смены группы ребенка
  void _changeGroup(BuildContext context, String childId) {
    final String? gardenId = FirebaseAuth.instance.currentUser?.uid;
    if (gardenId == null) return;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('garden').doc(gardenId).collection('groups').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

            return ListView(
              children: snapshot.data!.docs.map((doc) {
                return ListTile(
                  title: Text(doc['group_name']),
                  onTap: () async {
                    await FirebaseFirestore.instance
                        .collection('garden')
                        .doc(gardenId)
                        .collection('children')
                        .doc(childId)
                        .update({'group_id': doc.id});
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            );
          },
        );
      },
    );
  }

  /// 🔹 Функция для форматированного отображения данных
  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 16), overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
