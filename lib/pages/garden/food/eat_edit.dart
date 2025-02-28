import 'dart:io';
import 'package:bogcha_time/common/my_custom_widgets/my_custom_button.dart';
import 'package:bogcha_time/common/my_custom_widgets/my_custom_textfield.dart';
import 'package:bogcha_time/common/my_custom_widgets/my_custom_container.dart';
import 'package:bogcha_time/common/style/app_colors.dart';
import 'package:bogcha_time/common/style/app_style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';

class EditMealScreen extends StatefulWidget {
  final String mealId;
  final String mealName;
  final String mealTime;
  final String mealType;
  final String mealImage;

  const EditMealScreen({
    super.key,
    required this.mealId,
    required this.mealName,
    required this.mealTime,
    required this.mealType,
    required this.mealImage,
  });

  @override
  _EditMealScreenState createState() => _EditMealScreenState();
}

class _EditMealScreenState extends State<EditMealScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  String? _selectedMealType;
  File? _newImage;

  final List<String> mealTypes = ["Завтрак", "Обед", "Ужин"];

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.mealName;
    _timeController.text = widget.mealTime;
    _selectedMealType = widget.mealType;
  }

  
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _newImage = File(pickedFile.path);
      });
    }
  }

  
  Future<void> _updateMeal() async {
    setState(() {
    });

    try {
      final String? gardenId = FirebaseAuth.instance.currentUser?.uid;
      if (gardenId == null) throw "Ошибка: пользователь не найден";

      String? imageUrl = widget.mealImage;

      // Если выбрано новое изображение, загружаем в Firebase Storage
      if (_newImage != null) {
        final ref = FirebaseStorage.instance.ref().child('meals/${widget.mealId}.jpg');
        await ref.putFile(_newImage!);
        imageUrl = await ref.getDownloadURL();
      }

      // Обновление данных в Firestore
      await FirebaseFirestore.instance
          .collection('garden')
          .doc(gardenId)
          .collection('meals')
          .doc(DateTime.now().toString().split(' ')[0])
          .collection('items')
          .doc(widget.mealId)
          .update({
        'name': _nameController.text.trim(),
        'time': _timeController.text.trim(),
        'type': _selectedMealType,
        'image': imageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Блюдо успешно обновлено!")),
      );

      context.pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Ошибка: $e")));
    } finally {
      setState(() {
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.black45),
        ),
        centerTitle: true,
        title: Text(
          "Редактировать блюдо",
          style: AppStyle.fontStyle.copyWith(fontSize: 20),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
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
                        image: DecorationImage(
                          image: _newImage != null
                              ? FileImage(_newImage!)
                              : (widget.mealImage.isNotEmpty
                                  ? NetworkImage(widget.mealImage)
                                  : const AssetImage('assets/placeholder.png')) as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 5,
                      right: 5,
                      child: GestureDetector(
                        onTap: () => _pickImage(ImageSource.gallery),
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
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              NeumorphicTextField(hintText: "Название блюда", controller: _nameController),
              const SizedBox(height: 15),
              NeumorphicTextField(hintText: "Время приема пищи", controller: _timeController),
              const SizedBox(height: 15),

         
              const Text("Тип приема пищи", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              NeumorphicContainer(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedMealType,
                    isExpanded: true,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedMealType = newValue;
                      });
                    },
                    items: mealTypes.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type, style: AppStyle.fontStyle),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 30),

        
              NeumorphicButton(
                text: "Сохранить изменения",
                onPressed: _updateMeal,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
