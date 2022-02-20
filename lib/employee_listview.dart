import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EmployeeListView extends StatefulWidget {
  @override
  _EmployeeListViewState createState() => _EmployeeListViewState();
}

class _EmployeeListViewState extends State<EmployeeListView> {
  var txtName = TextEditingController();
  var txtNumber = TextEditingController();
  var txtEmail = TextEditingController();

  late QuerySnapshot colEmployees;
  bool isLoading = true, edit = false, activated = true;

  String docId = '';

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    setState(() {
      isLoading = true;
    });
    colEmployees = await FirebaseFirestore.instance
        .collection('employees')
        .orderBy('name')
        .get();
    setState(() {
      isLoading = false;
    });
  }

  void showEditOptions(int index) {
    showModalBottomSheet(
      context: context,
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
                foregroundImage:
                    NetworkImage(colEmployees.docs[index]['image']),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                'Code: ${colEmployees.docs[index]['code']}',
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
                'Name: ${colEmployees.docs[index]['name']}',
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
                'Number: ${colEmployees.docs[index]['number']}',
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
                'Email: ${colEmployees.docs[index]['email']}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                'Activated: ${colEmployees.docs[index]['activated']}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
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
                    docId = colEmployees.docs[index].id;
                    txtName.text = colEmployees.docs[index]['name'];
                    txtNumber.text = colEmployees.docs[index]['number'];
                    txtEmail.text = colEmployees.docs[index]['email'];
                    activated = colEmployees.docs[index]['activated'];
                    showEmployeeDialog();
                  });
                },
                leading: Icon(
                  Icons.edit_rounded,
                  color: Colors.black,
                ),
                title: Text(
                  'Edit employee details',
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

  void showEmployeeDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (contextt, setState) {
            return AlertDialog(
              title: const Text('Enter employee details'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: txtName,
                      decoration:
                          const InputDecoration(hintText: 'Enter name*'),
                    ),
                    TextField(
                      controller: txtNumber,
                      decoration: const InputDecoration(
                          hintText: 'Enter mobile number*'),
                    ),
                    TextField(
                      controller: txtEmail,
                      decoration:
                          const InputDecoration(hintText: 'Enter email'),
                    ),
                    CheckboxListTile(
                      value: activated,
                      title: const Text('Activated?'),
                      onChanged: (val) {
                        setState(() {
                          activated = val!;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
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
                        FirebaseFirestore.instance
                            .collection('employees')
                            .doc(edit ? docId : null)
                            .set(
                          {
                            'name': txtName.text,
                            'number': txtNumber.text,
                            'image': '',
                            'email': txtEmail.text,
                            'activated': activated,
                          },
                        );
                      }
                    }
                    Navigator.of(context).pop();
                    loadData();
                  },
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Employees List',
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     setState(() {
      //       edit = false;
      //     });
      //     showEmployeeDialog();
      //   },
      //   child: const Icon(
      //     Icons.person_add_alt_1_outlined,
      //     color: Colors.white,
      //   ),
      // ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ListView.builder(
                itemCount: colEmployees.docs.length,
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
                      onLongPress: () {
                        showEditOptions(index);
                      },
                      leading: SizedBox(
                        height: 65,
                        width: 65,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage:
                              const AssetImage('assets/profile.jpeg'),
                          foregroundImage:
                              NetworkImage(colEmployees.docs[index]['image']),
                        ),
                      ),
                      title: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Name: ${colEmployees.docs[index]['name']}',
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
                            'Number: ${colEmployees.docs[index]['number']}',
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
    );
  }
}
