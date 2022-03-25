import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui_testing/farmer_data_model.dart';
import 'package:flutterfire_ui_testing/main.dart';
import 'package:flutterfire_ui_testing/view_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multiselect/multiselect.dart';

class NewFarmer extends StatefulWidget {
  bool edit;
  String docId, farmerCode;
  FarmerDataModel farmerDataModel;
  NewFarmer(this.farmerCode, this.edit, this.docId, this.farmerDataModel,
      {Key? key})
      : super(key: key);

  @override
  _NewFarmerState createState() => _NewFarmerState();
}

class _NewFarmerState extends State<NewFarmer> {
  var txtName = TextEditingController();
  var txtNumber = TextEditingController();
  var txtEmail = TextEditingController();
  var txtLocation = TextEditingController();
  var txtPanNo = TextEditingController();
  var txtAadhaarNo = TextEditingController();
  var txtBankAccNumber = TextEditingController();
  var txtBankName = TextEditingController();
  var txtBankIfscCode = TextEditingController();
  var txtNotes = TextEditingController();
  String dropDownValue = '', code = '', reason = '';
  String stringPanId = '', stringAadhaarId = '', imageUrl = '';
  List images = [];
  bool attended = false;
  var _imageFile;
  bool isAdmin =
      FirebaseAuth.instance.currentUser!.email == 'qg.rickfeed@gmail.com';
  final picker = ImagePicker();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (!widget.edit) {
      setState(() {
        code = widget.farmerCode;
      });
    } else {
      prepare();
    }
  }

  void prepare() {
    setState(() {
      code = widget.farmerDataModel.code!;
      images = widget.farmerDataModel.images!;
      txtName.text = widget.farmerDataModel.name!;
      txtNumber.text = widget.farmerDataModel.number!;
      txtEmail.text = widget.farmerDataModel.email!;
      txtLocation.text = widget.farmerDataModel.location!;
      txtPanNo.text = widget.farmerDataModel.panNo!;
      txtAadhaarNo.text = widget.farmerDataModel.aadhaarNo!;
      stringPanId = widget.farmerDataModel.panId!;
      stringAadhaarId = widget.farmerDataModel.aadhaarId!;
      int i = 0;
      attended = widget.farmerDataModel.attended!;
      txtBankAccNumber.text = widget.farmerDataModel.bankAccNumber!;
      txtBankName.text = widget.farmerDataModel.bankName!;
      txtBankIfscCode.text = widget.farmerDataModel.bankIfscCode!;
    });
  }

  void saveEditFarmer() {
    FirebaseFirestore.instance.collection('farmers').doc(code).set({
      'code': code,
      'images': images,
      'name': txtName.text,
      'number': txtNumber.text,
      'email': txtEmail.text,
      'location': txtLocation.text,
      'panNo': txtPanNo.text,
      'aadhaarNo': txtAadhaarNo.text,
      'panId': stringPanId,
      'aadhaarId': stringAadhaarId,
      'attended': isAdmin ? attended : true,
      'bankAccNumber': txtBankAccNumber.text,
      'bankName': txtBankName.text,
      'bankIfscCode': txtBankIfscCode.text,
      'notes': txtNotes.text,
      'timestamp': DateTime.now().toString(),
    });
    Navigator.of(context).pop(true);
  }

  Future pickImage(bool panId) async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      uploadImageToFirebase(panId);
    }
  }

  Future uploadImageToFirebase(bool panId) async {
    String fileName = _imageFile.path.substring(
        _imageFile.path.lastIndexOf('/') + 1, _imageFile.path.length);
    Reference firebaseStorageRef =
        FirebaseStorage.instance.ref().child(fileName);
    UploadTask uploadTask = firebaseStorageRef.putFile(_imageFile);
    TaskSnapshot taskSnapshot = await uploadTask;
    taskSnapshot.ref.getDownloadURL().then(
      (value) {
        setState(() {
          if (panId) {
            stringPanId = value;
          } else {
            stringAadhaarId = value;
          }
        });
      },
    );
  }

  Future pickProfileImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      uploadProfileImageToFirebase();
    }
  }

  Future uploadProfileImageToFirebase() async {
    String fileName = _imageFile.path.substring(
        _imageFile.path.lastIndexOf('/') + 1, _imageFile.path.length);
    Reference firebaseStorageRef =
        FirebaseStorage.instance.ref().child(fileName);
    UploadTask uploadTask = firebaseStorageRef.putFile(_imageFile);
    TaskSnapshot taskSnapshot = await uploadTask;
    taskSnapshot.ref.getDownloadURL().then(
      (value) {
        setState(() {
          imageUrl = value;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.edit ? 'Edit farmer' : 'Add new farmer',
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          saveEditFarmer();
        },
        child: const Icon(
          Icons.done_rounded,
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: const AssetImage('assets/profile.jpeg'),
                foregroundImage: NetworkImage(imageUrl != '' ? imageUrl : ''),
              ),
              const SizedBox(
                height: 10,
              ),
              OutlinedButton(
                onPressed: () async {
                  await pickProfileImage();
                },
                child: const Text('Capture photo'),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: txtName,
                enabled: isAdmin,
                decoration: const InputDecoration(labelText: 'Enter name'),
              ),
              TextField(
                controller: txtNumber,
                enabled: isAdmin,
                decoration:
                    const InputDecoration(labelText: 'Enter mobile number'),
              ),
              TextField(
                controller: txtEmail,
                enabled: isAdmin,
                decoration: const InputDecoration(labelText: 'Enter email'),
              ),
              TextField(
                controller: txtLocation,
                enabled: isAdmin,
                decoration: const InputDecoration(labelText: 'Enter location'),
              ),
              TextField(
                controller: txtPanNo,
                enabled: isAdmin,
                decoration: const InputDecoration(labelText: 'Pan no'),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () async {
                      if (isAdmin) {
                        await pickImage(true);
                      }
                    },
                    child: const Text('Upload pan card photo'),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Visibility(
                    visible: stringPanId.isNotEmpty,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ViewImage(stringPanId)));
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          stringPanId,
                          fit: BoxFit.cover,
                          height: 50,
                          width: 50,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              TextField(
                controller: txtAadhaarNo,
                enabled: isAdmin,
                decoration: const InputDecoration(labelText: 'Aadhaar No'),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () async {
                      if (isAdmin) {
                        await pickImage(false);
                      }
                    },
                    child: const Text('Upload aadhaar card photo'),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Visibility(
                    visible: stringAadhaarId.isNotEmpty,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ViewImage(stringAadhaarId)));
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          stringAadhaarId,
                          fit: BoxFit.cover,
                          height: 50,
                          width: 50,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              TextField(
                controller: txtBankAccNumber,
                enabled: isAdmin,
                decoration:
                    const InputDecoration(labelText: 'Bank account number'),
              ),
              TextField(
                controller: txtBankName,
                enabled: isAdmin,
                decoration: const InputDecoration(labelText: 'Bank name'),
              ),
              TextField(
                controller: txtBankIfscCode,
                enabled: isAdmin,
                decoration: const InputDecoration(labelText: 'Bank IFSC code'),
              ),
              TextField(
                controller: txtNotes,
                decoration: const InputDecoration(labelText: 'Notes'),
              ),
              const SizedBox(
                height: 100,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
