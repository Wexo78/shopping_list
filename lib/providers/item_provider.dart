import 'package:shopping_list/models/list_item.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<ListItem>> fetchItems() async {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  List<ListItem> itemList = [];
  final docRef = await db.collection('listItems').get();
  docRef.docs.forEach(
      (doc) => itemList.add(ListItem.fromFireStore(doc.id, doc.data())));

  return itemList;
}

Future<void> deleteItem(String id) async {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  await db.collection('listItems').doc(id).delete();
}

Future<void> addItem(String itemName, int amount) async {
  final ItemData =
      ListItem(id: '', itemName: itemName, amount: amount, acquired: false)
          .toFirestore();
  final FirebaseFirestore db = FirebaseFirestore.instance;
  await db.collection('listItems').add(ItemData);
}

Future<void> editItem(String id, String itemName, int amount) async {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final data = {
    'itemName': itemName,
    'amount': amount,
  };
  await db.collection('listItems').doc(id).set(data, SetOptions(merge: true));
}

Future<void> deleteAll() async {
  final snapshot =
      await FirebaseFirestore.instance.collection('listItems').get();
  for (DocumentSnapshot ds in snapshot.docs) {
    ds.reference.delete();
  }
}

Future<void> toggleAcquiredProvider(ListItem item) async {
  if (item.id.isNotEmpty) {
    final newValue = item.toggleAcquired();
    final data = {'acquired': newValue};
    final FirebaseFirestore db = FirebaseFirestore.instance;
    await db
        .collection('listItems')
        .doc(item.id)
        .set(data, SetOptions(merge: true));
  } else {
    return;
  }
}
