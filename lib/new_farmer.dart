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
  List<TextEditingController> txtCurrentBatch = [];
  List<TextEditingController> txtFromDate = [];
  List<TextEditingController> txtToDate = [];
  List<TextEditingController> txtBatchEffectiveOn = [];
  List<TextEditingController> txtTotalQtyAllotted = [];
  List<TextEditingController> txtLossQtyTillDate = [];
  List<TextEditingController> txtReason = [];
  var txtBankAccNumber = TextEditingController();
  var txtBankName = TextEditingController();
  var txtBankIfscCode = TextEditingController();
  var txtNotes = TextEditingController();
  String dropDownValue = '', code = '', employeeCode = '', reason = '';
  String stringPanId = '', stringAadhaarId = '', imageUrl = '';
  List images = [];
  bool attended = false;
  var _imageFile;
  List<Widget> batches = [];
  bool isAdmin =
      FirebaseAuth.instance.currentUser!.email == 'qg.rickfeed@gmail.com';
  final picker = ImagePicker();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (!widget.edit) {
      setState(() {
        code = 'F' + generateRandomCode();
      });
      addBatch(batches.length);
    } else {
      widget.farmerDataModel.batches!.forEach(((element) {
        addBatch(batches.length);
      }));
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
      int i = 0;
      while (i < batches.length) {
        txtCurrentBatch[i].text =
            widget.farmerDataModel.batches![i]['currentBatch'];
        txtFromDate[i].text = widget.farmerDataModel.batches![i]['fromDate'];
        txtToDate[i].text = widget.farmerDataModel.batches![i]['toDate'];
        txtBatchEffectiveOn[i].text =
            widget.farmerDataModel.batches![i]['batchEffectiveOn'];
        txtTotalQtyAllotted[i].text =
            widget.farmerDataModel.batches![i]['totalQtyAllotted'];
        txtLossQtyTillDate[i].text =
            widget.farmerDataModel.batches![i]['lossQtyTillDate'];
        txtReason[i].text = widget.farmerDataModel.batches![i]['reason'];
        i++;
      }
      attended = widget.farmerDataModel.attended!;
      txtBankAccNumber.text = widget.farmerDataModel.bankAccNumber!;
      txtBankName.text = widget.farmerDataModel.bankName!;
      txtBankIfscCode.text = widget.farmerDataModel.bankIfscCode!;
    });
  }

  void saveEditFarmer() {
    List batchData = [];
    int i = 0;
    while (i < txtCurrentBatch.length) {
      batchData.add({
        'currentBatch': txtCurrentBatch[i].text,
        'fromDate': txtFromDate[i].text,
        'toDate': txtToDate[i].text,
        'batchEffectiveOn': txtBatchEffectiveOn[i].text,
        'totalQtyAllotted': txtTotalQtyAllotted[i].text,
        'lossQtyTillDate': txtLossQtyTillDate[i].text,
        'reason': txtReason[i].text,
      });
      i++;
    }
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
      'batches': batchData,
      'attended': isAdmin ? attended : true,
      'bankAccNumber': txtBankAccNumber.text,
      'bankName': txtBankName.text,
      'bankIfscCode': txtBankIfscCode.text,
      'notes': txtNotes.text,
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

  void addBatch(int index) {
    txtCurrentBatch.add(TextEditingController());
    txtFromDate.add(TextEditingController());
    txtToDate.add(TextEditingController());
    txtBatchEffectiveOn.add(TextEditingController());
    txtTotalQtyAllotted.add(TextEditingController());
    txtLossQtyTillDate.add(TextEditingController());
    txtReason.add(TextEditingController());
    Widget newColumn = Container(
      color: Colors.grey.withOpacity(0.2),
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () {
              if (batches.length != 1) {
                setState(() {
                  batches.removeAt(index);
                  txtCurrentBatch.removeAt(index);
                  txtFromDate.removeAt(index);
                  txtToDate.removeAt(index);
                  txtBatchEffectiveOn.removeAt(index);
                  txtTotalQtyAllotted.removeAt(index);
                  txtLossQtyTillDate.removeAt(index);
                });
              }
            },
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.red,
            ),
          ),
          TextField(
            controller: txtCurrentBatch[index],
            enabled: isAdmin,
            decoration: const InputDecoration(hintText: 'Current Batch'),
          ),
          TextField(
            controller: txtFromDate[index],
            enabled: isAdmin,
            decoration: const InputDecoration(hintText: 'From Date'),
          ),
          TextField(
            controller: txtToDate[index],
            enabled: isAdmin,
            decoration: const InputDecoration(hintText: 'To Date'),
          ),
          TextField(
            controller: txtBatchEffectiveOn[index],
            enabled: isAdmin,
            decoration: const InputDecoration(hintText: 'Batch effective on'),
          ),
          TextField(
            controller: txtTotalQtyAllotted[index],
            enabled: isAdmin || txtTotalQtyAllotted[index].text == '',
            decoration:
                const InputDecoration(hintText: 'Total quantity allotted'),
          ),
          TextField(
            controller: txtLossQtyTillDate[index],
            enabled: isAdmin || txtLossQtyTillDate[index].text == '',
            decoration:
                const InputDecoration(hintText: 'Loss quantity till date'),
          ),
          TextField(
            controller: txtReason[index],
            enabled: isAdmin || txtReason[index].text == '',
            decoration:
                const InputDecoration(hintText: 'Reason for loss quantity'),
          ),
        ],
      ),
    );
    setState(() {
      batches.add(newColumn);
    });
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
                decoration: const InputDecoration(hintText: 'Enter name'),
              ),
              TextField(
                controller: txtNumber,
                enabled: isAdmin,
                decoration:
                    const InputDecoration(hintText: 'Enter mobile number'),
              ),
              TextField(
                controller: txtEmail,
                enabled: isAdmin,
                decoration: const InputDecoration(hintText: 'Enter email'),
              ),
              TextField(
                controller: txtLocation,
                enabled: isAdmin,
                decoration: const InputDecoration(hintText: 'Enter location'),
              ),
              TextField(
                controller: txtPanNo,
                enabled: isAdmin,
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
                      if(isAdmin){
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
                      if(isAdmin){
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
              SizedBox(
                height: 10,
              ),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text('Batches'),
                      IconButton(
                        onPressed: () {
                          addBatch(batches.length);
                        },
                        icon: const Icon(Icons.add_rounded),
                      ),
                    ],
                  ),
                  Column(
                    children: batches,
                  )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: txtBankAccNumber,
                enabled: isAdmin,
                decoration:
                    const InputDecoration(hintText: 'Bank account number'),
              ),
              TextField(
                controller: txtBankName,
                enabled: isAdmin,
                decoration: const InputDecoration(hintText: 'Bank name'),
              ),
              TextField(
                controller: txtBankIfscCode,
                enabled: isAdmin,
                decoration: const InputDecoration(hintText: 'Bank IFSC code'),
              ),
              TextField(
                controller: txtNotes,
                decoration: const InputDecoration(hintText: 'Notes'),
              ),
              Visibility(
                visible: isAdmin,
                child: DropdownButton<String>(
                  hint: const Text('Select employee'),
                  value: dropDownValue == '' ? null : dropDownValue,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_downward),
                  elevation: 16,
                  onChanged: (String? newValue) {
                    setState(() {
                      dropDownValue = newValue!;
                      employeeCode =
                          newValue.substring(0, newValue.indexOf('-'));
                    });
                  },
                  items:
                      employees.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
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
