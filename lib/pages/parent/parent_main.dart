import 'package:bogcha_time/common/style/app_colors.dart';
import 'package:bogcha_time/common/style/app_style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ParentsPage extends StatefulWidget {
  const ParentsPage({super.key});

  @override
  _ParentsPageState createState() => _ParentsPageState();
}

class _ParentsPageState extends State<ParentsPage> {
  String? _parentId;
  List<String> _linkedChildren = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadParentData();
  }

  Future<void> _loadParentData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? parentId = prefs.getString('parent_id');

    if (parentId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _parentId = parentId;
    });

    try {
      DocumentSnapshot parentDoc = await FirebaseFirestore.instance
          .collection('parents')
          .doc(parentId)
          .get();

      if (parentDoc.exists) {
        Map<String, dynamic> parentData = parentDoc.data() as Map<String, dynamic>;
        List<String> children = List<String>.from(parentData['linked_children'] ?? []);

        setState(() {
          _linkedChildren = children;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("❌ Xatolik: $e");
    }
  }

  Future<DocumentSnapshot?> _getChildData(String childId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? gardenId = prefs.getString('garden_id');

      if (gardenId == null) return null;

      DocumentSnapshot childDoc = await FirebaseFirestore.instance
          .collection('garden')
          .doc(gardenId)
          .collection('children')
          .doc(childId)
          .get();

      return childDoc.exists ? childDoc : null;
    } catch (e) {
      print("❌ Xatolik: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Ota-ona Sahifasi'),
        backgroundColor: AppColors.defoltColor1,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _linkedChildren.isEmpty
              ? const Center(child: Text("Sizga bog‘langan bolalar yo‘q!"))
              : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: _linkedChildren.length,
                  itemBuilder: (context, index) {
                    return FutureBuilder<DocumentSnapshot?>(
                      future: _getChildData(_linkedChildren[index]),
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
                ),
    );
  }
}
