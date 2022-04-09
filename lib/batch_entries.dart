import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui_testing/new_batch_entry.dart';
import 'package:flutterfire_ui_testing/new_sale_entry.dart';

class BatchEntries extends StatefulWidget {
  String batchId, qty, fromDate, farmerName;
  DocumentSnapshot docBatch;
  BatchEntries(
      this.batchId, this.qty, this.fromDate, this.farmerName, this.docBatch,
      {Key? key})
      : super(key: key);

  @override
  State<BatchEntries> createState() => _BatchEntriesState();
}

class _BatchEntriesState extends State<BatchEntries> {
  bool isLoading = true, isLoadingTotalValues = true;
  late QuerySnapshot colVisits, colSales;
  bool isAdmin =
      FirebaseAuth.instance.currentUser!.email == 'qg.rickfeed@gmail.com';

  double totalFeedIntake = 0,
      totalFeedReceived = 0,
      totalMortalityTillDate = 0,
      recentWeight = 0;
  String recentDateWeight = '';
  double sc = 0, ac = 0;

  late QuerySnapshot colEntries;

  @override
  void initState() {
    super.initState();
    loadBatchEntries();
    loadTotalValues();
  }

  void loadBatchEntries() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot colEmployee = await FirebaseFirestore.instance
        .collection('employees')
        .where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email!)
        .get();
    colVisits = await FirebaseFirestore.instance
        .collection('entries')
        .orderBy('date', descending: true)
        .get();
    colSales = await FirebaseFirestore.instance
        .collection('sales')
        .orderBy('date', descending: true)
        .get();
    setState(() {
      isLoading = false;
    });
  }

  void loadTotalValues() async {
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
      if (element['batch'] == widget.batchId) {
        totalFeedIntake += double.parse(element['feedIntake']);
        totalFeedReceived += double.parse(element['feedToOrder']);
        totalMortalityTillDate += double.parse(element['lossQty']);
        if (element['weight'] != '0') {
          recentWeight = double.parse(element['weight']) / 1000;
          recentDateWeight = element['date'];
        }
      }
    });
    var element = widget.docBatch;
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Entries-${widget.fromDate} [Qty: ${widget.qty}]',
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: () async {
              var response = await Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      NewBatchEntry(widget.batchId, false, {})));
              if (response) {
                loadBatchEntries();
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                ),
                Text('Visit')
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          FloatingActionButton(
            backgroundColor: Colors.green,
            onPressed: () async {
              var response = await Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => NewSaleEntry(widget.batchId)));
              if (response) {
                loadBatchEntries();
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                ),
                Text('Sales')
              ],
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              height: MediaQuery.of(context).size.height - 106,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: DefaultTabController(
                length: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      color: Colors.black,
                      padding: const EdgeInsets.all(10),
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Batch Code: ${widget.batchId}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Farmer Name: ${widget.farmerName}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          isLoadingTotalValues
                              ? CircularProgressIndicator()
                              : Text(
                                  'Total Feed Intake: ${totalFeedIntake.toStringAsFixed(4)}\nTotal Feed Received: ${totalFeedReceived.toStringAsFixed(4)}\nTotal Mortality Till Date: $totalMortalityTillDate\nWeight: $recentWeight Kg [$recentDateWeight]',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const TabBar(
                      tabs: [
                        Tab(
                          child: Text(
                            'Visits',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                        Tab(
                          child: Text(
                            'Sales',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height - 302,
                      child: TabBarView(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            child: ListView.builder(
                                itemCount: colVisits.docs.length,
                                itemBuilder: (context, index) {
                                  if (colVisits.docs[index]['batch'] !=
                                      widget.batchId) return Container();
                                  return GestureDetector(
                                    onTap: () async {
                                      if (isAdmin) {
                                        var response = await Navigator.of(
                                                context)
                                            .push(MaterialPageRoute(
                                                builder: (context) =>
                                                    NewBatchEntry(
                                                        widget.batchId, true, {
                                                      'code': colVisits
                                                          .docs[index].id,
                                                      'date': colVisits
                                                          .docs[index]['date'],
                                                      'lossQty':
                                                          colVisits.docs[index]
                                                              ['lossQty'],
                                                      'remarks':
                                                          colVisits.docs[index]
                                                              ['remarks'],
                                                      'medicineAdvice':
                                                          colVisits.docs[index][
                                                              'medicineAdvice'],
                                                      'feedIntake':
                                                          colVisits.docs[index]
                                                              ['feedIntake'],
                                                      'weight':
                                                          colVisits.docs[index]
                                                              ['weight'],
                                                      'feedToOrder':
                                                          colVisits.docs[index]
                                                              ['feedToOrder'],
                                                      'mortalityTillDate':
                                                          colVisits.docs[index][
                                                              'mortalityTillDate'],
                                                      'eCode': colVisits
                                                          .docs[index]
                                                              ['employee']
                                                          .toString()
                                                          .substring(
                                                              0,
                                                              colVisits
                                                                  .docs[index][
                                                                      'employee']
                                                                  .toString()
                                                                  .indexOf(
                                                                      '-')),
                                                      'eName': colVisits
                                                          .docs[index]
                                                              ['employee']
                                                          .toString()
                                                          .substring(
                                                              colVisits.docs[
                                                                          index]
                                                                          [
                                                                          'employee']
                                                                      .toString()
                                                                      .indexOf(
                                                                          '-') +
                                                                  1,
                                                              colVisits
                                                                  .docs[index][
                                                                      'employee']
                                                                  .toString()
                                                                  .length),
                                                      'location':
                                                          colVisits.docs[index]
                                                              ['location'],
                                                      'reason':
                                                          colVisits.docs[index]
                                                              ['reason'],
                                                      'photos':
                                                          colVisits.docs[index]
                                                              ['photos'],
                                                    })));
                                        if (response) {
                                          loadBatchEntries();
                                        }
                                      }
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(top: 10),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.15),
                                              blurRadius: 5,
                                              spreadRadius: 5,
                                            )
                                          ]),
                                      child: ListTile(
                                        title: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Date: ${colVisits.docs[index]['date']}',
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
                                              'Loss Qty: ${colVisits.docs[index]['lossQty']}',
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
                                              'Till Date Mortality: ${colVisits.docs[index]['mortalityTillDate']}',
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
                                              'Feed Intake: ${colVisits.docs[index]['feedIntake']}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            child: ListView.builder(
                                itemCount: colSales.docs.length,
                                itemBuilder: (context, index) {
                                  if (colSales.docs[index]['batch'] !=
                                      widget.batchId) return Container();
                                  return Container(
                                    margin: const EdgeInsets.only(top: 10),
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 5),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.grey.withOpacity(0.15),
                                            blurRadius: 5,
                                            spreadRadius: 5,
                                          )
                                        ]),
                                    child: ListTile(
                                      title: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Date: ${colSales.docs[index]['date']}',
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
                                            'Sales Nos: ${colSales.docs[index]['salesNos']}',
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
                                            'Sales: ${colSales.docs[index]['sales']}',
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
                                            'DC No: ${colSales.docs[index]['dcNo']}',
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
                                            'Purchaser: ${colSales.docs[index]['purchaser']}',
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
                                            'Category: ${colSales.docs[index]['category'] ?? '-'}',
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
                                }),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
