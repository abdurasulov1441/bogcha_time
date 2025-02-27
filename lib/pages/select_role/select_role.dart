import 'package:bogcha_time/app/router.dart';
import 'package:flutter/material.dart';
import 'package:bogcha_time/common/style/app_colors.dart';
import 'package:bogcha_time/common/style/app_style.dart';
import 'package:go_router/go_router.dart';

class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  _RoleSelectionPageState createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  String? selectedRole;

  void selectRole(String role) {
    setState(() {
      selectedRole = role;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text('Rolni tanlang', style: AppStyle.fontStyle.copyWith(fontSize: 20)),
        centerTitle: true,
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Siz kim sifatida tizimga kirasiz?',
              style: AppStyle.fontStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.black45),
            ),
            const SizedBox(height: 30),

            /// **Кнопка "Родитель"**
            _buildRoleButton('parent', 'Ota-ona', Icons.family_restroom),
            const SizedBox(height: 20),

            /// **Кнопка "Сотрудник"**
            _buildRoleButton('staff', 'Bog‘cha hodimi', Icons.work),
            const SizedBox(height: 40),

            /// **Кнопка "Далее"**
            ElevatedButton(
              onPressed: selectedRole != null
                  ? () {
                     if (selectedRole == 'parent') {
                      context.go(Routes.linkChildPage);
                    } else {
                    context.go(Routes.loginPage);
                    }
                      print('Tanlangan rol: $selectedRole');
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedRole != null
                    ? AppColors.defoltColor1
                    : Colors.grey.shade400,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Davom etish',
                style: AppStyle.fontStyle.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// **Метод создания кнопки выбора роли**
  Widget _buildRoleButton(String role, String text, IconData icon) {
    final bool isSelected = selectedRole == role;
    return GestureDetector(
      onTap: () => selectRole(role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.defoltColor1.withOpacity(0.6),
                    offset: const Offset(3, 3),
                    blurRadius: 8,
                  ),
                  const BoxShadow(
                    color: Colors.white,
                    offset: Offset(-3, -3),
                    blurRadius: 8,
                  ),
                ]
              : [
                  const BoxShadow(
                    color: Colors.white,
                    offset: Offset(-3, -3),
                    blurRadius: 5,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: const Offset(3, 3),
                    blurRadius: 5,
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(icon, size: 30, color: isSelected ? AppColors.defoltColor1 : Colors.black45),
            const SizedBox(width: 15),
            Text(
              text,
              style: AppStyle.fontStyle.copyWith(fontSize: 18,color: isSelected ? AppColors.defoltColor1 : Colors.black45),
            ),
          ],
        ),
      ),
    );
  }
}