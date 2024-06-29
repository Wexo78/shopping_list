import 'package:flutter/material.dart';
import 'package:shopping_list/firebase_options.dart';
import 'package:shopping_list/screens/shopping_app.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ShoppingApp());
}
