import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui_testing/new_batch_entry.dart';

class BatchEntries extends StatefulWidget {
  String batchId, qty, fromDate;
  BatchEntries(this.batchId, this.qty, this.fromDate, {Key? key})
      : super(key: key);

  @override
  State<BatchEntries> createState() => _BatchEntriesState();
}

class _BatchEntriesState extends State<BatchEntries> {
  bool isLoading = true;
  late QuerySnapshot colBatches;
  bool isAdmin =
      FirebaseAuth.instance.currentUser!.email == 'qg.rickfeed@gmail.com';

  @override
  void initState() {
    super.initState();
    loadBatchEntries();
  }

  void loadBatchEntries() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot colEmployee = await FirebaseFirestore.instance
        .collection('employees')
        .where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email!)
        .get();
    if (isAdmin) {
      colBatches = await FirebaseFirestore.instance.collection('entries').get();
    } else {
      colBatches = await FirebaseFirestore.instance
          .collection('entries')
          .where('employee',
              isEqualTo: colEmployee.docs.first['code'] +
                  '-' +
                  FirebaseAuth.instance.currentUser!.displayName)
          .get();
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Entries-${widget.fromDate} [Qty: ${widget.qty}]',
        ),
      ),
      floatingActionButton: isAdmin
          ? null
          : FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => NewBatchEntry(widget.batchId)));
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
          : SizedBox(
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
                        title: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Date: ${colBatches.docs[index]['date']}',
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
                              'Loss Qty: ${colBatches.docs[index]['lossQty']}',
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
                              'Till Date Mortality: ${colBatches.docs[index]['mortalityTillDate']}',
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
                              'Feed Intake: ${colBatches.docs[index]['feedIntake']}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            // const SizedBox(
                            //   height: 5,
                            // ),
                            // Text(
                            //   'Qty: ${colBatches.docs[index]['qty']}',
                            //   style: const TextStyle(
                            //     fontSize: 14,
                            //     fontWeight: FontWeight.bold,
                            //     color: Colors.grey,
                            //   ),
                            // ),
                            // Visibility(
                            //   visible: isAdmin,
                            //   child: const SizedBox(
                            //     height: 5,
                            //   ),
                            // ),
                            // Visibility(
                            //   visible: isAdmin,
                            //   child: Text(
                            //     'Employee: ${colBatches.docs[index]['employee']}',
                            //     style: const TextStyle(
                            //       fontSize: 14,
                            //       fontWeight: FontWeight.bold,
                            //       color: Colors.grey,
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    );
                  }),
            ),
    );
  }
}
