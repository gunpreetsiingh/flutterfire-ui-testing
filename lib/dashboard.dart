import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  var txtName = TextEditingController();

  @override
  void initState() {
    super.initState();
    checkName();
  }

  void checkName() async {
    await Future.delayed(Duration.zero);
    if (FirebaseAuth.instance.currentUser!.displayName == null ||
        FirebaseAuth.instance.currentUser!.displayName!.trim() == '') {
      confirmName();
    }
  }

  void confirmName() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Please enter your name.'),
          content: TextField(
            controller: txtName,
            decoration: const InputDecoration(hintText: 'Start typing...'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (txtName.text.isNotEmpty) {
                  await FirebaseAuth.instance.currentUser!
                      .updateDisplayName(txtName.text);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void confirmSignOut() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text(
            'Are you sure you want to logout?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Dashboard'),
        actions: [
          TextButton(
            onPressed: confirmSignOut,
            child: const Icon(
              Icons.logout_outlined,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              FirebaseAuth.instance.currentUser!.email!,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 20,
              ),
            ),
            const SizedBox(
              height: 15,
            ),
          ],
        ),
      ),
    );
  }
}
