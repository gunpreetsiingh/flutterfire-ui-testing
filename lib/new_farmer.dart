import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui_testing/farmer_data_model.dart';
import 'package:flutterfire_ui_testing/main.dart';
import 'package:flutterfire_ui_testing/view_image.dart';
import 'package:image_picker/image_picker.dart';

class NewFarmer extends StatefulWidget {
  bool edit;
  String docId;
  FarmerDataModel farmerDataModel;
  NewFarmer(this.edit, this.docId, this.farmerDataModel, {Key? key})
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
  var txtCurrentBatch = TextEditingController();
  var txtFromDate = TextEditingController();
  var txtToDate = TextEditingController();
  var txtBatchEffectiveOn = TextEditingController();
  var txtTotalQtyAllotted = TextEditingController();
  var txtLossQtyTillDate = TextEditingController();
  var txtBankAccNumber = TextEditingController();
  var txtBankName = TextEditingController();
  var txtBankIfscCode = TextEditingController();
  String dropDownValue = '', code = '', employeeCode = '';
  String stringPanId = '', stringAadhaarId = '';
  List<String> images = [];
  bool attended = false;
  var _imageFile;

  final picker = ImagePicker();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (!widget.edit) {
      setState(() {
        code = 'F' + generateRandomCode();
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
      employeeCode = widget.farmerDataModel.employeeCode!;
      employees.forEach((element) {
        if (element.startsWith(employeeCode)) {
          dropDownValue = element;
        }
      });
      txtCurrentBatch.text = widget.farmerDataModel.currentBatch!;
      txtFromDate.text = widget.farmerDataModel.fromDate!;
      txtToDate.text = widget.farmerDataModel.toDate!;
      txtBatchEffectiveOn.text = widget.farmerDataModel.batchEffectiveOn!;
      txtTotalQtyAllotted.text = widget.farmerDataModel.totalQtyAllotted!;
      txtLossQtyTillDate.text = widget.farmerDataModel.lossQtyTillDate!;
      attended = widget.farmerDataModel.attended!;
      txtBankAccNumber.text = widget.farmerDataModel.bankAccNumber!;
      txtBankName.text = widget.farmerDataModel.bankName!;
      txtBankIfscCode.text = widget.farmerDataModel.bankIfscCode!;
    });
  }

  void saveEditEmployee() {
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
      'employeeCode': employeeCode,
      'currentBatch': txtCurrentBatch.text,
      'fromDate': txtFromDate.text,
      'toDate': txtToDate.text,
      'batchEffectiveOn': txtBatchEffectiveOn.text,
      'totalQtyAllotted': txtTotalQtyAllotted.text,
      'lossQtyTillDate': txtLossQtyTillDate.text,
      'attended': attended,
      'bankAccNumber': txtBankAccNumber.text,
      'bankName': txtBankName.text,
      'bankIfscCode': txtBankIfscCode.text,
      'notes': '',
      'timestamp': DateTime.now().toString(),
    });
    Navigator.of(context).pop();
  }

  String generateRandomCode() {
    int num = Random().nextInt(10000);
    return num.toString();
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
          saveEditEmployee();
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
              const SizedBox(
                height: 0,
              ),
              TextField(
                controller: txtName,
                decoration: const InputDecoration(hintText: 'Enter name'),
              ),
              TextField(
                controller: txtNumber,
                decoration:
                    const InputDecoration(hintText: 'Enter mobile number'),
              ),
              TextField(
                controller: txtEmail,
                decoration: const InputDecoration(hintText: 'Enter email'),
              ),
              TextField(
                controller: txtLocation,
                decoration: const InputDecoration(hintText: 'Enter location'),
              ),
              TextField(
                controller: txtPanNo,
                decoration: const InputDecoration(hintText: 'Pan no'),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () async {
                      await pickImage(true);
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
                decoration: const InputDecoration(hintText: 'Aadhaar No'),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () async {
                      await pickImage(false);
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
                controller: txtCurrentBatch,
                decoration: const InputDecoration(hintText: 'Current Batch'),
              ),
              TextField(
                controller: txtFromDate,
                decoration: const InputDecoration(hintText: 'From Date'),
              ),
              TextField(
                controller: txtToDate,
                decoration: const InputDecoration(hintText: 'To Date'),
              ),
              TextField(
                controller: txtBatchEffectiveOn,
                decoration:
                    const InputDecoration(hintText: 'Batch effective on'),
              ),
              TextField(
                controller: txtTotalQtyAllotted,
                decoration:
                    const InputDecoration(hintText: 'Total quantity allotted'),
              ),
              TextField(
                controller: txtLossQtyTillDate,
                decoration:
                    const InputDecoration(hintText: 'Loss quantity till date'),
              ),
              TextField(
                controller: txtBankAccNumber,
                decoration:
                    const InputDecoration(hintText: 'Bank account number'),
              ),
              TextField(
                controller: txtBankName,
                decoration: const InputDecoration(hintText: 'Bank name'),
              ),
              TextField(
                controller: txtBankIfscCode,
                decoration: const InputDecoration(hintText: 'Bank IFSC code'),
              ),
              DropdownButton<String>(
                hint: const Text('Select employee'),
                value: dropDownValue == '' ? null : dropDownValue,
                isExpanded: true,
                icon: const Icon(Icons.arrow_downward),
                elevation: 16,
                onChanged: (String? newValue) {
                  setState(() {
                    dropDownValue = newValue!;
                    employeeCode = newValue.substring(0, newValue.indexOf('-'));
                  });
                },
                items: employees.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
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
