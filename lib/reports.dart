import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';

class Reports extends StatefulWidget {
  const Reports({Key? key}) : super(key: key);

  @override
  State<Reports> createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  bool isLoading = false;

  void exportFarmers() async {
    var excel = Excel.createExcel();
    setState(() {
      isLoading = true;
    });
    QuerySnapshot colFarmers = await FirebaseFirestore.instance
        .collection('farmers')
        .orderBy('name')
        .get();
    Sheet sheetObject = excel['Sheet1'];
    List<String> data = [
      'S.No.',
      'Code',
      'Name',
      'Mobile Number',
      'E-Mail',
      'Location',
      'Pan No',
      'Pan Id',
      'Aadhaar No',
      'Aadhaar Id',
      'Bank Acc No',
      'Bank Name',
      'IFSC Code',
      'Notes'
    ];
    sheetObject.appendRow(data.map((e) => TextCellValue(e)).toList());
    int c = 1;
    colFarmers.docs.forEach((element) {
      List<String> data = [
        c.toString(),
        element['code'].toString(),
        element['name'].toString(),
        element['number'].toString(),
        element['email'].toString(),
        element['location'].toString(),
        element['panNo'].toString(),
        element['panId'].toString(),
        element['aadhaarNo'].toString(),
        element['aadhaarId'].toString(),
        element['bankAccNumber'].toString(),
        element['bankName'].toString(),
        element['bankIfscCode'].toString(),
        element['notes'].toString(),
      ];
      sheetObject.appendRow(data.map((e) => TextCellValue(e)).toList());
      c++;
    });
    var fileBytes = excel.save(fileName: "Rickfeed-Farmers.xlsx");
    setState(() {
      isLoading = false;
    });
  }

  void exportEmployees() async {
    var excel = Excel.createExcel();
    setState(() {
      isLoading = true;
    });
    QuerySnapshot colEmployees = await FirebaseFirestore.instance
        .collection('employees')
        .orderBy('name')
        .get();
    Sheet sheetObject = excel['Sheet1'];
    List<String> data = [
      'S.No.',
      'Code',
      'Name',
      'Mobile Number',
      'E-Mail',
      'Image',
      'Activated?',
    ];
    sheetObject.appendRow(data.map((e) => TextCellValue(e)).toList());
    int c = 1;
    colEmployees.docs.forEach((element) {
      List<String> data = [
        c.toString(),
        element['code'].toString(),
        element['name'].toString(),
        element['number'].toString(),
        element['email'].toString(),
        element['image'].toString(),
        element['activated'].toString(),
      ];
      sheetObject.appendRow(data.map((e) => TextCellValue(e)).toList());
      c++;
    });
    var fileBytes = excel.save(fileName: "Rickfeed-Employees.xlsx");
    setState(() {
      isLoading = false;
    });
  }

  void exportBatches() async {
    var excel = Excel.createExcel();
    setState(() {
      isLoading = true;
    });
    QuerySnapshot colBatches = await FirebaseFirestore.instance
        .collection('batches')
        .orderBy('fromDate')
        .get();
    Sheet sheetObject = excel['Sheet1'];
    List<String> data = [
      'S.No.',
      'Code',
      'Name',
      'Farmer',
      'Qty',
      'From Date',
      'Ending Date',
      'Employee',
      'SCC',
      'SFC',
      'ACC',
      'AFC',
      'Cons (%)',
    ];
    sheetObject.appendRow(data.map((e) => TextCellValue(e)).toList());
    int c = 1;
    colBatches.docs.forEach((element) {
      List<String> data = [
        c.toString(),
        element['code'].toString(),
        element['name'].toString(),
        element['farmerName'].toString(),
        element['qty'].toString(),
        element['fromDate'].toString(),
        element['endingDate'].toString(),
        element['employee'].toString(),
        element['scc'].toString(),
        element['sfc'].toString(),
        element['acc'].toString(),
        element['afc'].toString(),
        element['cons'].toString(),
      ];
      sheetObject.appendRow(data.map((e) => TextCellValue(e)).toList());
      c++;
    });
    var fileBytes = excel.save(fileName: "Rickfeed-Batches.xlsx");
    setState(() {
      isLoading = false;
    });
  }

