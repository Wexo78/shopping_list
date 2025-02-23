import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// This function fetches data from firestore every time user starts adding new grocery item
// Returns List of strings as grocery item names

Future<List<String>> getSuggestions() async {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final uid = FirebaseAuth.instance.currentUser!.uid;

  final snapshot = await db.collection('userItems').doc(uid).get();

  if (snapshot.exists) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    List<String> usersGroceryHistory = data.keys.toList();
    return usersGroceryHistory;
  }

  return [];
}
