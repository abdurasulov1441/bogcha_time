import 'package:bogcha_time/common/my_custom_widgets/my_custom_button.dart';
import 'package:bogcha_time/common/my_custom_widgets/my_custom_textfield.dart';
import 'package:bogcha_time/common/style/app_colors.dart';
import 'package:bogcha_time/common/style/app_style.dart';
import 'package:bogcha_time/app/router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LinkChildPage extends StatefulWidget {
  const LinkChildPage({super.key});

  @override
  _LinkChildPageState createState() => _LinkChildPageState();
}

class _LinkChildPageState extends State<LinkChildPage> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  /// 🔹 Функция для привязки ребенка по коду
  Future<void> _linkChild(String code) async {
    if (code.isEmpty) {
      setState(() {
        _errorMessage = 'Введите код!';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      var childSnapshot = await FirebaseFirestore.instance
          .collection('children')
          .where('unique_code', isEqualTo: code)
          .limit(1)
          .get();

      if (childSnapshot.docs.isNotEmpty) {
        var childDoc = childSnapshot.docs.first;

        if (childDoc['parent_id'] != null) {
          setState(() {
            _errorMessage = 'Этот ребенок уже привязан к другому родителю!';
          });
          return;
        }

        String parentId = "parent_123"; // 🔹 Здесь берем текущий ID родителя (замени на auth)
        await childDoc.reference.update({'parent_id': parentId});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ребенок успешно привязан!')),
        );
        Navigator.pop(context);
      } else {
        setState(() {
          _errorMessage = 'Код не найден, попробуйте еще раз!';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка: $e';
      });
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
        centerTitle: true,
        backgroundColor: AppColors.backgroundColor,
        title: Text('Привязка ребенка', style: AppStyle.fontStyle.copyWith(fontSize: 20)),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),

           
            Center(
              child: Text(
                'Введите код или отсканируйте QR-код',
                style: AppStyle.fontStyle.copyWith(fontSize: 18,),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 30),

            /// 🔹 Неоморфное поле ввода кода
            NeumorphicTextField(
              controller: _codeController,
              hintText: 'Введите код',
              isEmailvalidator: false,
            ),

            const SizedBox(height: 20),

            /// 🔹 Кнопка "Привязать ребенка"
            NeumorphicButton(
              text: "Привязать ребенка",
              isDisabled: _isLoading,
              onPressed: () => _linkChild(_codeController.text.trim()),
            ),

            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 10),
              Center(
                child: Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
            ],

            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 10),

           
            NeumorphicButton(
              text: "📷 Сканировать QR-код",
              onPressed: () => context.push(Routes.qrCodePage),
            ),

            const SizedBox(height: 10),
            Spacer(),
            NeumorphicButton(
              
              text: 'Подробраня инструкция', onPressed: () {
              context.push(Routes.qrInstruction);
            }),
          ],
        ),
      ),
    );
  }
}
