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
  late QuerySnapshot colBatches;
  bool isLoading = true, edit = false;
  String docId = '', employee = '';

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
        .orderBy('name')
        .get();
    setState(() {
      isLoading = false;
    });
  }

  void showEditOptions(int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
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
                    color: Colors.grey,
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
                    color: Colors.grey,
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
                    color: Colors.grey,
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
                    color: Colors.grey,
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
                    color: Colors.grey,
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
                    color: Colors.grey,
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
                    color: Colors.grey,
                  ),
                ),
                const Divider(
                  color: Colors.grey,
                ),
                ListTile(
                  onTap: () {
                    Navigator.of(context).pop();
                    setState(() {
                      docId = colBatches.docs[index].id;
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => NewBatch(
                            true,
                            docId,
                            BatchDataModel(
                              code: colBatches.docs[index]['code'],
                              name: colBatches.docs[index]['name'],
                              farmerCode: colBatches.docs[index]['farmerCode'],
                              farmerName: colBatches.docs[index]['farmerName'],
                              qty: colBatches.docs[index]['qty'],
                              fromDate: colBatches.docs[index]['fromDate'],
                              endingDate: colBatches.docs[index]['endingDate'],
                              employee: colBatches.docs[index]['employee'],
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
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => NewBatch(false, '', BatchDataModel())));
        },
        child: const Icon(
          Icons.person_add_alt_1_outlined,
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
                        color: Colors.grey,
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
                              Navigator.of(context).push(MaterialPageRoute(builder: (context) => BatchEntries(colBatches.docs[index]['code'], colBatches.docs[index]['qty'], colBatches.docs[index]['fromDate'])));
                            },
                            onLongPress: () {
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
                                    color: Colors.grey,
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
                                    color: Colors.grey,
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
                                    color: Colors.grey,
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
                                    color: Colors.grey,
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
