import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class MealAddPage extends StatefulWidget {
  const MealAddPage({super.key});

  @override
  _MealAddPageState createState() => _MealAddPageState();
}

class _MealAddPageState extends State<MealAddPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  String? _selectedMealType;
  File? _selectedImage;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  /// 🔹 Выбор изображения (камера/галерея)
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  /// 🔹 Загрузка изображения в **Firebase Storage** и получение URL
  Future<String?> _uploadPhoto(String mealUuid) async {
    if (_selectedImage == null) return null;

    try {
      final String? gardenId = _auth.currentUser?.uid;
      if (gardenId == null) return null;

      final storageRef = _storage.ref().child('meals/$gardenId/$mealUuid.jpg');
      await storageRef.putFile(_selectedImage!);
      return await storageRef.getDownloadURL(); // 📌 Получаем ссылку на загруженный файл
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Ошибка загрузки: $e")));
      return null;
    }
  }

  /// 🔹 Добавление еды в Firestore
  Future<void> _addMeal() async {
    if (_nameController.text.isEmpty || _timeController.text.isEmpty || _selectedMealType == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final String? gardenId = _auth.currentUser?.uid;
      if (gardenId == null) return;

      final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final String mealUuid = const Uuid().v4().substring(0, 8);

      // 📌 Загружаем фото в Firebase Storage
      String? photoUrl = await _uploadPhoto(mealUuid);

      await _firestore
          .collection('garden')
          .doc(gardenId)
          .collection('meals')
          .doc(today)
          .collection('items')
          .add({
        'uuid': mealUuid,
        'name': _nameController.text.trim(),
        'time': _timeController.text.trim(),
        'type': _selectedMealType,
        'image': photoUrl ?? '', // 📌 URL фото в Storage
        'created_at': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Еда добавлена!")));
      Navigator.pop(context);
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
      appBar: AppBar(title: const Text("Добавить еду")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Выберите тип приема пищи", style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: _selectedMealType,
                isExpanded: true,
                hint: const Text("Выберите"),
                items: ["Завтрак", "Обед", "Полдник"].map((String type) {
                  return DropdownMenuItem<String>(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedMealType = value;
                  });
                },
              ),
              const SizedBox(height: 15),
              _buildTextField(_nameController, "Название блюда"),
              _buildTextField(_timeController, "Время подачи (чч:мм)"),

              const SizedBox(height: 15),

              Center(
                child: Column(
                  children: [
                    if (_selectedImage != null)
                      Image.file(_selectedImage!, width: 150, height: 150, fit: BoxFit.cover),
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _addMeal,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text("Добавить еду"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 Поле ввода
  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      ),
    );
  }
}
