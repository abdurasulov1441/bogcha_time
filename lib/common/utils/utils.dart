import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';

abstract final class Utils {

  static bool isPhysicalAuth = false;
  static FilteringTextInputFormatter decimalFormatter() {
    return FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'));
  }

  static final moneyFormat = NumberFormat.currency(
    locale: 'uz_UZ',
    symbol: '',
    decimalDigits: 0,
    name: '',
  );
  static String formatNumber(int number) {
    final formatter = NumberFormat.decimalPattern();
    return formatter.format(number);
  }

 static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(locale: 'en_US', symbol: '\$');
    return formatter.format(amount);
  }
}
