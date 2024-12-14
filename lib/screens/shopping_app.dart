import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  var activeScreen = 'auth_screen';

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

  void addItem() {}

  @override
  Widget build(BuildContext context) {
    //  Widget screenWidget = StartScreen(toListScreen: itemsScreen);

    Widget screenWidget = AuthScreen(toItemsScreen: itemsScreen);

    final currentUser = FirebaseAuth.instance.currentUser;
    print('currentUser: $currentUser');

    if (currentUser != null) {
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
        home: screenWidget

        /*
      Scaffold(
          appBar: AppBar(
              title: const Center(
                  child: Text(
            'Was there everything?',
          ))),
          body: SafeArea(child: screenWidget),
          
          ),
*/
        );
  }
}
