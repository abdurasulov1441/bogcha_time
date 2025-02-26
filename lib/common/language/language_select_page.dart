import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

Future<void> showLanguageBottomSheet(BuildContext context) async {
  final List<Map<String, dynamic>> languages = [
    {'locale': const Locale('uz'), 'name': 'O‘zbekcha', 'flag': '🇺🇿'},
    {'locale': const Locale('ru'), 'name': 'Русский', 'flag': '🇷🇺'},
    {'locale': const Locale('en'), 'name': 'English', 'flag': '🇬🇧'},
  ];

  Locale? selectedLocale = context.locale;

  await showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Tilni tanlang',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ).tr(),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              itemCount: languages.length,
              itemBuilder: (context, index) {
                final lang = languages[index];
                return GestureDetector(
                  onTap: () {
                    selectedLocale = lang['locale'];
                    context.setLocale(selectedLocale!);
                    Navigator.pop(context); // Закрытие боттом-шита
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: selectedLocale == lang['locale']
                          ? Colors.blue.shade100
                          : Colors.white,
                      border: Border.all(
                        color: selectedLocale == lang['locale']
                            ? Colors.blue
                            : Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      children: [
                        ClipOval(
                          child: Container(
                            color: Colors.grey.shade200,
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              lang['flag'],
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          lang['name'],
                          style: TextStyle(
                            color: selectedLocale == lang['locale']
                                ? Colors.blue
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
    },
  );
}

class LanguageSelectionButton extends StatefulWidget {
  const LanguageSelectionButton({Key? key}) : super(key: key);

  @override
  State<LanguageSelectionButton> createState() =>
      _LanguageSelectionButtonState();
}

class _LanguageSelectionButtonState extends State<LanguageSelectionButton> {
  @override
  Widget build(BuildContext context) {
    // Определяем текущий флаг на основе локали
    final String currentFlag = context.locale == const Locale('uz')
        ? '🇺🇿'
        : context.locale == const Locale('ru')
            ? '🇷🇺'
            : '🇺🇿';

    return GestureDetector(
      onTap: () => showLanguageBottomSheet(context), // Вызов боттом-шита
      child: CircleAvatar(
        backgroundColor: Colors.grey.shade200, // Цвет фона аватара
        radius: 25, // Радиус круга
        child: Text(
          currentFlag, // Отображение флага
          style: const TextStyle(fontSize: 24), // Размер текста
        ),
      ),
    );
  }
}
