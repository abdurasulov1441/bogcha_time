import 'dart:io';
import 'package:bogcha_time/common/style/app_colors.dart';
import 'package:bogcha_time/common/style/app_style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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


  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }


  Future<String?> _uploadPhoto(String mealUuid) async {
    if (_selectedImage == null) return null;

    try {
      final String? gardenId = _auth.currentUser?.uid;
      if (gardenId == null) return null;

      final storageRef = _storage.ref().child('meals/$gardenId/$mealUuid.jpg');
      await storageRef.putFile(_selectedImage!);
      return await storageRef.getDownloadURL(); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Ошибка загрузки: $e")));
      return null;
    }
  }


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
        'image': photoUrl ?? '',
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
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          context.pop();
        }, icon: Icon(Icons.arrow_back, )),
        backgroundColor: AppColors.backgroundColor,
        
        title:  Text("Добавить еду")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Выберите тип приема пищи", style: TextStyle(fontWeight: FontWeight.bold)),
             _buildNeumorphicDropdown(),
              const SizedBox(height: 15),
              _buildNeumorphicTextField(_nameController, "Название блюда"),
_buildNeumorphicTextField(_timeController, "Время подачи (чч:мм)"),

              const SizedBox(height: 15),

              Center(
                child: Column(
                  children: [
                   _buildNeumorphicImage(),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                       _buildNeumorphicButton(
                      text: "📷 Камера",
                      onPressed: () => _pickImage(ImageSource.camera),
                    ),
                    const SizedBox(width: 10),
                    _buildNeumorphicButton(
                      text: "🖼 Галерея",
                      onPressed: () => _pickImage(ImageSource.gallery),
                    ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child:_buildNeumorphicButton(
  text: _isLoading ? "Загрузка..." : "Добавить еду",
  onPressed: _isLoading ? () {} : _addMeal,
),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNeumorphicTextField(TextEditingController controller, String label) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
    margin: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(
      color: AppColors.backgroundColor,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.1), offset: const Offset(3, 3), blurRadius: 5),
        BoxShadow(color: Colors.white.withOpacity(0.8), offset: const Offset(-3, -3), blurRadius: 5),
      ],
    ),
    child: TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: label,
        border: InputBorder.none,
      ),
    ),
  );
}
Widget _buildNeumorphicDropdown() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
    margin: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(
      color: AppColors.backgroundColor,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.1), offset: const Offset(3, 3), blurRadius: 5),
        BoxShadow(color: Colors.white.withOpacity(0.8), offset: const Offset(-3, -3), blurRadius: 5),
      ],
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: _selectedMealType,
        isExpanded: true,
        hint: const Text("Выберите"),
        items: ["Завтрак", "Обед", "Полдник"].map((String type) {
          return DropdownMenuItem<String>(
            value: type,
            child: Text(type),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedMealType = value;
          });
        },
      ),
    ),
  );
}
Widget _buildNeumorphicButton({required String text, required VoidCallback onPressed}) {
  return GestureDetector(
    onTap: onPressed,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.defoltColor1,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), offset: const Offset(3, 3), blurRadius: 5),
          BoxShadow(color: Colors.white.withOpacity(0.8), offset: const Offset(-3, -3), blurRadius: 5),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: AppStyle.fontStyle.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    ),
  );
}
Widget _buildNeumorphicImage() {
  return Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: AppColors.backgroundColor,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.1), offset: const Offset(3, 3), blurRadius: 5),
        BoxShadow(color: Colors.white.withOpacity(0.8), offset: const Offset(-3, -3), blurRadius: 5),
      ],
    ),
    child: _selectedImage != null
        ? ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(_selectedImage!, width: 150, height: 150, fit: BoxFit.cover),
          )
        : const Icon(Icons.image, size: 60, color: Colors.grey),
  );
}

}
