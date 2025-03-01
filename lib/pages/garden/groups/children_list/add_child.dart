import 'dart:io';
import 'package:bogcha_time/common/my_custom_widgets/my_custom_button.dart';
import 'package:bogcha_time/common/my_custom_widgets/my_custom_textfield.dart';
import 'package:bogcha_time/common/style/app_colors.dart';
import 'package:bogcha_time/common/style/app_style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class AddChildScreen extends StatefulWidget {
  final String groupId;

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
  File? _selectedImage;

  final _formKey = GlobalKey<FormState>();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(
      source: source,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadPhoto(String childUuid) async {
    if (_selectedImage == null) return null;

    try {
      final storageRef = FirebaseStorage.instance.ref().child(
        'children/$childUuid.jpg',
      );
      await storageRef.putFile(_selectedImage!);
      return await storageRef.getDownloadURL();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Ошибка загрузки: $e")));
      return null;
    }
  }

  Future<void> _addChild() async {
    if (!_formKey.currentState!.validate() || _selectedGender == null) return;

    setState(() {
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) throw "Не удалось определить текущего пользователя";

      String gardenId = user.uid;
      String uniqueCode = const Uuid().v4().substring(0, 8);

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
            'child_photo': photoUrl ?? '',
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    } finally {
      setState(() {
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
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: Icon(Icons.arrow_back, color: Colors.black45),
        ),
        centerTitle: true,
        backgroundColor: AppColors.backgroundColor,
        title: Text(
          'Добавить ребенка',
          style: AppStyle.fontStyle.copyWith(fontSize: 20),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NeumorphicTextField(
                    isEmailvalidator: false,
                    hintText: 'Имя ребенка',
                    controller: _nameController,
                  ),
                  SizedBox(height: 20),
                  NeumorphicTextField(
                    isEmailvalidator: false,
                    hintText: 'Фамилия ребенка',
                    controller: _surnameController,
                  ),
                  SizedBox(height: 20),
                  NeumorphicTextField(
                    isEmailvalidator: false,
                    hintText: 'Отчество ребенка',
                    controller: _lastNameController,
                  ),
                  SizedBox(height: 20),
                  NeumorphicTextField(
                    hintText: 'Дата рождения (гггг-мм-дд)',
                    controller: _birthdateController,
                  ),
                  const SizedBox(height: 10),

                  Text(
                    "Пол ребенка",
                    style: AppStyle.fontStyle.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          fillColor: WidgetStateProperty.all(
                            AppColors.defoltColor1,
                          ),
                          title: Text("Мальчик", style: AppStyle.fontStyle),
                          value: "1",
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
                          fillColor: WidgetStateProperty.all(
                            AppColors.defoltColor1,
                          ),
                          title: Text("Девочка", style: AppStyle.fontStyle),
                          value: "2",
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

                  Center(
                    child: Column(
                      children: [
                        if (_selectedImage != null)
                          Image.file(
                            _selectedImage!,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.backgroundColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                side: BorderSide(
                                  color: AppColors.backgroundColor,
                                  width: 0.1,
                                ),
                              ),
                              onPressed: () => _pickImage(ImageSource.camera),
                              icon: const Icon(Icons.camera_alt,color: AppColors.defoltColor1,),
                              label:  Text("Сделать фото",style: AppStyle.fontStyle.copyWith(),),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.backgroundColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                side: BorderSide(
                                  color: AppColors.backgroundColor,
                                  width: 0.1,
                                ),
                              ),
                              onPressed: () => _pickImage(ImageSource.gallery),
                              icon: const Icon(Icons.image,color: AppColors.defoltColor1,),
                              label:  Text("Выбрать фото",style: AppStyle.fontStyle.copyWith(),),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: NeumorphicButton(
                      onPressed:  _addChild,
                      text: 'Добавить ребенка',
                      
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
