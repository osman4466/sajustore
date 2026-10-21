/// Model representing a single transaction receipt:
/// can be cash sale ('cash'), account/credit sale ('account'), or credit repayment ('payment').
class SaleTransaction {
  final int? id;
  final String type; // 'cash' | 'account' | 'payment'
  final int? accountId;
  final double totalAmount;
  final String date;
  final String sortableDate;

  const SaleTransaction({
    this.id,
    required this.type,
    this.accountId,
    required this.totalAmount,
    required this.date,
    required this.sortableDate,
  });

  bool get isCash => type == 'cash';
  bool get isAccount => type == 'account';
  bool get isPayment => type == 'payment';

  SaleTransaction copyWith({
    int? id,
    String? type,
    int? accountId,
    double? totalAmount,
    String? date,
    String? sortableDate,
  }) {
    return SaleTransaction(
      id: id ?? this.id,
      type: type ?? this.type,
      accountId: accountId ?? this.accountId,
      totalAmount: totalAmount ?? this.totalAmount,
      date: date ?? this.date,
      sortableDate: sortableDate ?? this.sortableDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'accountId': accountId,
      'totalAmount': totalAmount,
      'date': date,
      'sortableDate': sortableDate,
    };
  }

  factory SaleTransaction.fromMap(Map<String, dynamic> map) {
    return SaleTransaction(
      id: map['id'] as int?,
      type: map['type'] as String,
      accountId: map['accountId'] as int?,
      totalAmount: (map['totalAmount'] as num).toDouble(),
      date: map['date'] as String,
      sortableDate: (map['sortableDate'] as String?) ?? '',
    );
  }

  @override
  String toString() =>
      'SaleTransaction(id: $id, type: $type, accountId: $accountId, totalAmount: $totalAmount, date: $date)';
}
