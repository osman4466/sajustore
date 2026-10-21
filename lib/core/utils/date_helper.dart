import 'package:intl/intl.dart';
import 'package:hijri/hijri_calendar.dart';

/// Utility class for multi-calendar date conversions and currency formatting.
class DateHelper {
  DateHelper._();

  static const List<String> banglaMonths = [
    'বৈশাখ',
    'জ্যৈষ্ঠ',
    'আষাঢ়',
    'শ্রাবণ',
    'ভাদ্র',
    'আশ্বিন',
    'কার্তিক',
    'অগ্রহায়ণ',
    'পৌষ',
    'মাঘ',
    'ফাল্গুন',
    'চৈত্র',
  ];

  static const List<String> hijriMonthsBangla = [
    'মুহররম',
    'সফর',
    'রবিউল আউয়াল',
    'রবিউস সানি',
    'জমাদিউল আউয়াল',
    'জমাদিউস সানি',
    'রজব',
    'শাবান',
    'রমজান',
    'শাওয়াল',
    'জিলক্বদ',
    'জিলহজ',
  ];

  /// Converts English numbers (e.g. 123) to Bangla numbers ('১২৩').
  static String toBanglaDigits(dynamic number) {
    const enDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const bnDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    String result = number.toString();
    for (int i = 0; i < enDigits.length; i++) {
      result = result.replaceAll(enDigits[i], bnDigits[i]);
    }
    return result;
  }

  static String _dayOrdinalSuffix(int day) {
    if (day == 1) return 'লা';
    if (day == 2 || day == 3) return 'রা';
    if (day == 4) return 'ঠা';
    if (day >= 5 && day <= 18) return 'ই';
    return 'শে';
  }

  static bool _isGregorianLeap(int year) {
    return (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;
  }

  /// Returns Bangla calendar date string (e.g. '১৬ই শ্রাবণ ১৪৩৩').
  static String getBanglaDate(DateTime date) {
    final int gYear = date.year;
    late DateTime newYearStart;
    late int bengaliYear;

    final thisYearNewYear = DateTime(gYear, 4, 14);
    if (!date.isBefore(thisYearNewYear)) {
      newYearStart = thisYearNewYear;
      bengaliYear = gYear - 593;
    } else {
      newYearStart = DateTime(gYear - 1, 4, 14);
      bengaliYear = gYear - 594;
    }

    int dayOfBengaliYear = date.difference(newYearStart).inDays + 1;

    final bool leapFalgun = _isGregorianLeap(newYearStart.year + 1);
    final List<int> monthLengths = [
      31,
      31,
      31,
      31,
      31,
      30,
      30,
      30,
      30,
      30,
      leapFalgun ? 31 : 30,
      30,
    ];

    int monthIndex = 0;
    int remaining = dayOfBengaliYear;
    for (int i = 0; i < monthLengths.length; i++) {
      if (remaining <= monthLengths[i]) {
        monthIndex = i;
        break;
      }
      remaining -= monthLengths[i];
    }

    final dayStr = toBanglaDigits(remaining) + _dayOrdinalSuffix(remaining);
    final monthStr = banglaMonths[monthIndex];
    final yearStr = toBanglaDigits(bengaliYear);

    return '$dayStr $monthStr $yearStr';
  }

  /// Returns English Gregorian date (e.g. '21 October 2026').
  static String getEnglishDate(DateTime date) {
    return DateFormat('d MMMM yyyy').format(date);
  }

  /// Returns Islamic Hijri date in Bengali (e.g. '৯ রবিউস সানি ১৪৪৮').
  static String getHijriBanglaDate(DateTime date) {
    final hijri = HijriCalendar.fromDate(date);
    final day = toBanglaDigits(hijri.hDay);
    final month = (hijri.hMonth >= 1 && hijri.hMonth <= 12)
        ? hijriMonthsBangla[hijri.hMonth - 1]
        : '';
    final year = toBanglaDigits(hijri.hYear);
    return '$day $month $year';
  }

  /// Standard display date-time string for transactions (e.g. '21-10-2026, 01:15 PM').
  static String formatDisplayDateTime(DateTime dateTime) {
    return DateFormat('dd-MM-yyyy, hh:mm a').format(dateTime);
  }

  /// Sortable date string used for SQLite index and queries (e.g. '2026-10-21').
  static String formatSortableDate(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  /// Formats currency with Taka symbol cleanly (e.g. '৳ 1,250' or '৳ 50.50').
  static String formatCurrency(double amount) {
    if (amount % 1 == 0) {
      return '৳ ${amount.toStringAsFixed(0)}';
    }
    return '৳ ${amount.toStringAsFixed(2)}';
  }
}
