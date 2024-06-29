import 'package:flutter/material.dart';
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
  var activeScreen = 'start-screen';

  void switchScreen() {
    setState(() {
      activeScreen = 'items_screen';
    });
  }

  void homeScreen() {
    setState(() {
      activeScreen = 'start-screen';
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget screenWidget = StartScreen(toListScreen: switchScreen);
    if (activeScreen == 'items_screen') {
      screenWidget = ItemsScreen(
        toHomeScreen: homeScreen,
      );
    }

    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
              title: const Center(
                  child: Text(
            'Was there everything?',
          ))),
          body: SafeArea(child: screenWidget)),
    );
  }
}
