import 'package:flutterfire_ui_testing/batch_data_model.dart';

class FarmerDataModel {
  String? code,
      name,
      number,
      email,
      location,
      panNo,
      aadhaarNo,
      panId,
      aadhaarId,
      bankAccNumber,
      bankName,
      bankIfscCode,
      notes,
      timestamp;
  List? images;
  bool? attended;
  FarmerDataModel(
      {this.code,
      this.images,
      this.name,
      this.number,
      this.email,
      this.location,
      this.panNo,
      this.aadhaarNo,
      this.panId,
      this.aadhaarId,
      this.attended,
      this.bankAccNumber,
      this.bankName,
      this.bankIfscCode,
      this.notes,
      this.timestamp});
}
