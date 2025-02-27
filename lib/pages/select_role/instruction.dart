import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bogcha_time/common/style/app_style.dart';
import 'package:bogcha_time/common/style/app_colors.dart';

class ChildCodeInstructions extends StatelessWidget {
  const ChildCodeInstructions({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: Icon(Icons.arrow_back, color: AppColors.defoltColor1),
        ),
        title: Text(
          "📌 Инструкция",
          style: AppStyle.fontStyle.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.defoltColor1,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection(
                  "📌 Как получить и привязать код ребенка?",
                  "Следуйте инструкции, чтобы успешно добавить ребенка в систему.",
                  isTitle: true,
                ),
                _buildSection(
                  "1️⃣ Что такое код ребенка?",
                  "Код ребенка – это уникальный идентификатор, который позволяет вам получить доступ к информации о ребенке в системе детского сада.",
                ),
                _buildSection(
                  "2️⃣ Где получить код?",
                  "Код можно получить у сотрудников детского сада – воспитателя, няни или администратора. Обратитесь к ним, если у вас еще нет кода.",
                ),
                _buildSection(
                  "3️⃣ Как привязать ребенка к своему аккаунту?",
                  "✅ Шаг 1: Откройте приложение и перейдите в раздел «Добавить ребенка».\n"
                  "✅ Шаг 2: Введите полученный код или отсканируйте QR-код.\n"
                  "✅ Шаг 3: Нажмите «Привязать» и дождитесь подтверждения.\n"
                  "✅ Шаг 4: После успешной привязки вам откроется доступ к данным ребенка.",
                ),
                _buildSection(
                  "4️⃣ Что делать, если код не работает?",
                  "🔸 Проверьте, правильно ли введен код (учитывайте регистр).\n"
                  "🔸 Убедитесь, что код еще активен и не истек его срок действия.\n"
                  "🔸 Если код уже использован, обратитесь к администрации детского сада.",
                ),
                _buildSection(
                  "5️⃣ Можно ли привязать нескольких детей?",
                  "Да! Для каждого ребенка вам нужно получить отдельный код и повторить шаги привязки.",
                ),
                _buildSection(
                  "6️⃣ Безопасность данных",
                  "🔐 Ваш код – уникальный. Не передавайте его посторонним, так как только родители или законные представители могут его использовать.",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🔹 Функция для красивого отображения секций
  Widget _buildSection(String title, String content, {bool isTitle = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15,left: 10,right: 10,top: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          const BoxShadow(
            color: Colors.white,
            offset: Offset(-3, -3),
            blurRadius: 5,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            offset: const Offset(3, 3),
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppStyle.fontStyle.copyWith(
              fontSize: isTitle ? 18 : 16,
              fontWeight: isTitle ? FontWeight.bold : FontWeight.w600,
              color: isTitle ? AppColors.defoltColor1 : AppColors.defoltColor1,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            content,
            style: AppStyle.fontStyle.copyWith(
              fontSize: 14,
              height: 1.5,
              color: Colors.black45,
            ),
          ),
        ],
      ),
    );
  }
}
