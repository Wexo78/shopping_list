import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shopping_list/main.dart';
import 'package:shopping_list/preferences/app_preferences.dart';

class StartScreen extends StatefulWidget {
  StartScreen(
      {required this.toListScreen,
      required this.updateShowedWelcome,
      super.key});
  final void Function() toListScreen;
  final void Function(bool) updateShowedWelcome;

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  final int _totalPages = 3;
  late Timer _autoSwipeTimer;
  bool _dontShowAgain = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView(
              // controller: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: [
                // First view/card
                _buildView(
                    imagePath: 'assets/images/start_image.png',
                    title: 'Welcome to App',
                    description:
                        'Welcome to shared grocery list app with AI categorization'),

                // Second view/card
                _buildView(
                    imagePath: 'assets/images/auth_screen.png',
                    title: 'Create an account',
                    description:
                        'Create account with valid email address and share credentials to person you want to use same shopping list'),

                // Third view/card
                _buildView(
                    imagePath: 'assets/images/item_screen.png',
                    title: 'Start listing',
                    description:
                        'Start adding items into list. You can tap item to mark as picked. If you have multiple items, you can tap \'Categorize\' to help shopping in grocery store'),
              ],
            ),
          ),
          if (_currentPage == _totalPages - 1)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: _dontShowAgain,
                  onChanged: (value) {
                    setState(() {
                      _dontShowAgain = value ?? false;
                    });
                  },
                ),
                Text(
                  "Don't show this screen again",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          if (_currentPage == _totalPages - 1)
            TextButton.icon(
                icon: const Icon(Icons.arrow_forward_outlined),
                onPressed: () async {
                  if (_dontShowAgain) {
                    AppPreferences.instance.showWelcomeDialog = false;
                  }
                  widget.updateShowedWelcome(true);
                  widget.toListScreen();
                },
                label: const Text(
                  'Get started',
                  style: TextStyle(fontSize: 20),
                )),
          _buildPageIndicator(_totalPages, _currentPage),
          const SizedBox(
            height: 16,
          ),
        ],
      ),
    );
  }
}

Widget _buildView({
  required String imagePath,
  required String title,
  required String description,
}) {
  return Container(
    padding: const EdgeInsets.all(24),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          imagePath,
          height: 400,
        ),
        const SizedBox(height: 20),
        Text(title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(
          height: 10,
        ),
        Text(
          description,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    ),
  );
}

Widget _buildPageIndicator(int totalPages, int currentPage) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(
        totalPages,
        (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              width: 8.0,
              height: 8.0,
              decoration: BoxDecoration(
                  color: currentPage == index ? Colors.blue : Colors.grey,
                  borderRadius: BorderRadius.circular(4.0)),
            )),
  );
}