  void exportVisits() async {
    var excel = Excel.createExcel();
    setState(() {
      isLoading = true;
    });
    QuerySnapshot colBatches = await FirebaseFirestore.instance
        .collection('entries')
        .orderBy('date')
        .get();
    Sheet sheetObject = excel['Sheet1'];
    List<String> data = [
      'S.No.',
      'Batch Code',
      'Employee',
      'Location',
      'Date',
      'Loss Qty',
      'Reason',
      'Remarks',
      'Photos',
      'Medicine Advice',
      'Feed Intake',
      'Weight',
      'Mortality Till Date',
      'Feed To Order',
    ];
    sheetObject.appendRow(data.map((e) => TextCellValue(e)).toList());
    int c = 1;
    colBatches.docs.forEach((element) {
      List<String> data = [
        c.toString(),
        element['batch'].toString(),
        element['employee'].toString(),
        element['location'].toString(),
        element['date'].toString(),
        element['lossQty'].toString(),
        element['reason'].toString(),
        element['remarks'].toString(),
        element['photos'].toString().replaceAll('[]', '').replaceAll(']', ''),
        element['medicineAdvice'].toString(),
        element['feedIntake'].toString(),
        element['weight'].toString(),
        element['mortalityTillDate'].toString(),
        element['feedToOrder'].toString(),
      ];
      sheetObject.appendRow(data.map((e) => TextCellValue(e)).toList());
      c++;
    });
    var fileBytes = excel.save(fileName: "Rickfeed-Visits.xlsx");
    setState(() {
      isLoading = false;
    });
  }

  void exportSales() async {
    var excel = Excel.createExcel();
    setState(() {
      isLoading = true;
    });
    QuerySnapshot colBatches = await FirebaseFirestore.instance
        .collection('sales')
        .orderBy('date')
        .get();
    Sheet sheetObject = excel['Sheet1'];
    List<String> data = [
      'S.No.',
      'Batch Code',
      'Date',
      'Sales Nos',
      'Sales',
      'DC No',
      'Purchaser',
      'Employee',
      'Remarks',
    ];
    sheetObject.appendRow(data.map((e) => TextCellValue(e)).toList());
    int c = 1;
    colBatches.docs.forEach((element) {
      List<String> data = [
        c.toString(),
        element['batch'].toString(),
        element['date'].toString(),
        element['salesNos'].toString(),
        element['sales'].toString(),
        element['dcNo'].toString(),
        element['purchaser'].toString(),
        element['employee'].toString(),
        element['remarks'].toString(),
      ];
      sheetObject.appendRow(data.map((e) => TextCellValue(e)).toList());
      c++;
    });
    var fileBytes = excel.save(fileName: "Rickfeed-Sales.xlsx");
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
      ),
      body: Container(
        padding: const EdgeInsets.all(15),
        alignment: Alignment.topCenter,
        child: isLoading
            ? const CircularProgressIndicator(
                color: Colors.blue,
              )
            : Wrap(
                alignment: WrapAlignment.center,
                runAlignment: WrapAlignment.center,
                spacing: 15,
                runSpacing: 15,
                children: [
                  TextButton(
                    onPressed: () {
                      if (!isLoading) {
                        exportFarmers();
                      }
                    },
                    child: const Text('Export Farmers'),
                  ),
                  TextButton(
                    onPressed: () {
                      if (!isLoading) {
                        exportEmployees();
                      }
                    },
                    child: const Text('Export Employees'),
                  ),
                  TextButton(
                    onPressed: () {
                      if (!isLoading) {
                        exportBatches();
                      }
                    },
                    child: const Text('Export Batches'),
                  ),
                  TextButton(
                    onPressed: () {
                      if (!isLoading) {
                        exportVisits();
                      }
                    },
                    child: const Text('Export Visits'),
                  ),
                  TextButton(
                    onPressed: () {
                      if (!isLoading) {
                        exportSales();
                      }
                    },
                    child: const Text('Export Sales'),
                  ),
                ],
              ),
      ),
    );
  }
}
