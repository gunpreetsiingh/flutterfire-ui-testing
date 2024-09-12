import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Reasons extends StatefulWidget {
  const Reasons({Key? key}) : super(key: key);

  @override
  State<Reasons> createState() => _ReasonsState();
}

class _ReasonsState extends State<Reasons> {
  var txtReason = TextEditingController();
  bool isLoading = true;
  late QuerySnapshot colReasons;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
  }

  void loadData() async {
    setState(() {
      isLoading = true;
    });
    colReasons = await FirebaseFirestore.instance
        .collection('reasons')
        .orderBy('reason')
        .get();
    setState(() {
      isLoading = false;
    });
  }

  void saveReason() {
    FirebaseFirestore.instance.collection('reasons').doc().set({
      'reason': txtReason.text,
    });
    Navigator.of(context).pop();
  }

  void showPopup() async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: TextField(
              controller: txtReason,
              decoration: const InputDecoration(labelText: 'Enter reason'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  saveReason();
                  Navigator.of(context).pop();
                  loadData();
                },
                child: const Text('Save'),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reasons',
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showPopup();
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
                itemCount: colReasons.docs.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.all(5),
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
                      title: Text(colReasons.docs[index]['reason']),
                      trailing: IconButton(
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('reasons')
                              .doc(colReasons.docs[index].id)
                              .delete();
                          loadData();
                        },
                        icon: const Icon(
                          Icons.delete_outlined,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
