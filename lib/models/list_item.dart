class ListItem {
  ListItem(
      {required this.id,
      required this.itemName,
      this.amount,
      required this.userId,
      this.category = 'Uncategorized',
      this.acquired = false});

  final String id;
  String itemName;
  String? amount;
  bool acquired;
  final String userId;
  String category;

  ListItem copyWith(
      {String? id,
      String? name,
      String? amount,
      String? userId,
      bool? acquired,
      String? category}) {
    return ListItem(
      id: id ?? this.id,
      itemName: name ?? this.itemName,
      amount: amount ?? this.amount,
      userId: userId ?? this.userId,
      acquired: acquired ?? this.acquired,
      category: category ?? this.category,
    );
  }

  factory ListItem.fromFireStore(String id, Map<String, dynamic> data) {
    return ListItem(
      id: id,
      itemName: data['itemName']!,
      amount: data['amount'].toString(),
      acquired: data['acquired'] ?? false,
      userId: data['userId'],
      category: data['category'] ?? 'Uncategorized',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'itemName': itemName,
      'amount': amount,
      'acquired': acquired,
      'userId': userId,
      'category': category,
    };
  }

  bool toggleAcquired() {
    if (acquired) {
      acquired = false;
    } else {
      acquired = true;
    }
    return acquired;
  }
}
