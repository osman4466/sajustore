class Sale {
  final int? id;
  final int transactionId; // links to a SaleTransaction
  final String productName;
  final double amount;

  Sale({
    this.id,
    required this.transactionId,
    required this.productName,
    required this.amount,
  });

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
      id: map['id'],
      transactionId: map['transactionId'],
      productName: map['productName'],
      amount: map['amount'],
    );
  }
}
