import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class AddChildScreen extends StatefulWidget {
  final String groupId; // 📌 Получаем ID группы, куда добавлять ребенка

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

  final _formKey = GlobalKey<FormState>();

  Future<void> _addChild() async {
    if (!_formKey.currentState!.validate() || _selectedGender == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw "Не удалось определить текущего пользователя";
      }

      String gardenId = user.uid; // 📌 UID детского сада
      String uniqueCode = const Uuid().v4().substring(0, 8); // 📌 Генерируем уникальный код

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
        'child_photo': '',
        'metrika_photo': '',
        'parent_id': null, // 📌 Привяжется после сканирования родителем
        'group_id': widget.groupId, // 📌 Привязываем к выбранной группе
        'created_at': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ребенок успешно добавлен! Код: $uniqueCode')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
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
