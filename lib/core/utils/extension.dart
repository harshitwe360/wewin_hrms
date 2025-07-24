extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime? other) {
    if(other==null) return false;
    return year == other.year && month == other.month
        && day == other.day;
  }
}