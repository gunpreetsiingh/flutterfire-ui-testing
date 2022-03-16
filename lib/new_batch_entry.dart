import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';

class NewBatchEntry extends StatefulWidget {
  String batchCode;
  NewBatchEntry(this.batchCode, {Key? key}) : super(key: key);

  @override
  State<NewBatchEntry> createState() => _NewBatchEntryState();
}

class _NewBatchEntryState extends State<NewBatchEntry> {
  var txtLossQty = TextEditingController();
  var txtRemarks = TextEditingController();
  var txtMedicineAdvice = TextEditingController();
  var txtFeedIntake = TextEditingController();
  var txtWeight = TextEditingController();
  var txtFeedToOrder = TextEditingController();
  var txtSalesNos = TextEditingController();
  var txtSales = TextEditingController();
  var txtDcNo = TextEditingController();
  var txtPurchaser = TextEditingController();
  double mortalityTillDate = 0;
  bool isLoading = true;
  String eCode = '', eName = '', location = '', date = '', reason = '';
  List<String> reasons = [], photos = [];
  var picker = ImagePicker(), _imageFile;
  Location locationObject = new Location();
  late LocationData _locationData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadMortality();
  }

  Future pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      uploadImageToFirebase();
    }
  }

  Future uploadImageToFirebase() async {
    String fileName = _imageFile.path.substring(
        _imageFile.path.lastIndexOf('/') + 1, _imageFile.path.length);
    Reference firebaseStorageRef =
        FirebaseStorage.instance.ref().child(fileName);
    UploadTask uploadTask = firebaseStorageRef.putFile(_imageFile);
    TaskSnapshot taskSnapshot = await uploadTask;
    taskSnapshot.ref.getDownloadURL().then(
      (value) {
        setState(() {
          photos.add(value);
        });
      },
    );
  }

  void loadMortality() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot colEmployee = await FirebaseFirestore.instance
        .collection('employees')
        .where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email!)
        .get();
    QuerySnapshot colBatches = await FirebaseFirestore.instance
        .collection('entries')
        .where('batch', isEqualTo: widget.batchCode)
        .get();
    colBatches.docs.forEach((element) {
      mortalityTillDate += double.parse(element['lossQty']);
    });
    QuerySnapshot colReasons =
        await FirebaseFirestore.instance.collection('reasons').get();
    colReasons.docs.forEach((element) {
      reasons.add(element['reason']);
    });
    date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    eCode = colEmployee.docs.first['code'];
    eName = colEmployee.docs.first['name'];
    _locationData = await locationObject.getLocation();
    location = '${_locationData.latitude}, ${_locationData.longitude}';
    setState(() {
      isLoading = false;
    });
  }

  void saveBatchEntry() {
    FirebaseFirestore.instance.collection('entries').doc().set({
      'batch': widget.batchCode,
      'employee': eCode + '-' + eName,
      'location': location,
      'date': date,
      'lossQty': txtLossQty.text,
      'reason': reason,
      'remarks': txtRemarks.text,
      'photos': photos,
      'medicineAdvice': txtMedicineAdvice.text,
      'feedIntake': txtFeedIntake.text,
      'weight': txtWeight.text,
      'mortalityTillDate': mortalityTillDate.toString(),
      'feedToOrder': txtFeedToOrder.text,
      'salesNos': txtSalesNos.text,
      'sales': txtSales.text,
      'dcNo': txtDcNo.text,
      'purchaser': txtPurchaser.text,
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add new batch entry',
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          saveBatchEntry();
        },
        child: const Icon(
          Icons.done_rounded,
          color: Colors.white,
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      'Date: $date',
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      'Employee Code: $eCode',
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      'Employee Name: $eName',
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      'Location: $location',
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    TextField(
                      controller: txtLossQty,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(hintText: 'Enter loss qty'),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    DropdownButton<String>(
                      hint: const Text('Select reason for loss qty'),
                      value: reason == '' ? null : reason,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_downward),
                      elevation: 16,
                      onChanged: (String? newValue) {
                        setState(() {
                          reason = newValue!;
                        });
                      },
                      items:
                          reasons.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    TextField(
                      controller: txtRemarks,
                      decoration:
                          const InputDecoration(hintText: 'Enter remarks'),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text('Photos'),
                        IconButton(
                            onPressed: pickImage,
                            icon: const Icon(Icons.add_a_photo_outlined))
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: photos.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(right: 10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                photos[index],
                                fit: BoxFit.cover,
                                height: 50,
                                width: 50,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    TextField(
                      controller: txtMedicineAdvice,
                      decoration: const InputDecoration(
                          hintText: 'Enter medicine advice'),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    TextField(
                      controller: txtFeedIntake,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          hintText: 'Enter feed intake (Kg)'),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    TextField(
                      controller: txtWeight,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(hintText: 'Enter weight (Kg)'),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text('Mortality Till Date: $mortalityTillDate'),
                    const SizedBox(
                      height: 5,
                    ),
                    TextField(
                      controller: txtFeedToOrder,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          hintText: 'Enter feed to order (Kg)'),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    TextField(
                      controller: txtSalesNos,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          hintText: 'Enter sales nos (Kg)'),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    TextField(
                      controller: txtSales,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(hintText: 'Enter sales (Kg)'),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    TextField(
                      controller: txtDcNo,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(hintText: 'Enter DC no'),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    TextField(
                      controller: txtPurchaser,
                      decoration:
                          const InputDecoration(hintText: 'Enter purchaser'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
