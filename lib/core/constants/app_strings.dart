/// Centralized Bengali and English strings for Confectionary Sales application.
class AppStrings {
  AppStrings._();

  // App & Branding
  static const String appName = 'Saju Confectionery';
  static const String appSubtitle = 'কনফেকশনারি বিক্রয় ও হিসাব';

  // Navigation & Screens
  static const String homeTitle = 'Saju Confectionery';
  static const String cashSalesTitle = 'ক্যাশ সেল';
  static const String accountSalesTitle = 'একাউন্ট সেল (বাকি)';
  static const String accountsTitle = 'গ্রাহক একাউন্ট তালিকা';
  static const String addCashSaleTitle = 'ক্যাশ সেল যোগ করুন';
  static const String editCashSaleTitle = 'ক্যাশ সেল এডিট করুন';
  static const String addAccountSaleTitle = 'বাকি বিক্রয় যোগ করুন';
  static const String editAccountSaleTitle = 'বাকি বিক্রয় এডিট করুন';

  // Dashboard & Summaries
  static const String todaySummary = 'আজকের হিসাব';
  static const String monthlySummary = 'মাসের হিসাব';
  static const String totalSales = 'মোট বিক্রয়';
  static const String cashReceived = 'ক্যাশ বিক্রয়';
  static const String creditSales = 'বাকির বিক্রয়';
  static const String totalDue = 'সর্বমোট বাকি';
  static const String customerTotalDue = 'মোট বাকি';
  static const String currencySymbol = '৳';

  // Forms & Actions
  static const String addProduct = 'আরেকটি পণ্য যোগ করুন';
  static const String saveAll = 'সব সেভ করুন';
  static const String update = 'আপডেট করুন';
  static const String cancel = 'বাতিল';
  static const String close = 'বন্ধ করুন';
  static const String edit = 'এডিট করুন';
  static const String delete = 'মুছে ফেলুন';
  static const String searchCustomer = 'গ্রাহকের নাম বা ফোন দিয়ে খুঁজুন...';
  static const String newAccount = 'নতুন একাউন্ট';
  static const String customerName = 'গ্রাহকের নাম';
  static const String customerPhone = 'মোবাইল নম্বর (ঐচ্ছিক)';
  static const String paymentDeposit = 'টাকা জমা';
  static const String paymentAmount = 'কত টাকা জমা দিলেন';
  static const String newEntry = 'নতুন এন্ট্রি';
  static const String productNameHint = 'পণ্যের নাম (যেমন: মিষ্টি, কেক, বিস্কুট)';
  static const String productAmountHint = 'দাম';

  // Messages & Warnings
  static const String noCashSales = 'কোনো ক্যাশ সেল নেই';
  static const String noAccounts = 'কোনো একাউন্ট পাওয়া যায়নি';
  static const String noEntries = 'কোনো এন্ট্রি নেই';
  static const String validationAtLeastOne = 'অন্তত একটি পণ্যের নাম ও দাম লিখুন';
  static const String confirmDeleteTitle = 'নিশ্চিতকরণ';
  static const String confirmDeleteTransaction = 'আপনি কি এই লেনদেনটি মুছে ফেলতে চান? এটি স্থায়ীভাবে মুছে যাবে।';
  static const String confirmDeleteAccount = 'আপনি কি এই গ্রাহক একাউন্টটি মুছে ফেলতে চান? এর সাথে যুক্ত সকল লেনদেন মুছে যাবে।';
}
