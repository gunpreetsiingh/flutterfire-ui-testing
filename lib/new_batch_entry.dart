import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui_testing/view_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';

class NewBatchEntry extends StatefulWidget {
  String batchCode;
  bool edit;
  Map data;
  NewBatchEntry(this.batchCode, this.edit, this.data, {Key? key})
      : super(key: key);

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
  double mortalityTillDate = 0;
  bool isLoading = true, isSaving = false;
  String eCode = '', eName = '', location = '', date = '', reason = '';
  List<String> reasons = [], photos = [];
  var picker = ImagePicker(), _imageFile;
  Location locationObject = new Location();
  late LocationData _locationData;
  bool isAdmin =
      FirebaseAuth.instance.currentUser!.email == 'qg.rickfeed@gmail.com';
  bool loadingAgain = false;
  late QuerySnapshot colEmployee;
  late QuerySnapshot colBatches;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.edit) {
      prefill();
      setState(() {
        isLoading = false;
      });
    } else {
      loadMortality();
    }
  }

  void prefill() async {
    QuerySnapshot colReasons =
        await FirebaseFirestore.instance.collection('reasons').get();
    colReasons.docs.forEach((element) {
      reasons.add(element['reason']);
    });
    setState(() {
      date = widget.data['date'].toString();
      txtLossQty.text = widget.data['lossQty'].toString();
      txtRemarks.text = widget.data['remarks'].toString();
      txtMedicineAdvice.text = widget.data['medicineAdvice'].toString();
      txtFeedIntake.text = widget.data['feedIntake'].toString();
      txtWeight.text = widget.data['weight'].toString();
      txtFeedToOrder.text = widget.data['feedToOrder'].toString();
      mortalityTillDate = double.parse(widget.data['mortalityTillDate']);
      eCode = widget.data['eCode'].toString();
      eName = widget.data['eName'].toString();
      location = widget.data['location'].toString();
      reason = widget.data['reason'].toString();
      widget.data['photos'].forEach((element) {
        photos.add(element);
      });
    });
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
      mortalityTillDate = 0;
    });
    if (!loadingAgain) {
      date = DateFormat('yyyy-MM-dd hh:mm:ss a').format(DateTime.now());
    }
    colEmployee = await FirebaseFirestore.instance
        .collection('employees')
        .where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email!)
        .get();
    colBatches = await FirebaseFirestore.instance
        .collection('entries')
        .where('batch', isEqualTo: widget.batchCode)
        .get();
    colBatches.docs.forEach((element) {
      if (DateTime.parse(date).isAfter(DateTime.parse(element['date']))) {
        mortalityTillDate += double.parse(element['lossQty']);
      }
    });
    reasons.clear();
    QuerySnapshot colReasons =
        await FirebaseFirestore.instance.collection('reasons').get();
    colReasons.docs.forEach((element) {
      reasons.add(element['reason']);
    });
    if (isAdmin) {
      eCode = 'E001';
      eName = 'Admin';
    } else {
      eCode = colEmployee.docs.first['code'];
      eName = colEmployee.docs.first['name'];
    }
    _locationData = await locationObject.getLocation();
    location = '${_locationData.latitude}, ${_locationData.longitude}';
    setState(() {
      isLoading = false;
    });
  }

  void saveBatchEntry() async {
    setState(() {
      isSaving = true;
    });
    bool proceed = true;
    if (!widget.edit) {
      QuerySnapshot colTodayEntry = await FirebaseFirestore.instance
          .collection('entries')
          .where('date',
              isEqualTo: DateTime.now())
          .get();
      colTodayEntry.docs.forEach((element) {
        if (element['batch'] == widget.batchCode) {
          if (proceed) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Colors.red,
              content: Text('There is already a visit entry for this date.'),
            ));
          }
          setState(() {
            proceed = false;
          });
          return;
        }
      });
    }
    if (proceed) {
      FirebaseFirestore.instance
          .collection('entries')
          .doc(widget.edit ? widget.data['code'] : null)
          .set({
        'batch': widget.batchCode,
        'employee': eCode + '-' + eName,
        'location': location,
        'date': date,
        'lossQty': txtLossQty.text == '' ? '0' : txtLossQty.text,
        'reason': reason,
        'remarks': txtRemarks.text,
        'photos': photos,
        'medicineAdvice': txtMedicineAdvice.text,
        'feedIntake': txtFeedIntake.text == '' ? '0' : txtFeedIntake.text,
        'weight': txtWeight.text == '' ? '0' : txtWeight.text,
        'mortalityTillDate':
            (mortalityTillDate + double.parse(txtLossQty.text)).toString(),
        'feedToOrder': txtFeedToOrder.text == '' ? '0' : txtFeedToOrder.text,
      });
    }
    setState(() {
      isSaving = false;
    });
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.edit ? 'Edit batch entry' : 'Add new batch entry',
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if(!isSaving) {
            saveBatchEntry();
          }
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
                    GestureDetector(
                      onTap: () async {
                        if (isAdmin) {
                          var result = await showDatePicker(
                              context: context,
                              initialDate: DateTime.parse(
                                  date == 'Enter ending date'
                                      ? DateTime.now().toString()
                                      : date),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100));
                          if (result != null) {
                            setState(() {
                              date = DateFormat('yyyy-MM-dd hh:mm:ss a')
                                  .format(result);
                            });
                            setState(() {
                              loadingAgain = true;
                            });
                            loadMortality();
                          }
                        }
                      },
                      child: Text(
                        'Date: $date',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      'Employee Code: $eCode',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      'Employee Name: $eName',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      'Location: $location',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    TextField(
                      controller: txtLossQty,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'Enter loss qty'),
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
                          const InputDecoration(labelText: 'Enter remarks'),
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
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  ViewImage(photos[index])));
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  photos[index],
                                  fit: BoxFit.cover,
                                  height: 50,
                                  width: 50,
                                ),
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
                          labelText: 'Enter medicine advice'),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    TextField(
                      controller: txtFeedIntake,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Enter feed intake (Kg)'),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    TextField(
                      controller: txtWeight,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Enter weight (grams)'),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      'Mortality Till Date: $mortalityTillDate',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    TextField(
                      controller: txtFeedToOrder,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText:
                              'Enter feed received (Kg)'), // feed to order
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
