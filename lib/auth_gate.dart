import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui_testing/dashboard.dart';
import 'package:flutterfire_ui_testing/dashboard_admin.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          return StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SignInScreen(
                  providerConfigs: [
                    EmailProviderConfiguration(),
                  ],
                );
              }
              if (FirebaseAuth.instance.currentUser!.email ==
                  'qg.rickfeed@gmail.com') return const DashboardAdmin();
              return const Dashboard();
            },
          );
        },
      ),
    );
  }
}
