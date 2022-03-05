import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui_testing/farmer_data_model.dart';
import 'package:flutterfire_ui_testing/new_farmer.dart';
import 'package:flutterfire_ui_testing/view_image.dart';
import 'package:image_picker/image_picker.dart';
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
  bool isLoading = true;
  late QuerySnapshot colFarmers, colEmployee;
  String imageUrl = '', employeeCode = '';

  final FirebaseStorage _storage = FirebaseStorage.instance;
  late File _imageFile;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    checkName();
    loadData();
  }

  void loadData() async {
    setState(() {
      isLoading = true;
    });
    colFarmers = await FirebaseFirestore.instance
        .collection('farmers')
        .orderBy('name')
        .get();
    colEmployee = await FirebaseFirestore.instance
        .collection('employees')
        .where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email)
        .get();
    setState(() {
      employeeCode = colEmployee.docs.first['code'];
      isLoading = false;
    });
  }

  void checkName() async {
    await Future.delayed(Duration.zero);
    if (Platform.isAndroid) {
      var status = await OneSignal.shared.getDeviceState();
      tokenId = status!.userId!;
    }
    if (FirebaseAuth.instance.currentUser!.displayName == null ||
        FirebaseAuth.instance.currentUser!.displayName!.trim() == '') {
      confirmName();
    }
  }

  String generateRandomCode() {
    int num = Random().nextInt(10000);
    return num.toString();
  }

  void confirmName() async {
    setState(() {
      code = 'E' + generateRandomCode();
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
                decoration: const InputDecoration(hintText: 'Enter your name'),
              ),
              TextField(
                controller: txtNumber,
                decoration:
                    const InputDecoration(hintText: 'Enter your phone number'),
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
                    },
                  );
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
                Navigator.of(context).pop();
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
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      child: const Text(
                        'Long press to edit farmer details.',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height - 106,
                      child: ListView.builder(
                        itemCount: colFarmers.docs.length,
                        itemBuilder: (context, index) {
                          if (colFarmers.docs[index]['employeeCode'] ==
                                  employeeCode &&
                              !colFarmers.docs[index]['attended']) {
                            return Container(
                              margin: const EdgeInsets.only(top: 10),
                              padding: const EdgeInsets.symmetric(vertical: 5),
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
                                onLongPress: () {
                                  // showEditOptions(index);
                                  String docId = colFarmers.docs[index].id;
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => NewFarmer(
                                        true,
                                        docId,
                                        FarmerDataModel(
                                          code: colFarmers.docs[index]['code'],
                                          images: colFarmers.docs[index]
                                              ['images'],
                                          name: colFarmers.docs[index]['name'],
                                          number: colFarmers.docs[index]
                                              ['number'],
                                          email: colFarmers.docs[index]
                                              ['email'],
                                          location: colFarmers.docs[index]
                                              ['location'],
                                          panNo: colFarmers.docs[index]
                                              ['panNo'],
                                          aadhaarNo: colFarmers.docs[index]
                                              ['aadhaarNo'],
                                          panId: colFarmers.docs[index]
                                              ['panId'],
                                          aadhaarId: colFarmers.docs[index]
                                              ['aadhaarId'],
                                          employeeCode: colFarmers.docs[index]
                                              ['employeeCode'],
                                          batches: colFarmers.docs[index]
                                              ['batches'],
                                          attended: colFarmers.docs[index]
                                              ['attended'],
                                          bankAccNumber: colFarmers.docs[index]
                                              ['bankAccNumber'],
                                          bankName: colFarmers.docs[index]
                                              ['bankName'],
                                          bankIfscCode: colFarmers.docs[index]
                                              ['bankIfscCode'],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                leading: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) => ViewImage(
                                                colFarmers.docs[index]
                                                    ['image'])));
                                  },
                                  child: SizedBox(
                                    height: 65,
                                    width: 65,
                                    child: CircleAvatar(
                                      radius: 50,
                                      backgroundImage: const AssetImage(
                                          'assets/profile.jpeg'),
                                      foregroundImage: NetworkImage(colFarmers
                                              .docs[index]['images'].isEmpty
                                          ? ''
                                          : colFarmers.docs[index]['images']
                                              [0]),
                                    ),
                                  ),
                                ),
                                title: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Name: ${colFarmers.docs[index]['name']}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      'Number: ${colFarmers.docs[index]['number']}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      'Email: ${colFarmers.docs[index]['email']}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      'Location: ${colFarmers.docs[index]['location']}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Visibility(
                                      visible: colFarmers.docs[index]
                                          ['attended'],
                                      child: const SizedBox(
                                        height: 5,
                                      ),
                                    ),
                                    Visibility(
                                      visible: colFarmers.docs[index]
                                          ['attended'],
                                      child: Text(
                                        'Notes: ${colFarmers.docs[index]['attended'] ? colFarmers.docs[index]['notes'] : ''}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    Visibility(
                                      visible: colFarmers.docs[index]
                                          ['attended'],
                                      child: const SizedBox(
                                        height: 5,
                                      ),
                                    ),
                                    Visibility(
                                      visible: colFarmers.docs[index]
                                          ['attended'],
                                      child: Text(
                                        'Timestamp: ${DateFormat('dd MMM, yyyy').format(DateTime.parse(colFarmers.docs[index]['attended'] ? colFarmers.docs[index]['timestamp'] : DateTime.now().toString()))}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: colFarmers.docs[index]['attended']
                                    ? const Icon(
                                        Icons.done_rounded,
                                        color: Colors.green,
                                        size: 30,
                                      )
                                    : const Icon(
                                        Icons.warning_amber_rounded,
                                        color: Colors.amber,
                                        size: 30,
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
