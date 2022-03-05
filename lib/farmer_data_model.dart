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
      employeeCode,
      bankAccNumber,
      bankName,
      bankIfscCode,
      notes,
      timestamp;
  List? images;
  List? batches;
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
      this.employeeCode,
      this.batches,
      this.attended,
      this.bankAccNumber,
      this.bankName,
      this.bankIfscCode,
      this.notes,
      this.timestamp});
}
