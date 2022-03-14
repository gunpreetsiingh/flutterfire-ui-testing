import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BatchEntries extends StatefulWidget {
  String batchId;
  BatchEntries(this.batchId, {Key? key}) : super(key: key);

  @override
  State<BatchEntries> createState() => _BatchEntriesState();
}

class _BatchEntriesState extends State<BatchEntries> {
  bool isLoading = true;
  late QuerySnapshot colBatches;

  void loadBatchEntries() async {
    setState(() {
      isLoading = false;
    });
    QuerySnapshot colEmployee = await FirebaseFirestore.instance
        .collection('employees')
        .where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email!)
        .get();
    colBatches = await FirebaseFirestore.instance
        .collection('entries')
        .where('employee', isEqualTo: colEmployee.docs.first['code'] + '-' + FirebaseAuth.instance.currentUser!.displayName)
        .get();
    setState(() {
      isLoading = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Batch entries',
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
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
                  if (colBatches.docs[index]['employee'] == '' || true) {
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
                                  colBatches.docs[index]['code'])));
                        },
                        title: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Batch Name: ${colBatches.docs[index]['name']}',
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
                              'Qty: ${colBatches.docs[index]['qty']}',
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
                  }
                },
              ),
            ),
    );
  }
}
