import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list/preferences/app_preferences.dart';
import 'package:shopping_list/screens/auth_screen.dart';
import 'package:shopping_list/screens/items_screen.dart';
import 'package:shopping_list/screens/start_screen.dart';

class ShoppingApp extends StatefulWidget {
  const ShoppingApp({super.key});

  @override
  State<ShoppingApp> createState() {
    return _ShoppingAppState();
  }
}

class _ShoppingAppState extends State<ShoppingApp> {
  late bool showWelcomeScreen;
  late String activeScreen;
  bool showedWelcome = false;

  @override
  void initState() {
    showWelcomeScreen = AppPreferences.instance.showWelcomeDialog;
    activeScreen = showWelcomeScreen ? 'welcome_screen' : 'auth_screen';
    super.initState();
  }

  void itemsScreen() {
    setState(() {
      activeScreen = 'items_screen';
    });
  }

  void authScreen() {
    setState(() {
      activeScreen = 'auth_screen';
    });
  }

  void updateShowedWelcome(bool value) {
    setState(() {
      showedWelcome = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    //  Widget screenWidget = StartScreen(toListScreen: itemsScreen);

    Widget screenWidget = showWelcomeScreen
        ? StartScreen(
            updateShowedWelcome: updateShowedWelcome, toListScreen: authScreen)
        : AuthScreen(toItemsScreen: itemsScreen);
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null && showWelcomeScreen == false) {
      itemsScreen();
    } else if (currentUser != null && showedWelcome == true) {
      itemsScreen();
    }

    if (activeScreen == 'items_screen') {
      screenWidget = ItemsScreen(
        toHomeScreen: authScreen,
      );
    } else if (activeScreen == 'auth_screen') {
      screenWidget = AuthScreen(
        toItemsScreen: itemsScreen,
      );
    }

    return MaterialApp(
        theme: ThemeData(
          listTileTheme: ListTileThemeData(
            dense: true, // Applies dense styling to all ListTiles
            contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
          ),
        ),
        home: ProviderScope(child: screenWidget));
  }
}
