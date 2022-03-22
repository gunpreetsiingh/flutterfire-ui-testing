import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui_testing/dashboard.dart';
import 'package:flutterfire_ui_testing/dashboard_admin.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool isLoading = true;
  late QuerySnapshot colAdmins;
  List<String> listAdminEmails = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadAdminEmails();
  }

  void loadAdminEmails() async {
    setState(() {
      isLoading = true;
    });
    colAdmins = await FirebaseFirestore.instance.collection('admins').get();
    colAdmins.docs.forEach((element) {
      listAdminEmails.add(element['email']);
    });
    setState(() {
      isLoading = false;
    });
  }

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
              if (listAdminEmails
                  .contains(FirebaseAuth.instance.currentUser!.email))
                return const DashboardAdmin();
              return const Dashboard();
            },
          );
        },
      ),
    );
  }
}
