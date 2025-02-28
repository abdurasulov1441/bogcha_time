import 'dart:io';
import 'package:bogcha_time/common/my_custom_widgets/my_custom_avatar.dart';
import 'package:bogcha_time/common/my_custom_widgets/my_custom_button.dart';
import 'package:bogcha_time/common/my_custom_widgets/my_custom_radio.dart';
import 'package:bogcha_time/common/my_custom_widgets/my_custom_textfield.dart';
import 'package:bogcha_time/common/style/app_colors.dart';
import 'package:bogcha_time/common/style/app_style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.childData['child_name'] ?? '';
    _surnameController.text = widget.childData['child_surname'] ?? '';
    _birthdateController.text = widget.childData['child_birthdate'] ?? '';
    _selectedGender = widget.childData['child_gender'];
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _newImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateChildData() async {
    setState(() {
    });

    try {
      String? newPhotoUrl = widget.childData['child_photo'];
      if (_newImage != null) {
        final ref = FirebaseStorage.instance.ref().child('children').child('${widget.childId}.jpg');
        await ref.putFile(_newImage!);
        newPhotoUrl = await ref.getDownloadURL();
      }

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

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Данные обновлены!")));
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
        leading: IconButton(onPressed: (){
          context.pop();
        }, icon: Icon(Icons.arrow_back,color: Colors.black45,)),
        centerTitle: true,
        backgroundColor: AppColors.backgroundColor,
        title:  Text("Редактировать ребенка",style: AppStyle.fontStyle.copyWith(fontSize: 20),)),
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
      NeumorphicAvatar(
        imageUrl: _newImage != null ? _newImage!.path : widget.childData['child_photo'],
        isAsset: _newImage == null && widget.childData['child_photo'].isEmpty,
        width: 100,
        height: 100,
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
            child: const Icon(
              Icons.camera_alt,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    ],
  ),
),

              const SizedBox(height: 15),
              NeumorphicTextField(hintText: "Имя ребенка", controller: _nameController),
              const SizedBox(height: 15),
              NeumorphicTextField(hintText: "Фамилия ребенка", controller: _surnameController),
              const SizedBox(height: 15),
              NeumorphicTextField(hintText: "Дата рождения (гггг-мм-дд)", controller: _birthdateController),
              const SizedBox(height: 15),
              const Text("Пол ребенка", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  NeumorphicRadio(
                    isSelected: _selectedGender == "Мальчик",
                    onTap: () => setState(() => _selectedGender = "Мальчик"),
                  ),
                  const SizedBox(width: 10),
                  const Text("Мальчик"),
                  const SizedBox(width: 20),
                  NeumorphicRadio(
                    isSelected: _selectedGender == "Девочка",
                    onTap: () => setState(() => _selectedGender = "Девочка"),
                  ),
                  const SizedBox(width: 10),
                  const Text("Девочка"),
                ],
              ),
              const SizedBox(height: 30),
              NeumorphicButton(
                text: "Сохранить изменения",
                onPressed: _updateChildData,
              ),
            ],
          ),
        ),
      ),
    );
  }
}