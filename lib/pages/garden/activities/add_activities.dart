import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class AddActivityPage extends StatefulWidget {
  const AddActivityPage({super.key});

  @override
  _AddActivityPageState createState() => _AddActivityPageState();
}

class _AddActivityPageState extends State<AddActivityPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  File? _selectedMedia;
  String? _selectedGroupId;
  String? _selectedChildId;
  bool _isUploading = false;
  List<Map<String, dynamic>> _groups = [];
  List<Map<String, String>> _children = [];

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  /// 📌 **Определение `gardenId`**
  String? _getGardenId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  /// 📌 **Загрузка списка групп из Firestore**
  Future<void> _loadGroups() async {
    String? gardenId = _getGardenId();
    if (gardenId == null) return;
FirebaseFirestore.instance
    .collection('garden')
    .doc(gardenId)
    .collection('groups')
    .get()
    .then((snapshot) {
  List<Map<String, dynamic>> groups = snapshot.docs.map((doc) {
    return {
      'id': doc.id,
      'name': doc['group_name'] ?? 'No Name', // Исправлено, чтобы избежать ошибки
    };
  }).toList(); // ✅ Убедимся, что результат преобразуется в List

  setState(() {
    _groups = groups;
  });
}).catchError((error) {
  print("Ошибка при загрузке групп: $error");
});
  }

  /// 📌 **Загрузка списка детей из выбранной группы**
  Future<void> _loadChildren(String groupId) async {
    String? gardenId = _getGardenId();
    if (gardenId == null) return;

    FirebaseFirestore.instance
        .collection('garden')
        .doc(gardenId)
        .collection('children')
        .where('group_id', isEqualTo: groupId)
        .get()
        .then((snapshot) {
      List<Map<String, String>> children = snapshot.docs.map((doc) {
        return {'id': doc.id, 'name': "${doc['child_name']} ${doc['child_surname']}"};
      }).toList();

      setState(() {
        _children = children;
      });
    });
  }

  /// 📌 **Выбор фото/видео**
  Future<void> _captureMedia() async {
    final pickedFile = await ImagePicker().pickVideo(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _selectedMedia = File(pickedFile.path);
      });
    }
  }

  /// 📌 **Загрузка файла в Firebase Storage**
  Future<String?> _uploadMedia(File file) async {
    try {
      String fileName = "activities/${DateTime.now().millisecondsSinceEpoch}.mp4";
      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = storageRef.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Ошибка загрузки: $e")));
      return null;
    }
  }

  /// 📌 **Добавление события в Firestore**
  Future<void> _uploadActivity() async {
    String? gardenId = _getGardenId();
    if (gardenId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Xatolik: Bog‘cha ID aniqlanmadi!")),
      );
      return;
    }

    if (_nameController.text.isEmpty || _timeController.text.isEmpty || _selectedMedia == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Barcha maydonlarni to‘ldiring!")),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    String? mediaUrl = await _uploadMedia(_selectedMedia!);
    if (mediaUrl == null) {
      setState(() {
        _isUploading = false;
      });
      return;
    }

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    Map<String, dynamic> activityData = {
      'name': _nameController.text,
      'time': _timeController.text,
      'media_url': mediaUrl,
      'created_at': FieldValue.serverTimestamp(),
    };

    if (_selectedChildId != null) {
      activityData['child_id'] = _selectedChildId;
    } else if (_selectedGroupId != null) {
      activityData['group_id'] = _selectedGroupId;
    }

    await firestore.collection('garden').doc(gardenId).collection('activities').add(activityData);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Tadbir muvaffaqiyatli qo‘shildi!")),
    );

    setState(() {
      _isUploading = false;
      _selectedMedia = null;
    });
if (GoRouter.of(context).canPop()) {
  context.pop();
}
   
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Faoliyat qo‘shish")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Tadbir nomi")),
            TextField(controller: _timeController, decoration: const InputDecoration(labelText: "Vaqti")),

            DropdownButtonFormField<String>(
              hint: const Text("Guruhni tanlash (ixtiyoriy)"),
              value: _selectedGroupId,
              items: _groups.map<DropdownMenuItem<String>>((group) {
                return DropdownMenuItem<String>(value: group['id'], child: Text(group['name']!));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedGroupId = value;
                  _selectedChildId = null;
                });
                if (value != null) {
                  _loadChildren(value);
                }
              },
            ),

            DropdownButtonFormField<String>(
              hint: const Text("Bolani tanlash (ixtiyoriy)"),
              value: _selectedChildId,
              items: _children.map((child) {
                return DropdownMenuItem(value: child['id'], child: Text(child['name']!));
              }).toList(),
              onChanged: (value) => setState(() => _selectedChildId = value),
            ),

            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _captureMedia,
              child: const Text("📸 Rasm / Video qo‘shish"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isUploading ? null : _uploadActivity,
              child: _isUploading ? const CircularProgressIndicator() : const Text("📌 Tadbirni saqlash"),
            ),
          ],
        ),
      ),
    );
  }
}
