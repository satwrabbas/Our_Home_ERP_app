class NumberFormatters {
  static String formatWithCommas(num number) {
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return number.toInt().toString().replaceAllMapped(reg, (Match match) => '${match[1]},');
  }
}