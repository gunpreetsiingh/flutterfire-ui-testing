import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui_testing/main.dart';
import 'package:flutterfire_ui_testing/scheme_data_model.dart';
import 'package:intl/intl.dart';

class NewSchemeEntry extends StatefulWidget {
  SchemeDataModel? schemeDataModel;
  NewSchemeEntry({
    Key? key,
    required this.schemeDataModel,
  }) : super(key: key);

  @override
  State<NewSchemeEntry> createState() => _NewSchemeEntryState();
}

class _NewSchemeEntryState extends State<NewSchemeEntry> {
  var txtName = TextEditingController();
  var txtBranchApplicability = TextEditingController();
  var txtBasis = TextEditingController();
  var txtStdMarketIncentiveOver = TextEditingController();
  var txtStdMarketIncentiveRate = TextEditingController();
  var txtMarketIncentiveScheme = TextEditingController();
  var txtScrChicks = TextEditingController();
  var txtSfrFeed = TextEditingController();
  var txtStdCost = TextEditingController();
  var txtStdRate = TextEditingController();
  String id = '';
  bool isLoading = true, medicineIncluded = false, vaccineIncluded = false;
  String dropDownValue = '';
  Timestamp applicableFrom = Timestamp.now(), applicableTo = Timestamp.now();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    prepare();
  }

  void prepare() {
    setState(() {
      if (widget.schemeDataModel != null) {
        id = widget.schemeDataModel!.id.toString();
        txtName.text = widget.schemeDataModel!.name.toString();
        txtBranchApplicability.text =
            widget.schemeDataModel!.branchApplicability.toString();
        txtBasis.text = widget.schemeDataModel!.basis.toString();
        txtStdMarketIncentiveOver.text =
            widget.schemeDataModel!.stdMarketIncentiveOver.toString();
        txtStdMarketIncentiveRate.text =
            widget.schemeDataModel!.stdMarketIncentiveRate.toString();
        txtMarketIncentiveScheme.text =
            widget.schemeDataModel!.marketIncentiveScheme.toString();
        txtScrChicks.text = widget.schemeDataModel!.scrChicks.toString();
        txtSfrFeed.text = widget.schemeDataModel!.sfrFeed.toString();
        txtStdCost.text = widget.schemeDataModel!.stdCost.toString();
        txtStdRate.text = widget.schemeDataModel!.stdRate.toString();
        medicineIncluded = widget.schemeDataModel!.medicineIncluded ?? false;
        vaccineIncluded = widget.schemeDataModel!.vaccineIncluded ?? false;
        applicableFrom =
            widget.schemeDataModel!.applicableFrom ?? Timestamp.now();
        applicableTo = widget.schemeDataModel!.applicableTo ?? Timestamp.now();
      } else {
        id = DateTime.now().millisecondsSinceEpoch.toString();
      }
    });
  }

  void saveUpdateScheme() async {
    await FirebaseFirestore.instance.collection('schemes').doc(id).set(
          SchemeDataModel().toJson(SchemeDataModel()),
          SetOptions(merge: true),
        );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add new payment scheme',
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          saveUpdateScheme();
        },
        child: const Icon(
          Icons.done_rounded,
          color: Colors.white,
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      'ID: $id',
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    TextField(
                      controller: txtName,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Enter name',
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    GestureDetector(
                      onTap: () async {
                        var result = await showDatePicker(
                            context: context,
                            initialDate: applicableFrom.toDate(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100));
                        if (result != null) {
                          setState(() {
                            applicableFrom = Timestamp.fromDate(result);
                          });
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          'Date: ${DateFormat('dd-MM-yyyy').format(applicableFrom.toDate())}',
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    GestureDetector(
                      onTap: () async {
                        var result = await showDatePicker(
                            context: context,
                            initialDate: applicableTo.toDate(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100));
                        if (result != null) {
                          setState(() {
                            applicableTo = Timestamp.fromDate(result);
                          });
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          'Date: ${DateFormat('dd-MM-yyyy').format(applicableTo.toDate())}',
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    TextField(
                      controller: txtBranchApplicability,
                      decoration: const InputDecoration(
                        labelText: 'Enter branch applicability',
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    TextField(
                      controller: txtScrChicks,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Enter SCR (Chicks)',
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    TextField(
                      controller: txtSfrFeed,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Enter SFR (Feed)',
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    TextField(
                      controller: txtStdCost,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Enter STD Cost',
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    TextField(
                      controller: txtStdRate,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Enter STD rate',
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    CheckboxListTile(
                      value: medicineIncluded,
                      title: const Text('Medicine Included'),
                      onChanged: (value) {
                        setState(() {
                          medicineIncluded = value ?? false;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    CheckboxListTile(
                      value: vaccineIncluded,
                      title: const Text('Vaccine Included'),
                      onChanged: (value) {
                        setState(() {
                          vaccineIncluded = value ?? false;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    TextField(
                      controller: txtBasis,
                      decoration: const InputDecoration(
                        labelText: 'Enter Basis (50% of extra/none)',
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    TextField(
                      controller: txtStdMarketIncentiveOver,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Enter STD Market Incentive Over',
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    TextField(
                      controller: txtStdMarketIncentiveRate,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Enter STD Market Incentive Rate',
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    TextField(
                      controller: txtMarketIncentiveScheme,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Enter Market Incentive Scheme',
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
