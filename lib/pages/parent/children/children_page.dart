import 'package:bogcha_time/app/router.dart';
import 'package:bogcha_time/common/style/app_colors.dart';
import 'package:bogcha_time/common/style/app_style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChildrenPage extends StatefulWidget {
  const ChildrenPage({super.key});

  @override
  _ParentsPageState createState() => _ParentsPageState();
}

class _ParentsPageState extends State<ChildrenPage> {
  String? _parentId;
  String? _gardenId; // ✅ Bog‘cha ID ni olish uchun o‘zgaruvchi
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadParentData();
  }

  Future<void> _loadParentData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? parentId = prefs.getString('parent_id');
    String? gardenId = prefs.getString('garden_id'); // ✅ Bog‘cha ID-ni olish

    if (parentId == null || gardenId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _parentId = parentId;
      _gardenId = gardenId;
      _isLoading = false;
    });
  }

  /// ✅ **Real vaqtda bog‘langan bolalar ro‘yxatini olish**
  Stream<List<String>> _linkedChildrenStream() {
    if (_parentId == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('parents')
        .doc(_parentId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return [];
      Map<String, dynamic> data = snapshot.data()!;
      return List<String>.from(data['linked_children'] ?? []);
    });
  }

  /// ✅ **Real vaqtda bolalar ma’lumotlarini olish**
  Stream<DocumentSnapshot?> _getChildData(String childId) {
    if (_gardenId == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('garden')
        .doc(_gardenId)
        .collection('children')
        .doc(childId)
        .snapshots()
        .map((snapshot) => snapshot.exists ? snapshot : null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Ota-ona Sahifasi'),
        backgroundColor: AppColors.defoltColor1,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push(Routes.addChildPage),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<String>>(
              stream: _linkedChildrenStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<String> linkedChildren = snapshot.data!;
                if (linkedChildren.isEmpty) {
                  return const Center(child: Text("Sizga bog‘langan bolalar yo‘q!"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: linkedChildren.length,
                  itemBuilder: (context, index) {
                    return StreamBuilder<DocumentSnapshot?>(
                      stream: _getChildData(linkedChildren[index]),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const ListTile(
                            title: Text("Yuklanmoqda..."),
                            subtitle: Text("Ma’lumotlar yuklanmoqda"),
                          );
                        }

                        DocumentSnapshot? childDoc = snapshot.data;
                        if (childDoc == null || !childDoc.exists) {
                          return const ListTile(
                            title: Text("Ma'lumot yo‘q"),
                            subtitle: Text("Bola topilmadi"),
                          );
                        }

                        Map<String, dynamic> childData = childDoc.data() as Map<String, dynamic>;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: childData['child_photo'] != null
                                  ? NetworkImage(childData['child_photo'])
                                  : null,
                              child: childData['child_photo'] == null
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                            title: Text(
                              "${childData['child_name']} ${childData['child_surname']}",
                              style: AppStyle.fontStyle.copyWith(fontSize: 16),
                            ),
                            subtitle: Text(
                              "Tug‘ilgan sana: ${childData['child_birthdate'] ?? 'Noma’lum'}",
                              style: AppStyle.fontStyle.copyWith(fontSize: 14),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
