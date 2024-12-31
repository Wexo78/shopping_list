import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list/preferences/app_preferences.dart';
import 'package:shopping_list/screens/auth_screen.dart';
import 'package:shopping_list/screens/items_screen.dart';
import 'package:shopping_list/screens/start_screen.dart';

/*

final activeScreenProvider = StateProvider((ref) {
  // Initialize between on preferences
  return AppPreferences.instance.showWelcomeDialog
      ? 'welcome-screen'
      : 'auth-screen';
});

class ShoppingApp extends StatelessWidget {
  const ShoppingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          listTileTheme: ListTileThemeData(
            dense: true, // Applies dense styling to all ListTiles
            contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
          ),
        ),
        home: ProviderScope(child: Consumer(builder: (context, ref, _) {
          // Check user's authentication state and showWelcomeDialog preference
          final currentUser = FirebaseAuth.instance.currentUser;
/*
          if (currentUser != null &&
              AppPreferences.instance.showWelcomeDialog) {
            ref.read(activeScreenProvider.notifier).state = 'welcome-screen';
          } else if (currentUser != null) {
            ref.read(activeScreenProvider.notifier).state = 'items-screen';
          } else if (!AppPreferences.instance.showWelcomeDialog) {
            ref.read(activeScreenProvider.notifier).state = 'auth-screen';
          }
          */

          final activeScreen = ref.watch(activeScreenProvider);
          switch (activeScreen) {
            case 'items-screen':
              return ItemsScreen(
                  toHomeScreen: () => ref
                      .read(activeScreenProvider.notifier)
                      .state = 'auth-screen');

            case 'auth-screen':
              return AuthScreen(
                  toItemsScreen: () => ref
                      .read(activeScreenProvider.notifier)
                      .state = 'items-screen');

            default:
              return StartScreen(
                  toListScreen: () => ref
                      .read(activeScreenProvider.notifier)
                      .state = 'auth-screen',
                  updateShowedWelcome: (value) {
                    if (value) {
                      ref.read(activeScreenProvider.notifier).state =
                          'auth-screen';
                    }
                  });
          }
        })));
  }
}

*/

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
