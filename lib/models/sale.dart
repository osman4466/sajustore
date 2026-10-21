/// Model representing a single line item product within a transaction.
class Sale {
  final int? id;
  final int transactionId;
  final String productName;
  final double amount;

  const Sale({
    this.id,
    required this.transactionId,
    required this.productName,
    required this.amount,
  });

  Sale copyWith({
    int? id,
    int? transactionId,
    String? productName,
    double? amount,
  }) {
    return Sale(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      productName: productName ?? this.productName,
      amount: amount ?? this.amount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transactionId': transactionId,
      'productName': productName,
      'amount': amount,
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'] as int?,
      transactionId: map['transactionId'] as int,
      productName: map['productName'] as String,
      amount: (map['amount'] as num).toDouble(),
    );
  }

  @override
  String toString() =>
      'Sale(id: $id, transactionId: $transactionId, productName: $productName, amount: $amount)';
}
