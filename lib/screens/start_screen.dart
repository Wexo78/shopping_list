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
  bool _dontShowAgain = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              const SizedBox(
                height: 20,
              ),
              Text(
                'Shopping list with AI',
                style: GoogleFonts.lato(
                  fontWeight: FontWeight.bold,
                ),
                textScaler: const TextScaler.linear(1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Text(
                'About app',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                'With this app you can use collaborated shopping lists. Application categorizes shopping items so in shop it\'s easier for you purchase groceries.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Divider(thickness: 1.0, height: 40.0),
              Text(
                'What next',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                'Next step is to create an account. Please use valid email address so if you don\'t remember your password you receive a link for renewal password into your email. After creating account you can give email and password anyone you want to share shopping list with. Enjoy.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(
                height: 100,
              ),
              Spacer(),
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
                  Text("Don't show this screen again"),
                ],
              ),
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
                    style: TextStyle(fontSize: 25),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
