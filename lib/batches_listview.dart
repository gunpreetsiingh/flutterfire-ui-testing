import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui_testing/batch_data_model.dart';
import 'package:flutterfire_ui_testing/batch_entries.dart';
import 'package:flutterfire_ui_testing/new_batch.dart';

class BatchesListView extends StatefulWidget {
  BatchesListView({Key? key}) : super(key: key);

  @override
  _BatchesListViewState createState() => _BatchesListViewState();
}

class _BatchesListViewState extends State<BatchesListView> {
  late QuerySnapshot colBatches, colEntries;
  bool isLoading = true, isLoadingTotalValues = true, edit = false;
  String docId = '', employee = '';
  double totalFeedIntake = 0,
      totalFeedReceived = 0,
      totalMortalityTillDate = 0,
      recentWeight = 0;
  String recentDateWeight = '';
  double sc = 0, ac = 0;
  String newBatchCode = '';

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    setState(() {
      isLoading = true;
    });
    colBatches = await FirebaseFirestore.instance
        .collection('batches')
        .orderBy('code', descending: true)
        .get();
    if (colBatches.docs.isEmpty) {
      setState(() {
        newBatchCode = 'B10000';
      });
    } else {
      newBatchCode = 'B' +
          (int.parse(colBatches.docs.first['code']
                      .substring(1, colBatches.docs.first['code'].length)) +
                  1)
              .toString();
    }
    setState(() {
      isLoading = false;
    });
  }

  void loadTotalValues(int index) async {
    setState(() {
      isLoadingTotalValues = true;
      totalFeedIntake = 0;
      totalFeedReceived = 0;
      totalMortalityTillDate = 0;
      recentWeight = 0;
      recentDateWeight = '';
      sc = 0;
      ac = 0;
    });
    colEntries = await FirebaseFirestore.instance
        .collection('entries')
        .orderBy('date')
        .get();
    colEntries.docs.forEach((element) {
      if (element['batch'] == colBatches.docs[index]['code']) {
        totalFeedIntake += double.parse(element['feedIntake']);
        totalFeedReceived += double.parse(element['feedToOrder']);
        totalMortalityTillDate += double.parse(element['lossQty']);
        if (element['weight'] != '0') {
          recentWeight = double.parse(element['weight']) / 1000;
          recentDateWeight = element['date'];
        }
      }
    });
    var element = colBatches.docs[index];
    sc = (double.parse(element['scc']) * double.parse(element['qty'])) +
        (double.parse(element['sfc']) * totalFeedIntake);
    sc = sc /
        (recentWeight *
            double.parse(element['cons']) *
            (double.parse(element['qty']) - totalMortalityTillDate));
    ac = (double.parse(element['acc']) * double.parse(element['qty'])) +
        (double.parse(element['afc']) * totalFeedIntake);
    ac = ac /
        (recentWeight *
            double.parse(element['cons']) *
            (double.parse(element['qty']) - totalMortalityTillDate));
    sc = sc * 100;
    ac = ac * 100;
    setState(() {
      isLoadingTotalValues = false;
    });
    Navigator.of(context).pop();
    showEditOptions(index);
  }

  void showEditOptions(int index) {
    if (isLoadingTotalValues) {
      loadTotalValues(index);
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return Container(
            padding: const EdgeInsets.all(15),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Code: ${colBatches.docs[index]['code']}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Name: ${colBatches.docs[index]['name']}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Farmer Code: ${colBatches.docs[index]['farmerCode']}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Farmer Name: ${colBatches.docs[index]['farmerName']}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Qty: ${colBatches.docs[index]['qty']}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'SC: ${sc.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'AC: ${ac.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'From Date: ${colBatches.docs[index]['fromDate']}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Ending Date: ${colBatches.docs[index]['endingDate']}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const Divider(
                    color: Colors.black,
                  ),
                  isLoadingTotalValues
                      ? CircularProgressIndicator()
                      : Text(
                          'Total Feed Intake: ${totalFeedIntake.toStringAsFixed(4)}\nTotal Feed Received: ${totalFeedReceived.toStringAsFixed(4)}\nTotal Mortality Till Date: $totalMortalityTillDate\nWeight: $recentWeight Kg [$recentDateWeight]',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                  const Divider(
                    color: Colors.black,
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.of(context).pop();
                      setState(() {
                        docId = colBatches.docs[index].id;
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => NewBatch(
                              newBatchCode,
                              true,
                              docId,
                              BatchDataModel(
                                code: colBatches.docs[index]['code'],
                                name: colBatches.docs[index]['name'],
                                farmerCode: colBatches.docs[index]
                                    ['farmerCode'],
                                farmerName: colBatches.docs[index]
                                    ['farmerName'],
                                qty: colBatches.docs[index]['qty'],
                                fromDate: colBatches.docs[index]['fromDate'],
                                endingDate: colBatches.docs[index]
                                    ['endingDate'],
                                employee: colBatches.docs[index]['employee'],
                                scc: colBatches.docs[index]['scc'],
                                sfc: colBatches.docs[index]['sfc'],
                                acc: colBatches.docs[index]['acc'],
                                afc: colBatches.docs[index]['afc'],
                                cons: colBatches.docs[index]['cons'],
                              ),
                            ),
                          ),
                        );
                      });
                    },
                    leading: const Icon(
                      Icons.edit_rounded,
                      color: Colors.black,
                    ),
                    title: const Text(
                      'Edit batch details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Batches List',
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (!isLoading) {
            var response = await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    NewBatch(newBatchCode, false, '', BatchDataModel())));
            if (response) {
              loadData();
            }
          }
        },
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: const Text(
                      'Long press to edit batch details.',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height - 106,
                    child: ListView.builder(
                      itemCount: colBatches.docs.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(top: 10),
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.15),
                                  blurRadius: 5,
                                  spreadRadius: 5,
                                )
                              ]),
                          child: ListTile(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => BatchEntries(
                                      colBatches.docs[index]['code'],
                                      colBatches.docs[index]['qty'],
                                      colBatches.docs[index]['fromDate'])));
                            },
                            onLongPress: () {
                              setState(() {
                                isLoadingTotalValues = true;
                              });
                              showEditOptions(index);
                            },
                            title: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Code: ${colBatches.docs[index]['code']}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  'Batch: ${colBatches.docs[index]['name']}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  'Farmer Name: ${colBatches.docs[index]['farmerName']}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  'Employee: ${colBatches.docs[index]['employee']}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
