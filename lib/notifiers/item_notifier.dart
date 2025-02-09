import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:shopping_list/models/list_item.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ItemNotifier extends StateNotifier<List<ListItem>> {
  ItemNotifier() : super([]) {
    _fetchItems();
  }

  StreamSubscription? _subscription;

  void _fetchItems() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    // print('************ uid on notifier *********');
    // print(uid);
    // print('************ uid on notifier *********');
    final FirebaseFirestore db = FirebaseFirestore.instance;

    // Cancel any existing subscription to prevent multiple listeners
    _subscription?.cancel();

    _subscription = db
        .collection('listItems')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .listen((snapshot) {
      // Convert the Firestore snapshot into a list of ListItem objects
      final itemList = snapshot.docs.map((doc) {
        return ListItem.fromFireStore(doc.id, doc.data());
      }).toList();
      state = itemList;
    });

    // final docRef =
    //     await db.collection('listItems').where('userId', isEqualTo: uid).get();
    // docRef.docs.forEach(
    //     (doc) => itemList.add(ListItem.fromFireStore(doc.id, doc.data())));
  }

  void reset() {
    _subscription?.cancel();
    _subscription = null;
    state = []; // Reset to initial value.
  }

  Future<void> deleteItem(String id) async {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    await db.collection('listItems').doc(id).delete();
    // state = state.where((item) => item.id != id).toList();
  }

  Future<void> addItem(String itemName, String amount) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final ItemData = ListItem(
            id: '',
            itemName: itemName,
            amount: amount,
            acquired: false,
            userId: uid)
        .toFirestore();
    final FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentReference docRef = await db.collection('listItems').add(ItemData);
    final docId = docRef.id;
    ListItem newItem =
        ListItem(id: docId, itemName: itemName, userId: uid, amount: amount);

    final listDocRef =
        FirebaseFirestore.instance.collection('userItems').doc(uid);

    await listDocRef.set({
      itemName: FieldValue.increment(1),
    }, SetOptions(merge: true));
    //  state = [...state, newItem];
  }

  Future<void> editItem(
      String id, String itemName, String amount, String category) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User is not authenticated');
    }

    final FirebaseFirestore db = FirebaseFirestore.instance;
    final data = {
      'itemName': itemName,
      'amount': amount,
      'category': category,
      'userId': user.uid,
    };
    await db.collection('listItems').doc(id).set(data, SetOptions(merge: true));
    //  final item = state.firstWhere((item) => item.id == id);
    // state = [
    //   for (final item in state)
    //     if (item.id == id)
    //       item.copyWith(name: itemName, amount: amount, category: category)
    //     else
    //       item,
    // ];
  }

  Future<void> deleteAll() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final snapshot = await FirebaseFirestore.instance
        .collection('listItems')
        .where('userId', isEqualTo: uid)
        .get();

    // Use a batch for efficient deletion
    final batch = FirebaseFirestore.instance.batch();
    for (DocumentSnapshot ds in snapshot.docs) {
      batch.delete(ds.reference);
    }

    // Commit the batch
    await batch.commit();

    // state = [];
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

      // state = [
      //   for (final listItem in state)
      //     if (listItem.id == item.id)
      //       item.copyWith(acquired: newValue)
      //     else
      //       item,
      // ];
    } else {
      return;
    }
  }
}

final itemProvider = StateNotifierProvider<ItemNotifier, List<ListItem>>((ref) {
  return ItemNotifier();
});
