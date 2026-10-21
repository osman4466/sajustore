class Account {
  final int? id;
  final String name;
  final String? phone;

  Account({this.id, required this.name, this.phone});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'phone': phone};
  }

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(id: map['id'], name: map['name'], phone: map['phone']);
  }
}
