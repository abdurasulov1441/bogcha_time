import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditChildScreen extends StatefulWidget {
  final String childId;
  final Map<String, dynamic> childData;

  const EditChildScreen({super.key, required this.childId, required this.childData});

  @override
  _EditChildScreenState createState() => _EditChildScreenState();
}

class _EditChildScreenState extends State<EditChildScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  String? _selectedGender;
  File? _newImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.childData['child_name'] ?? '';
    _surnameController.text = widget.childData['child_surname'] ?? '';
    _birthdateController.text = widget.childData['child_birthdate'] ?? '';
    _selectedGender = widget.childData['child_gender'];
  }

  /// 📌 Выбор нового фото
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _newImage = File(pickedFile.path);
      });
    }
  }

  /// 📌 Обновление данных ребенка
  Future<void> _updateChildData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String? newPhotoUrl = widget.childData['child_photo'];

      // ✅ Если выбрано новое фото, загружаем его в Firebase Storage
      if (_newImage != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('children')
            .child('${widget.childId}.jpg');

        await ref.putFile(_newImage!);
        newPhotoUrl = await ref.getDownloadURL();
      }

      // ✅ Обновляем Firestore
      await FirebaseFirestore.instance.collection('garden')
          .doc(widget.childData['garden_id'])
          .collection('children')
          .doc(widget.childId)
          .update({
        'child_name': _nameController.text.trim(),
        'child_surname': _surnameController.text.trim(),
        'child_birthdate': _birthdateController.text.trim(),
        'child_gender': _selectedGender,
        'child_photo': newPhotoUrl,
      });

      Navigator.pop(context); // Закрываем экран после успешного обновления
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Данные обновлены!")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Ошибка: $e")));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Редактировать ребенка")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 📌 Фото ребенка
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _newImage != null
                          ? FileImage(_newImage!)
                          : (widget.childData['child_photo'].isNotEmpty
                              ? NetworkImage(widget.childData['child_photo'])
                              : null) as ImageProvider?,
                      child: _newImage == null && widget.childData['child_photo'].isEmpty
                          ? const Icon(Icons.person, size: 50)
                          : null,
                    ),
                    IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.blueAccent),
                      onPressed: () => _pickImage(ImageSource.gallery),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),

              // 📌 Поля редактирования
              _buildTextField(_nameController, "Имя ребенка"),
              _buildTextField(_surnameController, "Фамилия ребенка"),
              _buildTextField(_birthdateController, "Дата рождения (гггг-мм-дд)"),

              // 📌 Выбор пола
              const Text("Пол ребенка", style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text("Мальчик"),
                      value: "Мальчик",
                      groupValue: _selectedGender,
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text("Девочка"),
                      value: "Девочка",
                      groupValue: _selectedGender,
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 📌 Кнопка "Сохранить изменения"
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateChildData,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text("Сохранить изменения"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
