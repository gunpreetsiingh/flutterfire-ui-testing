import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui_testing/batches_listview.dart';
import 'package:flutterfire_ui_testing/employee_listview.dart';
import 'package:flutterfire_ui_testing/farmers_listview.dart';
import 'package:flutterfire_ui_testing/main.dart';

class DashboardWidgets extends StatefulWidget {
  const DashboardWidgets({Key? key}) : super(key: key);

  @override
  _DashboardWidgetsState createState() => _DashboardWidgetsState();
}

class _DashboardWidgetsState extends State<DashboardWidgets> {
  late QuerySnapshot colFarmers, colEmployees, colBatches;
  int totalFarmers = 0, totalEmployees = 0, totalBatches = 0;
  bool loadingData = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
  }

  void loadData() async {
    setState(() {
      loadingData = true;
    });
    colFarmers = await FirebaseFirestore.instance
        .collection('farmers')
        .orderBy('name')
        .get();
    colEmployees = await FirebaseFirestore.instance
        .collection('employees')
        .orderBy('name')
        .get();
    colBatches = await FirebaseFirestore.instance
        .collection('batches')
        .orderBy('name')
        .get();
    // employees.add('Select employee');
    // employeesToken.add('Select employee token');
    farmers.clear();
    colFarmers.docs.forEach(
      (element) {
        farmers.add(element['code'] + '-' + element['name']);
      },
    );
    employees.clear();
    employeesToken.clear();
    colEmployees.docs.forEach(
      (element) {
        employees.add(element['code'] + '-' + element['name']);
        employeesToken.add(element['token']);
      },
    );
    batches.clear();
    colBatches.docs.forEach(
      (element) {
        batches.add(element['code'] + '-' + element['name']);
      },
    );
    setState(() {
      totalFarmers = colFarmers.docs.length;
      totalEmployees = colEmployees.docs.length;
      totalBatches = colBatches.docs.length;
      loadingData = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loadingData)
      return const Center(
        child: CircularProgressIndicator(),
      );
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        runAlignment: WrapAlignment.center,
        spacing: 15,
        runSpacing: 15,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (contetx) => FarmersListView(false)));
            },
            child: Container(
              height: 107,
              width: 177,
              padding: const EdgeInsets.all(15),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Farmers',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.green,
                              width: 2,
                            )),
                        child: const Icon(
                          Icons.people_outline_rounded,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        '$totalFarmers',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (contetx) => EmployeeListView()));
            },
            child: Container(
              height: 107,
              width: 177,
              padding: const EdgeInsets.all(15),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Employees',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.orange,
                              width: 2,
                            )),
                        child: const Icon(
                          Icons.people_outline_rounded,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        '$totalEmployees',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (contetx) => BatchesListView()));
            },
            child: Container(
              height: 107,
              width: 177,
              padding: const EdgeInsets.all(15),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Batches',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.blue,
                              width: 2,
                            )),
                        child: const Icon(
                          Icons.article_outlined,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        '$totalBatches',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
