import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutterfire_ui_testing/auth_gate.dart';
import 'package:flutterfire_ui_testing/firebase_options.dart';
import 'package:flutterfire_ui_testing/gc/gc_report_view.dart';
import 'package:flutterfire_ui_testing/new_scheme_entry.dart';
// import 'package:onesignal_flutter/onesignal_flutter.dart';

List<String> employees = [];
List<String> employeesToken = [];
List<String> farmers = [];
List<String> batches = [];
List<String> categories = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  // OneSignal.initialize('28caf8a7-aa7f-46e5-adff-bc09e0881cc2');
  // OneSignal.Notifications.requestPermission(true).then((accepted) {
  //   debugPrint("Accepted permission: $accepted");
  // });
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NewSchemeEntry(
        schemeDataModel: null,
      ), // AuthGate(),
    );
  }
}
