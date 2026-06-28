import 'package:intl/intl.dart';

class AppFormatters {
  const AppFormatters._();

  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  static final DateFormat _displayDateFormatter = DateFormat(
    'dd MMM yyyy',
    'id_ID',
  );
  static final DateFormat _apiDateFormatter = DateFormat('yyyy-MM-dd');

  static String currency(num value) => _currencyFormatter.format(value);
  static String compactCurrency(num value) =>
      '${value < 0 ? '-' : ''}${_currencyFormatter.format(value.abs())}';
  static String displayDate(DateTime value) =>
      _displayDateFormatter.format(value);
  static String apiDate(DateTime value) => _apiDateFormatter.format(value);
}
