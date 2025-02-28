import 'package:bogcha_time/common/my_custom_widgets/my_custom_button.dart';
import 'package:bogcha_time/common/my_custom_widgets/my_custom_container.dart';
import 'package:bogcha_time/common/style/app_colors.dart';
import 'package:bogcha_time/common/style/app_style.dart';
import 'package:bogcha_time/pages/garden/groups/children_list_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  _GroupsPageState createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  final TextEditingController _groupNameController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> _getGroups() {
    final String? gardenId = _auth.currentUser?.uid;
    if (gardenId == null) return const Stream.empty();
    return _firestore.collection('garden').doc(gardenId).collection('groups').snapshots();
  }

  Future<void> _addGroup() async {
    if (_groupNameController.text.isEmpty) return;

    final String? gardenId = _auth.currentUser?.uid;
    if (gardenId == null) return;

    await _firestore.collection('garden').doc(gardenId).collection('groups').add({
      'group_name': _groupNameController.text.trim(),
      'created_at': FieldValue.serverTimestamp(),
    });

    _groupNameController.clear();
  
  }

  void _showAddGroupDialog() {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: AppColors.backgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            
              Text(
                "Добавить новую группу",
                style: AppStyle.fontStyle.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 15),

              
              Container(
                decoration: _neumorphicDecoration(),
                child: TextField(
                  controller: _groupNameController,
                  decoration: const InputDecoration(
                    hintStyle: AppStyle.fontStyle,
                    hintText: "Введите название группы",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                  ),
                ),
              ),

              const SizedBox(height: 20),

             
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _neumorphicButton(
                    text: "Отмена",
                    color: Colors.redAccent,
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 10),
                  _neumorphicButton(
                    text: "Добавить",
                    color: AppColors.defoltColor1,
                    onPressed: () {
                      _addGroup();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _neumorphicButton({required String text, required Color color, required VoidCallback onPressed}) {
  return Expanded(
    child: GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: _neumorphicDecoration(),
        child: Center(
          child: Text(
            text,
            style: AppStyle.fontStyle.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ),
    ),
  );
}

BoxDecoration _neumorphicDecoration() {
  return BoxDecoration(
    color: AppColors.backgroundColor,
    borderRadius: BorderRadius.circular(15),
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
  );
}


  Future<void> _deleteGroup(String groupId) async {
    final String? gardenId = _auth.currentUser?.uid;
    if (gardenId == null) return;

    bool confirmDelete = await _showDeleteConfirmationDialog();
    if (!confirmDelete) return;

    try {
 
      var children = await _firestore
          .collection('garden')
          .doc(gardenId)
          .collection('children')
          .where('group_id', isEqualTo: groupId)
          .get();

      for (var child in children.docs) {
        await child.reference.delete();
      }


      await _firestore.collection('garden').doc(gardenId).collection('groups').doc(groupId).delete();

      Navigator.pop(context); 
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Группа удалена!")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Ошибка при удалении: $e")));
    }
  }


  Future<bool> _showDeleteConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Удалить группу?"),
            content: const Text("Все дети в этой группе также будут удалены!"),
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

  void _showEditGroupDialog(String groupId, String currentName) {
    _groupNameController.text = currentName;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Редактировать группу"),
        content: TextField(
          controller: _groupNameController,
          decoration: const InputDecoration(labelText: "Введите новое название группы"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Отмена"),
          ),
          ElevatedButton(
            onPressed: () async {
              final String? gardenId = _auth.currentUser?.uid;
              if (gardenId == null || _groupNameController.text.isEmpty) return;

              await _firestore
                  .collection('garden')
                  .doc(gardenId)
                  .collection('groups')
                  .doc(groupId)
                  .update({'group_name': _groupNameController.text.trim()});

              Navigator.pop(context);
            },
            child: const Text("Сохранить"),
          ),
        ],
      ),
    );
  }

  void _showGroupOptions(String groupId, String groupName) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text("Редактировать"),
              onTap: () {
                Navigator.pop(context);
                _showEditGroupDialog(groupId, groupName);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text("Удалить"),
              onTap: () => _deleteGroup(groupId),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String? gardenId = _auth.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: _showAddGroupDialog,
            icon: const Icon(Icons.add,color: AppColors.foregroundColor,),
          ),
        ],
        centerTitle: true,
        backgroundColor: AppColors.defoltColor1,
        title:  Text("groups".tr(),style: AppStyle.fontStyle.copyWith(color: AppColors.foregroundColor,fontSize: 20),)
        
        ),
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
              return NeumorphicContainer(
                margin: const EdgeInsets.only(top: 20, left: 16,right: 16),
                child: ListTile(
                
                  title: Text(doc['group_name'],style: AppStyle.fontStyle.copyWith(fontSize: 20),),
                  trailing: StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('garden')
                        .doc(gardenId)
                        .collection('children')
                        .where('group_id', isEqualTo: doc.id)
                        .snapshots(),
                    builder: (context, childSnapshot) {
                      if (!childSnapshot.hasData) return const Text("...");
                      return Text("Jami bolalar: ${childSnapshot.data!.docs.length}",style: AppStyle.fontStyle,); 
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
                  onLongPress: () => _showGroupOptions(doc.id, doc['group_name']), 
                ),
              );
            }).toList(),
          );
        },
      ),
     
    );
  }
}
