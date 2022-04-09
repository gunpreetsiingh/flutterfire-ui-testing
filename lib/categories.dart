import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';

class Categories extends StatefulWidget {
  Categories({Key? key}) : super(key: key);

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  var txtCategory = TextEditingController();
  bool isLoading = true;
  late QuerySnapshot colCategories;

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
    colCategories = await FirebaseFirestore.instance
        .collection('categories')
        .orderBy('name')
        .get();
    setState(() {
      isLoading = false;
    });
  }

  void saveReason() {
    FirebaseFirestore.instance.collection('categories').doc().set({
      'name': txtCategory.text,
    });
    Navigator.of(context).pop();
  }

  void showPopup() async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: TextField(
              controller: txtCategory,
              decoration: const InputDecoration(labelText: 'Enter category'),
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
          'Categories',
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
                itemCount: colCategories.docs.length,
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
                      title: Text(colCategories.docs[index]['name']),
                      trailing: IconButton(
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('categories')
                              .doc(colCategories.docs[index].id)
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
