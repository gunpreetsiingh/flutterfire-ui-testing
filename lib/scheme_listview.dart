import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui_testing/farmer_data_model.dart';
import 'package:flutterfire_ui_testing/new_farmer.dart';
import 'package:flutterfire_ui_testing/new_scheme_entry.dart';
import 'package:flutterfire_ui_testing/scheme_data_model.dart';
import 'package:flutterfire_ui_testing/view_image.dart';
// import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:intl/intl.dart';

class SchemeListView extends StatefulWidget {
  const SchemeListView({Key? key}) : super(key: key);

  @override
  _SchemeListViewState createState() => _SchemeListViewState();
}

class _SchemeListViewState extends State<SchemeListView> {
  bool isLoading = true;
  late QuerySnapshot colSchemes;
  List<SchemeDataModel> listScheme = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    setState(() {
      isLoading = true;
    });
    colSchemes = await FirebaseFirestore.instance
        .collection('schemes')
        .orderBy('name')
        .get();
    setState(() {
      listScheme = colSchemes.docs
          .map((e) =>
              SchemeDataModel().fromJson(e.data() as Map<String, dynamic>))
          .toList();
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
                  'ID: ${listScheme[index].id}',
                ),
                Text(
                  'Name: ${listScheme[index].name}',
                ),
                Text(
                  'Branch Applicability: ${listScheme[index].branchApplicability}',
                ),
                Text(
                  'Basis: ${listScheme[index].basis}',
                ),
                Text(
                  'STD Market Incentive Over: ${listScheme[index].stdMarketIncentiveOver}',
                ),
                Text(
                  'STD Market Incentive Rate: ${listScheme[index].stdMarketIncentiveRate}',
                ),
                Text(
                  'Market Incentive Scheme: ${listScheme[index].marketIncentiveScheme}',
                ),
                Text(
                  'Applicable From: ${listScheme[index].applicableFrom}',
                ),
                Text(
                  'Applicable To: ${listScheme[index].applicableTo}',
                ),
                Text(
                  'SCR (Chicks): ${listScheme[index].scrChicks}',
                ),
                Text(
                  'SFR (Feed): ${listScheme[index].sfrFeed}',
                ),
                Text(
                  'STD Cost: ${listScheme[index].stdCost}',
                ),
                Text(
                  'STD Rate: ${listScheme[index].stdRate}',
                ),
                Text(
                  'Medicine Included: ${listScheme[index].medicineIncluded}',
                ),
                Text(
                  'Vaccine Included: ${listScheme[index].vaccineIncluded}',
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
          'Schemes',
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.brown,
        onPressed: () async {
          if (!isLoading) {
            var response = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => NewSchemeEntry(
                  schemeDataModel: null,
                ),
              ),
            );
            if (response) {
              loadData();
            }
          }
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
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: listScheme.length,
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
                          ],
                        ),
                        child: ListTile(
                          onLongPress: () {
                            showEditOptions(index);
                          },
                          title: Text(
                            'Name: ${listScheme[index].name}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          subtitle: Text(
                            '${DateFormat('dd-MM-yyyy').format(listScheme[index].applicableFrom!.toDate())} to ${DateFormat('dd-MM-yyyy').format(listScheme[index].applicableTo!.toDate())}',
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.grey,
                            size: 30,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(
                    height: 100,
                  ),
                ],
              ),
            ),
    );
  }
}
