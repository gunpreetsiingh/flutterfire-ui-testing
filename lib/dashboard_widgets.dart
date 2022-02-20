import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui_testing/employee_listview.dart';
import 'package:flutterfire_ui_testing/farmers_listview.dart';
import 'package:flutterfire_ui_testing/main.dart';

class DashboardWidgets extends StatefulWidget {
  const DashboardWidgets({Key? key}) : super(key: key);

  @override
  _DashboardWidgetsState createState() => _DashboardWidgetsState();
}

class _DashboardWidgetsState extends State<DashboardWidgets> {
  late QuerySnapshot colFarmers, colEmployees;
  int totalFarmers = 0, unattendedFarmers = 0, totalEmployees = 0;
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
    // employees.add('Select employee');
    // employeesToken.add('Select employee token');
    employees.clear();
    employeesToken.clear();
    colEmployees.docs.forEach(
      (element) {
        employees.add(element['code'] + '-' + element['name']);
        employeesToken.add(element['token']);
      },
    );
    setState(() {
      totalFarmers = colFarmers.docs.length;
      totalEmployees = colEmployees.docs.length;
      colFarmers.docs.forEach((element) {
        if (!element['attended']) {
          unattendedFarmers++;
        }
      });
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
                    'Total Farmers',
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
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (contetx) => FarmersListView(true)));
            },
            child: Container(
              height: 107,
              width: 177,
              padding: const EdgeInsets.all(15),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Unattended Farmers',
                    style: TextStyle(
                      color: Colors.purple,
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
                              color: Colors.purple,
                              width: 2,
                            )),
                        child: const Icon(
                          Icons.people_outline_rounded,
                          color: Colors.purple,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        '$unattendedFarmers',
                        style: TextStyle(
                          color: Colors.purple,
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
                    'Total Employees',
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
        ],
      ),
    );
  }
}
