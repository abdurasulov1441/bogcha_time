import 'package:flutter/material.dart';

abstract final class MyColors {
  static const primary = Color(0xff7F2828);
  static const green = Color(0xff00D100);

  static const backgroundLight = Color(0xfff3f3f3);
  static const cardLight = Color(0xffffffff);
  static const textLight = Color(0xff090909);
  static const hintLight = Color(0xff797979);
  static const iconLight = Color(0xffababab);
  static const dividerLight = Color(0xffe7e7e7);
  static const containerLight = Color(0xffffffff);

  static const backgroundDark = Color(0xff212121);
  static const cardDark = Color(0xff303030);
  static const textDark = Color(0xffffffff);
  static const hintDark = Color(0xffc0c0c0);
  static const iconDark = Color(0xfff0f0f0);
  static const dividerDark = Color(0xff505050);
  static const containerDark = Color(0xff000000);
}

final lightTheme = ThemeData(
  secondaryHeaderColor: Color(0XFFFFF5F5),
  scaffoldBackgroundColor: MyColors.backgroundLight,
  cardColor: MyColors.cardLight,
  hintColor: MyColors.hintLight,
  primaryColor: MyColors.primary,
  iconTheme: const IconThemeData(color: MyColors.iconLight),
  dividerColor: MyColors.dividerLight,
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: MyColors.textLight),
  ),
  colorScheme: ColorScheme.light(
    primary: MyColors.primary,
    background: MyColors.backgroundLight,
    surface: MyColors.cardLight,
    onPrimary: Colors.white,
    onBackground: MyColors.textLight,
    onSurface: MyColors.textLight,
  ),
  checkboxTheme: CheckboxThemeData(
    visualDensity: VisualDensity.compact,
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
    side: BorderSide(
      width: 1.3,
      color: WidgetStateColor.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? MyColors.primary
            : MyColors.iconLight,
      ),
    ),
  ),
);

final darkTheme = ThemeData(
  secondaryHeaderColor: MyColors.dividerDark,
  scaffoldBackgroundColor: MyColors.backgroundDark,
  cardColor: MyColors.cardDark,
  hintColor: MyColors.hintDark,
  primaryColor: MyColors.green,
  iconTheme: const IconThemeData(color: MyColors.iconDark),
  dividerColor: MyColors.dividerDark,
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: MyColors.textDark),
  ),
  colorScheme: ColorScheme.dark(
    primary: MyColors.primary,
    background: MyColors.backgroundDark,
    surface: MyColors.cardDark,
    onPrimary: Colors.white,
    onBackground: MyColors.textDark,
    onSurface: MyColors.textDark,
  ),
  checkboxTheme: CheckboxThemeData(
    visualDensity: VisualDensity.compact,
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
    side: BorderSide(
      width: 1.3,
      color: WidgetStateColor.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? MyColors.primary
            : MyColors.iconDark,
      ),
    ),
  ),
);
