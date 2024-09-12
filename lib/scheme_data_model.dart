import 'package:cloud_firestore/cloud_firestore.dart';

class SchemeDataModel {
  String? id,
      name,
      branchApplicability,
      basis,
      stdMarketIncentiveOver,
      stdMarketIncentiveRate,
      marketIncentiveScheme;
  Timestamp? applicableFrom, applicableTo;
  double? scrChicks, sfrFeed, stdCost, stdRate;
  bool? medicineIncluded, vaccineIncluded;

  SchemeDataModel({
    this.id,
    this.name,
    this.branchApplicability,
    this.basis,
    this.stdMarketIncentiveOver,
    this.stdMarketIncentiveRate,
    this.marketIncentiveScheme,
    this.applicableFrom,
    this.applicableTo,
    this.scrChicks,
    this.sfrFeed,
    this.stdCost,
    this.stdRate,
    this.medicineIncluded,
    this.vaccineIncluded,
  });

  Map<String, dynamic> toJson(SchemeDataModel schemeDataModel) {
    return {
      'id': schemeDataModel.id,
      'name': schemeDataModel.name,
      'branchApplicability': schemeDataModel.branchApplicability,
      'basis': schemeDataModel.basis,
      'stdMarketIncentiveOver': schemeDataModel.stdMarketIncentiveOver,
      'stdMarketIncentiveRate': schemeDataModel.stdMarketIncentiveRate,
      'marketIncentiveScheme': schemeDataModel.marketIncentiveScheme,
      'applicableFrom': schemeDataModel.applicableFrom,
      'applicableTo': schemeDataModel.applicableTo,
      'scrChicks': schemeDataModel.scrChicks,
      'sfrFeed': schemeDataModel.sfrFeed,
      'stdCost': schemeDataModel.stdCost,
      'stdRate': schemeDataModel.stdRate,
      'medicineIncluded': schemeDataModel.medicineIncluded,
      'vaccineIncluded': schemeDataModel.vaccineIncluded,
    };
  }

  SchemeDataModel fromJson(Map<String, dynamic> json) {
    return SchemeDataModel(
      id: json['id'],
      name: json['name'],
      branchApplicability: json['branchApplicability'],
      basis: json['basis'],
      stdMarketIncentiveOver: json['stdMarketIncentiveOver'],
      stdMarketIncentiveRate: json['stdMarketIncentiveRate'],
      marketIncentiveScheme: json['marketIncentiveScheme'],
      applicableFrom: json['applicableFrom'],
      applicableTo: json['applicableTo'],
      scrChicks: json['scrChicks'],
      sfrFeed: json['sfrFeed'],
      stdCost: json['stdCost'],
      stdRate: json['stdRate'],
      medicineIncluded: json['medicineIncluded'],
      vaccineIncluded: json['vaccineIncluded'],
    );
  }
}
