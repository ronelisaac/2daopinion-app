class BirthDate {
  const BirthDate(this.year, this.month, this.day);
  final int year;
  final int month;
  final int day;

  bool validAt(DateTime now) {
    final date = DateTime.utc(year, month, day);
    return year >= 1900 &&
        date.year == year &&
        date.month == month &&
        date.day == day &&
        !date.isAfter(DateTime.utc(now.year, now.month, now.day));
  }
}
