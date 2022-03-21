import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';

class NewSaleEntry extends StatefulWidget {
  String batchCode;
  NewSaleEntry(this.batchCode, {Key? key}) : super(key: key);

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
    date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (isAdmin) {
      eCode = 'E001';
      eName = 'Admin';
    } else {
      eCode = colEmployee.docs.first['code'];
      eName = colEmployee.docs.first['name'];
    }
    setState(() {
      isLoading = false;
    });
  }

  void saveSalesEntry() {
    FirebaseFirestore.instance.collection('sales').doc().set({
      'batch': widget.batchCode,
      'date': date,
      'salesNos': txtSalesNos.text,
      'sales': txtSales.text,
      'dcNo': txtDcNo.text,
      'purchaser': txtPurchaser.text,
      'employee': '$eCode-$eName',
      'remarks': txtRemarks.text,
    });
    Navigator.of(context).pop();
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
                            date = result
                                .toString()
                                .substring(0, result.toString().indexOf(' '));
                          });
                        }
                      },
                      child: Text(
                        'Date: $date',
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
                    TextField(
                      controller: txtRemarks,
                      decoration:
                          const InputDecoration(labelText: 'Enter remarks'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}