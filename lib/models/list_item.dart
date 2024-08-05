class ListItem {
  ListItem(
      {required this.id,
      required this.itemName,
      required this.amount,
      this.acquired = false});

  final String id;
  final String itemName;
  final int amount;
  bool acquired;

  factory ListItem.fromFireStore(String id, Map<String, dynamic> data) {
    return ListItem(
        id: id,
        itemName: data['itemName']!,
        amount: data['amount']!,
        acquired: data['acquired'] ?? false);
  }

  Map<String, dynamic> toFirestore() {
    return {
      'itemName': itemName,
      'amount': amount,
      'acquired': acquired,
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
