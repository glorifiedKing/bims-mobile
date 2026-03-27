import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String formatUgx(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_UG',
      symbol: 'UGX ',
      decimalDigits: 0, // UGX usually has no decimals
    );
    return formatter.format(amount);
  }
}
