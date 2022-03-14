import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui_testing/farmer_data_model.dart';
import 'package:flutterfire_ui_testing/main.dart';
import 'package:flutterfire_ui_testing/new_farmer.dart';
import 'package:flutterfire_ui_testing/view_image.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:intl/intl.dart';

class FarmersListView extends StatefulWidget {
  bool unattended;
  FarmersListView(this.unattended, {Key? key}) : super(key: key);

  @override
  _FarmersListViewState createState() => _FarmersListViewState();
}

class _FarmersListViewState extends State<FarmersListView> {
  late QuerySnapshot colFarmers;
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
    colFarmers = await FirebaseFirestore.instance
        .collection('farmers')
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
                Visibility(
                  visible: colFarmers.docs[index]['images'].isNotEmpty,
                  child: Row(
                    children: [
                      for (int i = 0;
                          i < colFarmers.docs[index]['images'].length;
                          i++)
                        CircleAvatar(
                          radius: 50,
                          backgroundImage:
                              const AssetImage('assets/profile.jpeg'),
                          foregroundImage:
                              NetworkImage(colFarmers.docs[index]['images'][i]),
                        ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'Code: ${colFarmers.docs[index]['code']}',
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
                  'Name: ${colFarmers.docs[index]['name']}',
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
                  'Number: ${colFarmers.docs[index]['number']}',
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
                  'Email: ${colFarmers.docs[index]['email']}',
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
                  'Location: ${colFarmers.docs[index]['location']}',
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
                  'Employee: $employee',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const Divider(),
                Row(
                  children: [
                    Visibility(
                      visible: colFarmers.docs[index]['panId'].isNotEmpty,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  ViewImage(colFarmers.docs[index]['panId'])));
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            colFarmers.docs[index]['panId'],
                            fit: BoxFit.cover,
                            height: 50,
                            width: 50,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Pan No: ${colFarmers.docs[index]['panNo']}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Visibility(
                      visible: colFarmers.docs[index]['aadhaarId'].isNotEmpty,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => ViewImage(
                                  colFarmers.docs[index]['aadhaarId'])));
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            colFarmers.docs[index]['aadhaarId'],
                            fit: BoxFit.cover,
                            height: 50,
                            width: 50,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Aadhaar No: ${colFarmers.docs[index]['aadhaarNo']}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'Total Batches: ${colFarmers.docs[index]['batches'].length}',
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
                  'Bank Account Number: ${colFarmers.docs[index]['bankAccNumber']}',
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
                  'Bank Name: ${colFarmers.docs[index]['bankName']}',
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
                  'Bank IFSC Code: ${colFarmers.docs[index]['bankIfscCode']}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const Divider(),
                Visibility(
                  visible: colFarmers.docs[index]['attended'],
                  child: const SizedBox(
                    height: 10,
                  ),
                ),
                Visibility(
                  visible: colFarmers.docs[index]['attended'],
                  child: Text(
                    'Notes: ${colFarmers.docs[index]['attended'] ? colFarmers.docs[index]['notes'] : ''}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Visibility(
                  visible: colFarmers.docs[index]['attended'],
                  child: const SizedBox(
                    height: 10,
                  ),
                ),
                Visibility(
                  visible: colFarmers.docs[index]['attended'],
                  child: Text(
                    'Timestamp: ${DateFormat('dd MMM, yyyy').format(DateTime.parse(colFarmers.docs[index]['attended'] ? colFarmers.docs[index]['timestamp'] : DateTime.now().toString()))}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                const Divider(
                  color: Colors.grey,
                ),
                ListTile(
                  onTap: () {
                    Navigator.of(context).pop();
                    setState(() {
                      docId = colFarmers.docs[index].id;
                      List<String> batchesList = [];
                      colFarmers.docs[index]['batches'].forEach((element) {
                        batchesList.add(element);
                      });
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => NewFarmer(
                            true,
                            docId,
                            FarmerDataModel(
                              code: colFarmers.docs[index]['code'],
                              images: colFarmers.docs[index]['images'],
                              name: colFarmers.docs[index]['name'],
                              number: colFarmers.docs[index]['number'],
                              email: colFarmers.docs[index]['email'],
                              location: colFarmers.docs[index]['location'],
                              panNo: colFarmers.docs[index]['panNo'],
                              aadhaarNo: colFarmers.docs[index]['aadhaarNo'],
                              panId: colFarmers.docs[index]['panId'],
                              aadhaarId: colFarmers.docs[index]['aadhaarId'],
                              attended: colFarmers.docs[index]['attended'],
                              bankAccNumber: colFarmers.docs[index]
                                  ['bankAccNumber'],
                              bankName: colFarmers.docs[index]['bankName'],
                              bankIfscCode: colFarmers.docs[index]
                                  ['bankIfscCode'],
                            ),
                          ),
                        ),
                      );
                    });
                  },
                  leading: Icon(
                    Icons.edit_rounded,
                    color: Colors.black,
                  ),
                  title: Text(
                    'Edit farmer details',
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
        title: Text(
          widget.unattended ? 'Unattended Farmers List' : 'Farmers List',
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => NewFarmer(false, '', FarmerDataModel())));
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
                      'Long press to edit farmer details.',
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
                      itemCount: colFarmers.docs.length,
                      itemBuilder: (context, index) {
                        if (widget.unattended &&
                            colFarmers.docs[index]['attended']) {
                          return Container();
                        }
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
                            onLongPress: () {
                              showEditOptions(index);
                            },
                            leading: GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => ViewImage(colFarmers
                                        .docs[index]['images']
                                        .toString())));
                              },
                              child: SizedBox(
                                height: 65,
                                width: 65,
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundImage:
                                      const AssetImage('assets/profile.jpeg'),
                                  foregroundImage: NetworkImage(colFarmers
                                      .docs[index]['images']
                                      .toString()),
                                ),
                              ),
                            ),
                            title: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Name: ${colFarmers.docs[index]['name']}',
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
                                  'Number: ${colFarmers.docs[index]['number']}',
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
                                  'Employee: $employee',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            trailing: colFarmers.docs[index]['attended']
                                ? const Icon(
                                    Icons.done_rounded,
                                    color: Colors.green,
                                    size: 30,
                                  )
                                : const Icon(
                                    Icons.warning_amber_rounded,
                                    color: Colors.amber,
                                    size: 30,
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
