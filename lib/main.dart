import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shopping_list/firebase_options.dart';
import 'package:shopping_list/screens/shopping_app.dart';
import 'package:firebase_core/firebase_core.dart';

const apiKey = String.fromEnvironment('OPENAI_API_KEY', defaultValue: '');
const baseUrl = String.fromEnvironment('BASE_URL', defaultValue: '');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // await dotenv.load(fileName: ".env");

  runApp(const ShoppingApp());
}
