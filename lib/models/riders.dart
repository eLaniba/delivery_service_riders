import 'package:cloud_firestore/cloud_firestore.dart';

class Riders {
  String? driverPath;
  String? driverURL;
  bool? driverVerified;
  bool? emailVerified;
  String? idPath;
  String? idURL;
  bool? idVerified;
  bool? phoneVerified;
  String? riderAddress;
  String? riderEmail;
  String? riderID;
  GeoPoint? riderLocation;
  String? riderName;
  String? riderPhone;
  String? riderProfilePath ;
  String? riderProfileURL;
  String? status;

  Riders({
    this.driverPath,
    this.driverURL,
    this.driverVerified,
    this.emailVerified,
    this.idPath,
    this.idURL,
    this.idVerified,
    this.phoneVerified,
    this.riderAddress,
    this.riderEmail,
    this.riderID,
    this.riderLocation,
    this.riderName,
    this.riderPhone,
    this.riderProfilePath,
    this.riderProfileURL,
    this.status,
  });

  Riders.fromJson(Map<String, dynamic> json) {
    driverPath = json["driverPath"];
    driverURL = json["driverURL"];
    driverVerified = json["driverVerified"];
    emailVerified = json["emailVerified"];
    idPath = json["idPath"];
    idURL = json["idURL"];
    idVerified = json["idVerified"];
    phoneVerified = json["phoneVerified"];
    riderAddress = json["riderAddress"];
    riderEmail = json["riderEmail"];
    riderID = json["riderID"];
    riderLocation = json["riderLocation"];
    riderName = json["riderName"];
    riderPhone = json["riderPhone"];
    riderProfilePath = json["riderProfilePath"];
    riderProfileURL = json["riderProfileURL"];
    status = json["status"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["driverPath"] = driverPath;
    data["driverURL"] = driverURL;
    data["driverVerified"] = driverVerified;
    data["emailVerified"] = emailVerified;
    data["idPath"] = idPath;
    data["idURL"] = idURL;
    data["idVerified"] = idVerified;
    data["phoneVerified"] = phoneVerified;
    data["riderAddress"] = riderAddress;
    data["riderEmail"] = riderEmail;
    data["riderID"] = riderID;
    data["riderLocation"] = riderLocation;
    data["riderName"] = riderName;
    data["riderPhone"] = riderPhone;
    data["riderProfilePath"] = riderProfilePath;
    data["riderProfileURL"] = riderProfileURL;
    data["status"] = status;

    return data;
  }

}