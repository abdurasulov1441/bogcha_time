import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class AddChildScreen extends StatefulWidget {
  final String groupId; // 📌 ID группы

  const AddChildScreen({super.key, required this.groupId});

  @override
  _AddChildScreenState createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  String? _selectedGender;
  bool _isLoading = false;
  File? _selectedImage;

  final _formKey = GlobalKey<FormState>();

  /// 📌 Выбор фото (камера/галерея)
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  /// 📌 Загрузка фото в **Firebase Storage** и возврат URL
  Future<String?> _uploadPhoto(String childUuid) async {
    if (_selectedImage == null) return null;

    try {
      final storageRef = FirebaseStorage.instance.ref().child('children/$childUuid.jpg');
      await storageRef.putFile(_selectedImage!);
      return await storageRef.getDownloadURL(); // 📌 Получаем ссылку на загруженный файл
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Ошибка загрузки: $e")));
      return null;
    }
  }

  /// 📌 Добавление ребенка в Firestore
  Future<void> _addChild() async {
    if (!_formKey.currentState!.validate() || _selectedGender == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) throw "Не удалось определить текущего пользователя";

      String gardenId = user.uid;
      String uniqueCode = const Uuid().v4().substring(0, 8);

      // 📌 Загружаем фото в Firebase Storage
      String? photoUrl = await _uploadPhoto(uniqueCode);

      await FirebaseFirestore.instance
          .collection('garden')
          .doc(gardenId)
          .collection('children')
          .add({
        'unique_code': uniqueCode,
        'child_name': _nameController.text.trim(),
        'child_surname': _surnameController.text.trim(),
        'child_last_name': _lastNameController.text.trim(),
        'child_birthdate': _birthdateController.text.trim(),
        'child_gender': _selectedGender,
        'child_photo': photoUrl ?? '', // 📌 URL фото в Storage
        'metrika_photo': '',
        'parent_id': null,
        'group_id': widget.groupId,
        'created_at': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ребенок успешно добавлен! Код: $uniqueCode')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _lastNameController.dispose();
    _birthdateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Добавить ребенка')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(_nameController, 'Имя ребенка'),
                _buildTextField(_surnameController, 'Фамилия ребенка'),
                _buildTextField(_lastNameController, 'Отчество ребенка'),
                _buildTextField(_birthdateController, 'Дата рождения (гггг-мм-дд)'),
                const SizedBox(height: 10),

                /// Выбор пола
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

                /// 📌 Выбор фото
                Center(
                  child: Column(
                    children: [
                      if (_selectedImage != null)
                        Image.file(_selectedImage!, width: 120, height: 120, fit: BoxFit.cover),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _pickImage(ImageSource.camera),
                            icon: const Icon(Icons.camera_alt),
                            label: const Text("Сделать фото"),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            onPressed: () => _pickImage(ImageSource.gallery),
                            icon: const Icon(Icons.image),
                            label: const Text("Выбрать фото"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// Кнопка "Добавить ребенка"
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _addChild,
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text("Добавить ребенка"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Функция для создания поля ввода
  Widget _buildTextField(TextEditingController controller, String hintText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: hintText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: (value) => value == null || value.isEmpty ? "Введите $hintText" : null,
      ),
    );
  }
}
