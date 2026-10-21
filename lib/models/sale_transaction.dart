class SaleTransaction {
  final int? id;
  final String type; // "cash" or "account"
  final int? accountId; // only for account sales
  final double totalAmount;
  final String date;
  final String sortableDate;

  SaleTransaction({
    this.id,
    required this.type,
    this.accountId,
    required this.totalAmount,
    required this.date,
    required this.sortableDate,
  });

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
      id: map['id'],
      type: map['type'],
      accountId: map['accountId'],
      totalAmount: map['totalAmount'],
      date: map['date'],
      sortableDate: map['sortableDate'],
    );
  }
}
