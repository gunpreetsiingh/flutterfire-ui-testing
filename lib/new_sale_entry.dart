import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui_testing/main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';

class NewSaleEntry extends StatefulWidget {
  bool update;
  String docId, batchCode;
  String? date, salesNos, sales, dcNo, purchaser, employee, remarks, category;
  NewSaleEntry({
    required this.update,
    required this.docId,
    required this.batchCode,
    this.date,
    this.salesNos,
    this.sales,
    this.dcNo,
    this.purchaser,
    this.employee,
    this.remarks,
    this.category,
  });

  @override
  State<NewSaleEntry> createState() => _NewSaleEntryState();
}

class _NewSaleEntryState extends State<NewSaleEntry> {
  var txtSalesNos = TextEditingController();
  var txtSales = TextEditingController();
  var txtDcNo = TextEditingController();
  var txtPurchaser = TextEditingController();
  var txtRemarks = TextEditingController();
  String date = '', eCode = '', eName = '';
  bool isLoading = true;
  bool isAdmin =
      FirebaseAuth.instance.currentUser!.email == 'qg.rickfeed@gmail.com';
  String dropDownValue = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
  }

  void loadData() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot colEmployee = await FirebaseFirestore.instance
        .collection('employees')
        .where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email!)
        .get();
    date = DateFormat('yyyy-MM-dd hh:mm:ss a').format(DateTime.now());
    if (isAdmin) {
      eCode = 'E001';
      eName = 'Admin';
    } else {
      eCode = colEmployee.docs.first['code'];
      eName = colEmployee.docs.first['name'];
    }
    if (widget.update) {
      prepare();
    }
    setState(() {
      isLoading = false;
    });
  }

  void prepare() {
    setState(() {
      date = widget.date!;
      txtSalesNos.text = widget.salesNos!;
      txtSales.text = widget.sales!;
      txtDcNo.text = widget.dcNo!;
      txtPurchaser.text = widget.purchaser!;
      eCode = widget.employee!.substring(0, 4);
      eName = widget.employee!.substring(5, widget.employee!.length);
      txtRemarks.text = widget.remarks!;
      dropDownValue = widget.category!;
    });
  }

  void saveSalesEntry() {
    FirebaseFirestore.instance
        .collection('sales')
        .doc(widget.update ? widget.docId : null)
        .set({
      'batch': widget.batchCode,
      'date': date,
      'salesNos': txtSalesNos.text,
      'sales': txtSales.text,
      'dcNo': txtDcNo.text,
      'purchaser': txtPurchaser.text,
      'employee': '$eCode-$eName',
      'remarks': txtRemarks.text,
      'category': dropDownValue,
    });
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'Add new sales entry',
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {
          saveSalesEntry();
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
                              initialDate: DateTime.parse(date == ''
                                  ? DateTime.now().toString()
                                  : date.substring(0, date.indexOf(' '))),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100));
                          if (result != null) {
                            setState(() {
                              date = DateFormat('yyyy-MM-dd').format(result) +
                                  ' ' +
                                  DateFormat('hh:mm:ss a')
                                      .format(DateTime.now());
                            });
                          }
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          'Date: $date',
                        ),
                      ),
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
                    TextField(
                      controller: txtSalesNos,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Enter sales nos (Kg)'),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    TextField(
                      controller: txtSales,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'Enter sales (Kg)'),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    TextField(
                      controller: txtDcNo,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'Enter DC no'),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    TextField(
                      controller: txtPurchaser,
                      decoration:
                          const InputDecoration(labelText: 'Enter purchaser'),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    SizedBox(
                      height: 100,
                      child: TextField(
                        controller: txtRemarks,
                        maxLines: 10,
                        decoration:
                            const InputDecoration(labelText: 'Enter remarks'),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    DropdownButton<String>(
                      hint: const Text('Select category'),
                      value: dropDownValue == '' ? null : dropDownValue,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_downward),
                      elevation: 16,
                      onChanged: (String? newValue) {
                        setState(() {
                          dropDownValue = newValue!;
                        });
                      },
                      items: categories
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
