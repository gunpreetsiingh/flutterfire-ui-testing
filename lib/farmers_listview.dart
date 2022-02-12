import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    setState(() {
      isLoading = true;
    });
    colFarmers = await FirebaseFirestore.instance.collection('farmers').get();
    setState(() {
      isLoading = false;
    });
  }

  void showFarmerDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter farmer details'),
          content: Column(
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
                decoration: const InputDecoration(hintText: 'Enter location'),
              ),
            ],
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
                    if (txtEmail.text.isNotEmpty) {
                      if (txtLocation.text.isNotEmpty) {
                        FirebaseFirestore.instance.collection('farmers').add(
                          {
                            'name': txtName.text,
                            'image': '',
                            'number': txtNumber.text,
                            'email': txtEmail.text,
                            'location': txtLocation.text,
                            'employee': '',
                            'attended': false,
                          },
                        );
                      }
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
        onPressed: showFarmerDialog,
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
              child: ListView.builder(
                itemCount: colFarmers.docs.length,
                itemBuilder: (context, index) {
                  if (widget.unattended && colFarmers.docs[index]['attended']) {
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
                      leading: SizedBox(
                        height: 65,
                        width: 65,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage:
                              const AssetImage('assets/profile.jpeg'),
                          foregroundImage:
                              NetworkImage(colFarmers.docs[index]['image']),
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
                          // Text(
                          //   'Email: ${colFarmers.docs[index]['email']}',
                          //   style: const TextStyle(
                          //     fontSize: 14,
                          //     fontWeight: FontWeight.bold,
                          //     color: Colors.grey,
                          //   ),
                          // ),
                          // const SizedBox(
                          //   height: 5,
                          // ),
                          // Text(
                          //   'Location: ${colFarmers.docs[index]['location']}',
                          //   style: const TextStyle(
                          //     fontSize: 14,
                          //     fontWeight: FontWeight.bold,
                          //     color: Colors.grey,
                          //   ),
                          // ),
                          // const SizedBox(
                          //   height: 5,
                          // ),
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
    );
  }
}
