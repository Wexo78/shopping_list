import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shopping_list/firebase_options.dart';
import 'package:shopping_list/preferences/app_preferences.dart';
import 'package:shopping_list/screens/shopping_app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: ".env");
  await AppPreferences.instance.init();

  runApp(const ShoppingApp());
}
