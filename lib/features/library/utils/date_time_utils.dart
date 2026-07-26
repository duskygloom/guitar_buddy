class DateTimeUtils {
  static String format(DateTime dt) {
    return "${dt.year}"
        "${dt.month.toString().padLeft(2, "0")}"
        "${dt.day.toString().padLeft(2, "0")}"
        "${dt.hour.toString().padLeft(2, "0")}"
        "${dt.minute.toString().padLeft(2, "0")}"
        "${dt.second.toString().padLeft(2, "0")}";
  }

  static DateTime parse(String s) {
    return DateTime(
      int.parse(s.substring(0, 4)),
      int.parse(s.substring(4, 6)),
      int.parse(s.substring(6, 8)),
      int.parse(s.substring(8, 10)),
      int.parse(s.substring(10, 12)),
      int.parse(s.substring(12, 14)),
    );
  }
}
