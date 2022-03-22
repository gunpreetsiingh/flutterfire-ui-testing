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
    sheetObject.appendRow(data);
    int c = 1;
    colFarmers.docs.forEach((element) {
      List<String> data = [
        c.toString(),
        element['code'],
        element['name'],
        element['number'],
        element['email'],
        element['location'],
        element['panNo'],
        element['panId'],
        element['aadhaarNo'],
        element['aadhaarId'],
        element['bankAccNumber'],
        element['bankName'],
        element['bankIfscCode'],
        element['notes'],
      ];
      sheetObject.appendRow(data);
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
    sheetObject.appendRow(data);
    int c = 1;
    colEmployees.docs.forEach((element) {
      List<String> data = [
        c.toString(),
        element['code'],
        element['name'],
        element['number'],
        element['email'],
        element['image'],
        element['activated'].toString(),
      ];
      sheetObject.appendRow(data);
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
        .orderBy('name')
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
    sheetObject.appendRow(data);
    int c = 1;
    colBatches.docs.forEach((element) {
      List<String> data = [
        c.toString(),
        element['code'],
        element['name'],
        element['farmerName'],
        element['qty'],
        element['fromDate'],
        element['endingDate'],
        element['employee'],
        element['scc'],
        element['sfc'],
        element['acc'],
        element['afc'],
        element['cons'],
      ];
      sheetObject.appendRow(data);
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
    sheetObject.appendRow(data);
    int c = 1;
    colBatches.docs.forEach((element) {
      List<String> data = [
        c.toString(),
        element['batch'],
        element['employee'],
        element['location'],
        element['date'],
        element['lossQty'],
        element['reason'],
        element['remarks'],
        element['photos'].toString().replaceAll('[]', '').replaceAll(']', ''),
        element['medicineAdvice'],
        element['feedIntake'],
        element['weight'],
        element['mortalityTillDate'],
        element['feedToOrder'],
      ];
      sheetObject.appendRow(data);
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
    sheetObject.appendRow(data);
    int c = 1;
    colBatches.docs.forEach((element) {
      List<String> data = [
        c.toString(),
        element['batch'],
        element['date'],
        element['salesNos'],
        element['sales'],
        element['dcNo'],
        element['purchaser'],
        element['employee'],
        element['remarks'],
      ];
      sheetObject.appendRow(data);
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
        ? const CircularProgressIndicator(color: Colors.blue,)
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
