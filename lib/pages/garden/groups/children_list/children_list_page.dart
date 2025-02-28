import 'dart:convert';

import 'package:bogcha_time/app/router.dart';
import 'package:bogcha_time/common/my_custom_widgets/my_custom_container.dart';
import 'package:bogcha_time/common/style/app_colors.dart';
import 'package:bogcha_time/common/style/app_style.dart';
import 'package:bogcha_time/pages/garden/groups/children_list/add_child.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: Icon(Icons.arrow_back, color: AppColors.foregroundColor),
        ),
        backgroundColor: AppColors.defoltColor1,

        title: Text(
          "children_in_group",
          style: AppStyle.fontStyle.copyWith(
            color: AppColors.foregroundColor,
            fontSize: 20,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.defoltColor1,

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddChildScreen(groupId: groupId),
              ),
            ),
        child: const Icon(Icons.add, color: AppColors.foregroundColor),
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
            children:
                snapshot.data!.docs.map((doc) {
                  return NeumorphicContainer(
                    margin: const EdgeInsets.only(top: 20, left: 10, right: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            doc['child_photo'].isNotEmpty
                                ? NetworkImage(doc['child_photo'])
                                : null,
                        child:
                            doc['child_photo'].isNotEmpty
                                ? null
                                : Text(doc['child_name'][0]),
                      ),

                      title: Text(
                        "${doc['child_name']} ${doc['child_surname']}",
                        style: AppStyle.fontStyle.copyWith(fontSize: 16),
                      ),
                      subtitle: Text(
                        "Дата рождения: ${doc['child_birthdate'] ?? 'Не указано'}",
                        style: AppStyle.fontStyle.copyWith(fontSize: 14),
                      ),
                      trailing: PopupMenuButton<String>(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                offset: const Offset(2, 2),
                                blurRadius: 5,
                              ),
                              BoxShadow(
                                color: Colors.white.withOpacity(0.7),
                                offset: const Offset(-2, -2),
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.more_vert,
                            color: Colors.grey,
                          ),
                        ),
                        color: AppColors.backgroundColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onSelected: (value) {
                          if (value == "qr") {
                          _showQRCode(context, FirebaseAuth.instance.currentUser?.uid ?? "", doc['unique_code']);

                          } else if (value == "info") {
                            _showChildDetails(context, doc);
                          } else if (value == "change_group") {
                            _changeGroup(context, doc.id);
                          }
                        },
                        itemBuilder:
                            (context) => [
                              _buildNeumorphicMenuItem(
                                "qr",
                                Icons.qr_code,
                                "Показать QR-код",
                              ),
                              _buildNeumorphicMenuItem(
                                "info",
                                Icons.info,
                                "Информация",
                              ),
                              _buildNeumorphicMenuItem(
                                "change_group",
                                Icons.swap_horiz,
                                "Сменить группу",
                              ),
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

  PopupMenuItem<String> _buildNeumorphicMenuItem(
    String value,
    IconData icon,
    String text,
  ) {
    return PopupMenuItem(
      value: value,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(2, 2),
              blurRadius: 4,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.6),
              offset: const Offset(-2, -2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.defoltColor1),
            const SizedBox(width: 10),
            Text(text, style: AppStyle.fontStyle),
          ],
        ),
      ),
    );
  }

 void _showQRCode(BuildContext context, String gardenId, String uniqueCode) {
  // ✅ Формируем JSON-объект с `garden_id` и `unique_code`
  String qrData = jsonEncode({
    "garden_id": gardenId,
    "unique_code": uniqueCode,
  });

  showModalBottomSheet(
    backgroundColor: AppColors.backgroundColor,
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "QR-kod bolaga",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // ✅ Генерация QR-кода с JSON-данными
            Container(
              width: 200,
              height: 200,
              child: PrettyQrView.data(
                data: qrData, // Передаем JSON-строку
                errorCorrectLevel: QrErrorCorrectLevel.H,
                decoration: const PrettyQrDecoration(
                  shape: PrettyQrSmoothSymbol(color: Colors.black),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ✅ Отображение JSON-строки для проверки
            SelectableText(
              qrData,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
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
      isScrollControlled: true,
      context: context,
      backgroundColor: AppColors.backgroundColor,
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
              Center(
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.backgroundColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            offset: const Offset(4, 4),
                            blurRadius: 6,
                          ),
                          BoxShadow(
                            color: Colors.white.withOpacity(0.7),
                            offset: const Offset(-4, -4),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            child['child_photo'].isNotEmpty
                                ? NetworkImage(child['child_photo'])
                                : null,
                        child:
                            child['child_photo'].isEmpty
                                ? const Icon(Icons.person, size: 50)
                                : null,
                      ),
                    ),

                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          context.pop();
                          context.push(
                            Routes.editChildPage,
                            extra: {
                              'childId': child.id,
                              'childData': {
                                ...child.data() as Map<String, dynamic>,
                                'garden_id':
                                    FirebaseAuth.instance.currentUser?.uid,
                              },
                            },
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.defoltColor1,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                offset: const Offset(2, 2),
                                blurRadius: 4,
                              ),
                              BoxShadow(
                                color: Colors.white.withOpacity(0.6),
                                offset: const Offset(-2, -2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(6),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),

              Center(
                child: Text(
                  "Информация о ребенке",
                  style: AppStyle.fontStyle.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 15),

              _infoRow("Имя", child['child_name']),
              Divider(color: Colors.grey),
              _infoRow("Фамилия", child['child_surname']),
              Divider(color: Colors.grey),
              _infoRow("Фамилия", child['child_last_name']),
              Divider(color: Colors.grey),
              _infoRow(
                "Дата рождения",
                (child['child_birthdate'] ?? "Не указано").toString(),
              ),
              Divider(color: Colors.grey),
              _infoRow("Пол", child['child_gender']),
              Divider(color: Colors.grey),

              const SizedBox(height: 20),

              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  onPressed: () => _deleteChild(context, gardenId, child.id),
                  child: const Text(
                    "Удалить ребенка",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

 void _deleteChild(
  BuildContext context,
  String gardenId,
  String childId,
) async {
  bool confirmDelete = await _showDeleteConfirmationDialog(context);
  if (!confirmDelete) return;

  try {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // 🔹 1. Bola ma’lumotlarini olish
    DocumentSnapshot childDoc = await firestore
        .collection('garden')
        .doc(gardenId)
        .collection('children')
        .doc(childId)
        .get();

    if (!childDoc.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Xatolik: Bola topilmadi!")),
      );
      return;
    }

    // 🔹 2. Ota-onani aniqlash va bolalar ro‘yxatidan olib tashlash
    Map<String, dynamic> childData = childDoc.data() as Map<String, dynamic>;
    String? parentId = childData['parent_id'];

    if (parentId != null) {
      DocumentReference parentRef = firestore.collection('parents').doc(parentId);
      DocumentSnapshot parentDoc = await parentRef.get();

      if (parentDoc.exists) {
        Map<String, dynamic> parentData = parentDoc.data() as Map<String, dynamic>;
        List<dynamic> linkedChildren = List<dynamic>.from(parentData['linked_children'] ?? []);

        // 🔹 3. Ota-ona profilidan bolani olib tashlash
        linkedChildren.remove(childId);
        await parentRef.update({'linked_children': linkedChildren});

        // ✅ Agar ota-onada boshqa bola qolmasa, ota-ona hujjatini o‘chirib tashlash
        if (linkedChildren.isEmpty) {
          await parentRef.delete();
        }
      }
    }

    // 🔹 4. Bolani Firestore'dan o‘chirish
    await firestore.collection('garden').doc(gardenId).collection('children').doc(childId).delete();

    // 🔹 5. UI yangilash va xabar chiqarish
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Bola muvaffaqiyatli o‘chirildi!")),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("❌ Xatolik: $e")),
    );
  }
}


  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text("Удалить ребенка?"),
                content: const Text(
                  "Вы уверены, что хотите удалить этого ребенка? Это действие необратимо.",
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

  /// 🔹 Функция для смены группы ребенка
  void _changeGroup(BuildContext context, String childId) {
    final String? gardenId = FirebaseAuth.instance.currentUser?.uid;
    if (gardenId == null) return;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('garden')
                  .doc(gardenId)
                  .collection('groups')
                  .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return const Center(child: CircularProgressIndicator());

            return ListView(
              children:
                  snapshot.data!.docs.map((doc) {
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

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(
            title,
            style: AppStyle.fontStyle.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: AppStyle.fontStyle.copyWith(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
