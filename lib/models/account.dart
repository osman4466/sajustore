/// Model representing a customer account for confectionery credit management.
class Account {
  final int? id;
  final String name;
  final String? phone;

  const Account({
    this.id,
    required this.name,
    this.phone,
  });

  Account copyWith({
    int? id,
    String? name,
    String? phone,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
    };
  }

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'] as int?,
      name: map['name'] as String,
      phone: map['phone'] as String?,
    );
  }

  @override
  String toString() => 'Account(id: $id, name: $name, phone: $phone)';
}
