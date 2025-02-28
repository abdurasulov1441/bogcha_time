import 'package:bogcha_time/common/style/app_colors.dart';
import 'package:bogcha_time/common/style/app_style.dart';
import 'package:bogcha_time/pages/garden/groups/add_child.dart';
import 'package:bogcha_time/pages/garden/groups/edit_child_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

class ChildrenListPage extends StatelessWidget {
  final String groupId;

  const ChildrenListPage({super.key, required this.groupId});

  /// 🔹 Получение списка детей в группе
 Stream<QuerySnapshot>? _getChildren() {
  final String? gardenId = FirebaseAuth.instance.currentUser?.uid;
  if (gardenId == null) return null; // ✅ Вернем null, а не пустой поток

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
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.defoltColor1,
        
        title:  Text("children_in_group",style: AppStyle.fontStyle.copyWith(color: AppColors.foregroundColor,fontSize: 20),),),
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
                leading: CircleAvatar(
  backgroundImage: doc['child_photo'].isNotEmpty
      ? NetworkImage(doc['child_photo']) // ✅ Загружает фото, если есть
      : null, 
  child: doc['child_photo'].isNotEmpty ? null : Text(doc['child_name'][0]), // ✅ Если нет фото, показывает первую букву
),

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
void _showChildDetails(BuildContext context, DocumentSnapshot child) {
  final String? gardenId = FirebaseAuth.instance.currentUser?.uid;
  if (gardenId == null) return;

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
            // 📌 Фото ребенка + кнопка редактирования
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: child['child_photo'].isNotEmpty
                      ? NetworkImage(child['child_photo'])
                      : null,
                  child: child['child_photo'].isEmpty
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blueAccent),
                  onPressed: () {
                    Navigator.pop(context); // Закрыть инфо перед переходом
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditChildScreen(
                          childId: child.id,
                          childData: child.data() as Map<String, dynamic>,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 15),

            const Center(
              child: Text(
                "Информация о ребенке",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 15),

            _infoRow("👦 Имя", child['child_name']),
            _infoRow("📛 Фамилия", child['child_surname']),
            _infoRow("📅 Дата рождения", (child['child_birthdate'] ?? "Не указано").toString()),
            _infoRow("🧑‍⚕ Пол", child['child_gender']),

            const SizedBox(height: 20),

            // 📌 Кнопка удаления ребенка
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => _deleteChild(context, gardenId, child.id),
                child: const Text("Удалить ребенка", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      );
    },
  );
}


void _deleteChild(BuildContext context, String gardenId, String childId) async {
  bool confirmDelete = await _showDeleteConfirmationDialog(context);
  if (!confirmDelete) return;

  try {
    await FirebaseFirestore.instance
        .collection('garden')
        .doc(gardenId)
        .collection('children')
        .doc(childId)
        .delete();

    Navigator.pop(context); // Закрываем BottomSheet после удаления

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Ребенок успешно удален")),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Ошибка при удалении: $e")),
    );
  }
}
Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Удалить ребенка?"),
          content: const Text("Вы уверены, что хотите удалить этого ребенка? Это действие необратимо."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Отмена"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Удалить", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ) ??
      false;
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
