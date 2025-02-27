import 'package:bogcha_time/pages/garden/children/children_list_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  _GroupsPageState createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  final TextEditingController _groupNameController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔹 Получение списка групп для текущего детского сада
  Stream<QuerySnapshot> _getGroups() {
    final String? gardenId = _auth.currentUser?.uid;
    if (gardenId == null) return const Stream.empty();
    return _firestore
        .collection('garden')
        .doc(gardenId)
        .collection('groups')
        .snapshots();
  }

  /// 🔹 Добавление новой группы
  Future<void> _addGroup() async {
    if (_groupNameController.text.isEmpty) return;

    final String? gardenId = _auth.currentUser?.uid;
    if (gardenId == null) return;

    await _firestore.collection('garden').doc(gardenId).collection('groups').add({
      'group_name': _groupNameController.text.trim(),
      'created_at': FieldValue.serverTimestamp(),
    });

    _groupNameController.clear();
    Navigator.pop(context);
  }

  /// 🔹 Открытие BottomSheet для ввода группы
   /// 🔹 Открытие диалогового окна для ввода группы
  void _showAddGroupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Добавить новую группу"),
        content: TextField(
          controller: _groupNameController,
          decoration: const InputDecoration(labelText: "Введите название группы"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Отмена"),
          ),
          ElevatedButton(
            onPressed: _addGroup, 
            child: const Text("Добавить"),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final String? gardenId = _auth.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Группы")),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getGroups(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Нет групп. Добавьте первую группу!"));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              return ListTile(
                title: Text(doc['group_name']),
                trailing: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('garden')
                      .doc(gardenId)
                      .collection('children')
                      .where('group_id', isEqualTo: doc.id)
                      .snapshots(),
                  builder: (context, childSnapshot) {
                    if (!childSnapshot.hasData) return const Text("...");
                    return Text("${childSnapshot.data!.docs.length}"); // Количество детей в группе
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChildrenListPage(groupId: doc.id),
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGroupDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
