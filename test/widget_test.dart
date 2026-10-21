import 'package:flutter_test/flutter_test.dart';
import 'package:confectionary_sales/core/utils/date_helper.dart';
import 'package:confectionary_sales/models/account.dart';
import 'package:confectionary_sales/models/sale.dart';
import 'package:confectionary_sales/models/sale_transaction.dart';

void main() {
  group('DateHelper Tests', () {
    test('Converts English digits to Bangla digits correctly', () {
      expect(DateHelper.toBanglaDigits(12345), '১২৩৪৫');
      expect(DateHelper.toBanglaDigits(0), '০');
      expect(DateHelper.toBanglaDigits(9876), '৯৮৭৬');
    });

    test('Formats currency properly with Taka symbol', () {
      expect(DateHelper.formatCurrency(500.0), '৳ 500');
      expect(DateHelper.formatCurrency(120.50), '৳ 120.50');
    });
  });

  group('Model Serialization Tests', () {
    test('Account toMap and fromMap works correctly', () {
      final account = Account(id: 1, name: 'রহিম মিষ্টি ঘর', phone: '01700000000');
      final map = account.toMap();
      final parsed = Account.fromMap(map);

      expect(parsed.id, 1);
      expect(parsed.name, 'রহিম মিষ্টি ঘর');
      expect(parsed.phone, '01700000000');
    });

    test('Sale toMap and fromMap works correctly', () {
      final sale = Sale(id: 10, transactionId: 5, productName: 'রসগোল্লা', amount: 350.0);
      final map = sale.toMap();
      final parsed = Sale.fromMap(map);

      expect(parsed.id, 10);
      expect(parsed.transactionId, 5);
      expect(parsed.productName, 'রসগোল্লা');
      expect(parsed.amount, 350.0);
    });

    test('SaleTransaction toMap and fromMap works correctly', () {
      final transaction = SaleTransaction(
        id: 7,
        type: 'cash',
        totalAmount: 1250.0,
        date: '21-10-2026, 12:30 PM',
        sortableDate: '2026-10-21',
      );
      final map = transaction.toMap();
      final parsed = SaleTransaction.fromMap(map);

      expect(parsed.id, 7);
      expect(parsed.type, 'cash');
      expect(parsed.totalAmount, 1250.0);
      expect(parsed.isCash, isTrue);
      expect(parsed.isAccount, isFalse);
    });
  });
}
