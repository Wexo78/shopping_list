import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutContent extends StatelessWidget {
  const AboutContent({super.key});

  Widget _infoTile(String title, String subtitle) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle.isEmpty ? 'Not set' : subtitle),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: PackageInfo.fromPlatform(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }

          final packageInfo = snapshot.data!;
          final email = FirebaseAuth.instance.currentUser!.email;

          return SizedBox(
            height: 300,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  _infoTile('App name', packageInfo.appName),
                  _infoTile('Package name', packageInfo.packageName),
                  _infoTile('App version', packageInfo.version),
                  _infoTile('Build number', packageInfo.buildNumber),
                  _infoTile('Build signature', packageInfo.buildSignature),
                  _infoTile(
                    'Installer store',
                    packageInfo.installerStore ?? 'Not available',
                  ),
                  _infoTile(
                    'Username',
                    email.toString(),
                  ),
                ],
              ),
            ),
          );

          /*
          return Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(
                'Shared shopping list with AI',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(
                height: 16,
              ),
              const Text(
                'This app helps users manage shared lists. Users with same credentials can add and edit items collaboratively.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 16,
              ),
              Text('Version: ${packageInfo.version}'),
              Text('Buildnumber: ${packageInfo.buildNumber}'),
            ]),
          );
          */
        });
  }
}
