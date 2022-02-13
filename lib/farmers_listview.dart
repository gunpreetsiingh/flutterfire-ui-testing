import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui_testing/main.dart';
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
  var txtName = TextEditingController();
  var txtNumber = TextEditingController();
  var txtEmail = TextEditingController();
  var txtLocation = TextEditingController();

  late QuerySnapshot colFarmers;
  bool isLoading = true, edit = false;
  String docId = '';
  String dropDownValue = '';

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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: const AssetImage('assets/profile.jpeg'),
                foregroundImage: NetworkImage(colFarmers.docs[index]['image']),
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
                'Employee: ${colFarmers.docs[index]['employee']}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
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
                  'Timestamp: ${DateFormat('dd MMM, yyyy hh:mm:ss a').format(DateTime.parse(colFarmers.docs[index]['attended'] ? colFarmers.docs[index]['timestamp'] : DateTime.now().toString()))}',
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
                    edit = true;
                    docId = colFarmers.docs[index].id;
                    txtName.text = colFarmers.docs[index]['name'];
                    txtNumber.text = colFarmers.docs[index]['number'];
                    txtEmail.text = colFarmers.docs[index]['email'];
                    txtLocation.text = colFarmers.docs[index]['location'];
                    dropDownValue = colFarmers.docs[index]['employee'];
                    showFarmerDialog();
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
        );
      },
    );
  }

  void showFarmerDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text(edit ? 'Edit farmer details' : 'Enter farmer details'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: txtName,
                    decoration: const InputDecoration(hintText: 'Enter name*'),
                  ),
                  TextField(
                    controller: txtNumber,
                    decoration:
                        const InputDecoration(hintText: 'Enter mobile number*'),
                  ),
                  TextField(
                    controller: txtEmail,
                    decoration: const InputDecoration(hintText: 'Enter email'),
                  ),
                  TextField(
                    controller: txtLocation,
                    decoration:
                        const InputDecoration(hintText: 'Enter location'),
                  ),
                  DropdownButton<String>(
                    hint: const Text('Select employee'),
                    value: dropDownValue == '' ? null : dropDownValue,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_downward),
                    elevation: 16,
                    onChanged: (String? newValue) {
                      setState(() {
                        dropDownValue = newValue!;
                      });
                    },
                    items:
                        employees.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  if (txtName.text.isNotEmpty) {
                    if (txtNumber.text.isNotEmpty) {
                      if (dropDownValue != 'Select employee') {
                        FirebaseFirestore.instance
                            .collection('farmers')
                            .doc(edit ? docId : null)
                            .set(
                          {
                            'name': txtName.text,
                            'image': '',
                            'number': txtNumber.text,
                            'email': txtEmail.text,
                            'location': txtLocation.text,
                            'employee': dropDownValue,
                            'attended': false,
                          },
                        );
                        OSCreateNotification notification =
                            OSCreateNotification(
                          playerIds: [
                            employeesToken[employees.indexOf(dropDownValue)]
                          ],
                          content: 'You have been assigned a new farmer.',
                          subtitle: 'Please open the app to view details.',
                        );
                        await OneSignal.shared.postNotification(notification);
                      }
                    }
                  }
                  Navigator.of(context).pop();
                  loadData();
                },
                child: const Text('Confirm'),
              ),
            ],
          );
        });
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
          setState(() {
            edit = false;
          });
          showFarmerDialog();
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
                                    builder: (context) => ViewImage(
                                        colFarmers.docs[index]['image'])));
                              },
                              child: SizedBox(
                                height: 65,
                                width: 65,
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundImage:
                                      const AssetImage('assets/profile.jpeg'),
                                  foregroundImage: NetworkImage(
                                      colFarmers.docs[index]['image']),
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
                                  'Employee: ${colFarmers.docs[index]['employee']}',
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
