import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui_testing/batch_data_model.dart';
import 'package:flutterfire_ui_testing/main.dart';
import 'package:flutterfire_ui_testing/view_image.dart';
import 'package:image_picker/image_picker.dart';

class NewBatch extends StatefulWidget {
  bool edit;
  String docId;
  BatchDataModel batchDataModel;
  NewBatch(this.edit, this.docId, this.batchDataModel, {Key? key})
      : super(key: key);

  @override
  _NewBatchState createState() => _NewBatchState();
}

class _NewBatchState extends State<NewBatch> {
  var txtName = TextEditingController();
  var txtQty = TextEditingController();
  String txtFromDate = 'Enter from date';
  String txtEndingDate = 'Enter ending date';
  var txtEmployee = TextEditingController();
  String dropDownValue = '',
      farmerDropDownValue = '',
      code = '',
      employeeCode = '',
      fCode = '',
      fName = '';
  bool isAdmin =
      FirebaseAuth.instance.currentUser!.email == 'qg.rickfeed@gmail.com';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (!widget.edit) {
      setState(() {
        code = 'B' + generateRandomCode();
      });
    } else {
      prepare();
    }
  }

  void prepare() {
    setState(() {
      code = widget.batchDataModel.code!;
      txtName.text = widget.batchDataModel.name!;
      fCode = widget.batchDataModel.farmerCode!;
      fName = widget.batchDataModel.farmerName!;
      txtQty.text = widget.batchDataModel.qty!;
      txtFromDate = widget.batchDataModel.fromDate!;
      txtEndingDate = widget.batchDataModel.endingDate!;
      txtEmployee.text = widget.batchDataModel.employee!;
      employees.forEach((element) {
        if (element.startsWith(employeeCode)) {
          dropDownValue = element;
        }
      });
    });
  }

  void saveEditBatch() {
    FirebaseFirestore.instance.collection('batches').doc(code).set({
      'code': code,
      'name': txtName.text,
      'farmerCode': fCode,
      'farmerName': fName,
      'qty': txtQty.text,
      'fromDate': txtFromDate,
      'endingDate': txtEndingDate,
      'employee': employeeCode,
    });
    Navigator.of(context).pop();
  }

  String generateRandomCode() {
    int num = Random().nextInt(10000);
    return num.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.edit ? 'Edit batch' : 'Add new batch',
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          saveEditBatch();
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
              TextField(
                controller: txtName,
                enabled: isAdmin,
                decoration: const InputDecoration(hintText: 'Enter batch name'),
              ),
              Visibility(
                visible: isAdmin,
                child: DropdownButton<String>(
                  hint: const Text('Select farmer'),
                  value: farmerDropDownValue == '' ? null : farmerDropDownValue,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_downward),
                  elevation: 16,
                  onChanged: (String? newValue) {
                    setState(() {
                      farmerDropDownValue = newValue!;
                      fName = farmerDropDownValue;
                      fCode = newValue.substring(0, newValue.indexOf('-'));
                    });
                  },
                  items: farmers.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              TextField(
                controller: txtQty,
                enabled: isAdmin,
                decoration: const InputDecoration(hintText: 'Enter qty'),
              ),
              GestureDetector(
                onTap: () async {
                  var result = await showDatePicker(
                      context: context,
                      initialDate: DateTime.parse(
                          txtFromDate == 'Enter from date'
                              ? DateTime.now().toString()
                              : txtFromDate),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100));
                  if (result != null) {
                    setState(() {
                      txtFromDate = result
                          .toString()
                          .substring(0, result.toString().indexOf(' '));
                    });
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    txtFromDate,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  var result = await showDatePicker(
                      context: context,
                      initialDate: DateTime.parse(
                          txtEndingDate == 'Enter ending date'
                              ? DateTime.now().toString()
                              : txtEndingDate),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100));
                  if (result != null) {
                    setState(() {
                      txtEndingDate = result
                          .toString()
                          .substring(0, result.toString().indexOf(' '));
                    });
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    txtEndingDate,
                  ),
                ),
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
                      employeeCode = newValue;
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
