import 'package:intl/intl.dart';
import 'package:hijri/hijri_calendar.dart';

class DateHelper {
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

  static String toBanglaDigits(int number) {
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

  // বাংলা তারিখ বের করে (যেমন: ১৬ই শ্রাবণ ১৪৩৩)
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

  // ইংরেজি তারিখ
  static String getEnglishDate(DateTime date) {
    return DateFormat('d MMMM yyyy').format(date);
  }

  // আরবি (হিজরি) তারিখ বাংলায়
  static String getHijriBanglaDate(DateTime date) {
    final hijri = HijriCalendar.fromDate(date);
    final day = toBanglaDigits(hijri.hDay);
    final month = hijriMonthsBangla[hijri.hMonth - 1];
    final year = toBanglaDigits(hijri.hYear);
    return '$day $month $year';
  }
}
