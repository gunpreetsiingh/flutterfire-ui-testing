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
import 'package:intl/intl.dart';

class NewBatch extends StatefulWidget {
  bool edit;
  String docId, batchCode;
  BatchDataModel batchDataModel;
  NewBatch(this.batchCode, this.edit, this.docId, this.batchDataModel,
      {Key? key})
      : super(key: key);

  @override
  _NewBatchState createState() => _NewBatchState();
}

class _NewBatchState extends State<NewBatch> {
  var txtName = TextEditingController();
  var txtQty = TextEditingController();
  var txtSCC = TextEditingController();
  var txtSFC = TextEditingController();
  var txtACC = TextEditingController();
  var txtAFC = TextEditingController();
  var txtCons = TextEditingController();
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
        code = widget.batchCode;
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
      txtSCC.text = widget.batchDataModel.scc!;
      txtSFC.text = widget.batchDataModel.sfc!;
      txtACC.text = widget.batchDataModel.acc!;
      txtAFC.text = widget.batchDataModel.afc!;
      txtCons.text = widget.batchDataModel.cons!;
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
      'qty': txtQty.text == '' ? '0' : txtQty.text,
      'fromDate': txtFromDate == 'Enter from date'
          ? DateFormat('yyyy-MM-dd').format(DateTime.now())
          : txtFromDate,
      'endingDate': txtEndingDate == 'Enter ending date'
          ? DateFormat('yyyy-MM-dd')
              .format(DateTime.now().add(const Duration(days: 46)))
          : txtEndingDate,
      'employee': employeeCode,
      'scc': txtSCC.text == '' ? '0' : txtSCC.text,
      'sfc': txtSFC.text == '' ? '0' : txtSFC.text,
      'acc': txtACC.text == '' ? '0' : txtACC.text,
      'afc': txtAFC.text == '' ? '0' : txtAFC.text,
      'cons': txtCons.text == '' ? '0' : txtCons.text,
    });
    Navigator.of(context).pop(true);
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
                style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                    fontSize: 22),
                decoration:
                    const InputDecoration(labelText: 'Enter batch name'),
              ),
              const SizedBox(
                height: 10,
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
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: txtQty,
                enabled: isAdmin,
                style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                    fontSize: 22),
                decoration: const InputDecoration(labelText: 'Enter qty'),
              ),
              const SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: () async {
                  var result = await showDatePicker(
                      context: context,
                      initialDate: DateTime.parse(
                          txtFromDate == 'Enter from date'
                              ? DateTime.now().toString()
                              : txtFromDate),
                      firstDate: DateTime(2200),
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
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Text(
                    txtFromDate,
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: () async {
                  var result = await showDatePicker(
                      context: context,
                      initialDate: DateTime.parse(
                          txtEndingDate == 'Enter ending date'
                              ? DateTime.now().toString()
                              : txtEndingDate),
                      firstDate: DateTime(2200),
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
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Text(
                    txtEndingDate,
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
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
                height: 10,
              ),
              TextField(
                controller: txtSCC,
                enabled: isAdmin,
                style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                    fontSize: 22),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Enter SCC'),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: txtSFC,
                enabled: isAdmin,
                style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                    fontSize: 22),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Enter SFC'),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: txtACC,
                enabled: isAdmin,
                style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                    fontSize: 22),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Enter ACC'),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: txtAFC,
                enabled: isAdmin,
                style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                    fontSize: 22),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Enter AFC'),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: txtCons,
                enabled: isAdmin,
                style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                    fontSize: 22),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Enter Cons (%)'),
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
