import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui_testing/batch_entries.dart';
import 'package:flutterfire_ui_testing/farmer_data_model.dart';
import 'package:flutterfire_ui_testing/new_farmer.dart';
import 'package:flutterfire_ui_testing/view_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:intl/intl.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  var txtName = TextEditingController();
  var txtNumber = TextEditingController();
  var txtNotes = TextEditingController();
  var txtLossQty = TextEditingController();
  var txtReason = TextEditingController();
  String tokenId = '', code = '';
  bool isLoading = true, showError = false;
  late QuerySnapshot colBatches, colEmployee, colEmployees;
  String imageUrl = '', employeeCode = '';

  final FirebaseStorage _storage = FirebaseStorage.instance;
  late File _imageFile;
  final picker = ImagePicker();
  Location location = new Location();

  @override
  void initState() {
    super.initState();
    checkName();
  }

  Future<void> loadExistingEmployees() async {
    colEmployees = await FirebaseFirestore.instance
        .collection('employees')
        .orderBy('code', descending: true)
        .limit(1)
        .get();
  }

  void loadData() async {
    setState(() {
      isLoading = true;
    });
    await checkLocationPermissions();
    colEmployee = await FirebaseFirestore.instance
        .collection('employees')
        .where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email)
        .get();
    colBatches = await FirebaseFirestore.instance
        .collection('batches')
        .orderBy('farmerName')
        .get();
    setState(() {
      employeeCode = colEmployee.docs.first['code'];
      if (colEmployee.docs.first['activated']) {
        showError = false;
      } else {
        showError = true;
      }
      isLoading = false;
    });
  }

  Future<void> checkLocationPermissions() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }

  void checkName() async {
    await Future.delayed(Duration.zero);
    await loadExistingEmployees();
    if (!kIsWeb) {
      if (Platform.isAndroid) {
        var status = await OneSignal.shared.getDeviceState();
        tokenId = status!.userId!;
      }
    }
    if (FirebaseAuth.instance.currentUser!.displayName == null ||
        FirebaseAuth.instance.currentUser!.displayName!.trim() == '') {
      confirmName();
    } else {
      loadData();
    }
  }

  void confirmName() async {
    setState(() {
      if (colEmployees.docs.isEmpty) {
        code = 'E100';
      } else {
        code = 'E' +
            (int.parse(colEmployees.docs.first['code']
                        .substring(1, colEmployees.docs.first['code'].length)) +
                    1)
                .toString();
      }
    });
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Please enter your details.'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: txtName,
                decoration: const InputDecoration(labelText: 'Enter your name'),
              ),
              TextField(
                controller: txtNumber,
                decoration:
                    const InputDecoration(labelText: 'Enter your phone number'),
              ),
            ],
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
                if (txtName.text.isNotEmpty && txtNumber.text.isNotEmpty) {
                  await FirebaseAuth.instance.currentUser!
                      .updateDisplayName(txtName.text);
                  await FirebaseFirestore.instance.collection('employees').add(
                    {
                      'code': code,
                      'name': txtName.text,
                      'number': txtNumber.text,
                      'image': '',
                      'email': FirebaseAuth.instance.currentUser!.email,
                      'token': tokenId,
                      'activated': false,
                    },
                  );
                }
                Navigator.of(context).pop();
                loadExistingEmployees();
                loadData();
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
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pop();
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
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : showError
                ? const Text('Your account is not yet activated!')
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          child: const Text(
                            'Tap on a batch to edit details.',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height - 106,
                          child: ListView.builder(
                            itemCount: colBatches.docs.length,
                            itemBuilder: (context, index) {
                              if (DateTime.parse(
                                          colBatches.docs[index]['endingDate'])
                                      .isAfter(DateTime.now()) &&
                                  colBatches.docs[index]['employee'] ==
                                      colEmployee.docs.first['code'] +
                                          '-' +
                                          colEmployee.docs.first['name']) {
                                return Container(
                                  margin: const EdgeInsets.only(top: 10),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.15),
                                          blurRadius: 5,
                                          spreadRadius: 5,
                                        )
                                      ]),
                                  child: ListTile(
                                    onTap: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  BatchEntries(
                                                      colBatches.docs[index]
                                                          ['code'],
                                                      colBatches.docs[index]
                                                          ['qty'],
                                                      colBatches.docs[index]
                                                          ['fromDate'])));
                                    },
                                    title: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Batch Name: ${colBatches.docs[index]['name']}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          'Farmer Name: ${colBatches.docs[index]['farmerName']}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          'Qty: ${colBatches.docs[index]['qty']}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                              return Container();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
