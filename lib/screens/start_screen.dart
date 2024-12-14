// This is base screen where application lands on

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({required this.toListScreen, super.key});
  final void Function() toListScreen;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Center(
              child: Text(
        'Was there everything?',
      ))),
      body: SafeArea(
        child: Container(
          height: double.infinity,
          child: ListView(
            children: [
              const SizedBox(
                height: 20,
              ),
              Text(
                'Welcome to shopping list app!',
                style: GoogleFonts.lato(
                  fontWeight: FontWeight.bold,
                ),
                textScaler: const TextScaler.linear(1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Image.asset(
                'assets/images/start_image.png',
                height: 400,
              ),
              const SizedBox(
                height: 50,
              ),
              TextButton.icon(
                  icon: const Icon(Icons.arrow_forward_outlined),
                  onPressed: toListScreen,
                  label: const Text(
                    'To list',
                    style: TextStyle(fontSize: 25),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
