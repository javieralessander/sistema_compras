import 'dart:convert';
import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';

enum UserGender { MALE, FEMALE, OTHER }

extension UserGenderExtension on UserGender {
  String get value {
    switch (this) {
      case UserGender.MALE:
        return 'M';
      case UserGender.FEMALE:
        return 'F';
      case UserGender.OTHER:
        return 'NA';
      default:
        throw ArgumentError('Unknown gender: $this');
    }
  }

  String get label {
    switch (this) {
      case UserGender.MALE:
        return 'Masculino';
      case UserGender.FEMALE:
        return 'Femenino';
      case UserGender.OTHER:
        return 'Prefiero no especificar';
      default:
        throw ArgumentError('Unknown gender: $this');
    }
  }

  static UserGender fromValue(String value) {
    switch (value) {
      case 'M':
        return UserGender.MALE;
      case 'F':
        return UserGender.FEMALE;
      case 'NA':
        return UserGender.OTHER;
      default:
        throw ArgumentError('Unknown gender value: $value');
    }
  }
}

class User {
  String? id;
  bool? active;
  dynamic documents;
  String? identity;
  String? identityType;
  String? completeName;
  String? username;
  String? password;
  String? email;
  DateTime? birthday;
  String? phoneNumber;
  String? address;
  String? nationality;
  UserGender? gender;
  String? photo;
  String? externalId;
  String? url;

  bool? isAnSS0User;

  // Merge with UserData
  String? displayName;
  String? firstName;
  String? lastName;
  bool? emailVerified;
  String? direction;
  String? photoURL;
  GeoPoint? location;

  User({
    this.id,
    this.active,
    this.documents,
    this.identity,
    this.identityType,
    this.completeName,
    this.username,
    this.password,
    this.email,
    this.birthday,
    this.phoneNumber,
    this.address,
    this.nationality,
    this.gender,
    this.photo,
    this.externalId,
    this.isAnSS0User = false,

    // Merge with UserData
    this.displayName,
    this.firstName,
    this.lastName,
    this.emailVerified,
    this.direction,
    this.photoURL,
    this.location,
  }) {
    if (Platform.isAndroid) {
      url =
          "https://play.google.com/store/apps/details?id=com.ambientedo.calcarbono";
    } else if (Platform.isIOS) {
      url =
          "https://apps.apple.com/app/calculadora-huella-de-carbono/id6477601758";
    }
  }

  factory User.fromRawJson(String str) => User.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["_id"] ?? json["id"],
    active: json["active"],
    documents: json["documents"],
    identity: json["identity"],
    identityType: json["identityType"],
    completeName: json["completeName"],
    username: json["username"],
    password: json["password"],
    email: json["email"],
    birthday:
        json["birthday"] != null ? DateTime.parse(json["birthday"]) : null,
    phoneNumber: json["phoneNumber"],
    address: json["address"],
    nationality: json["nationality"],
    gender:
        json["gender"] != null
            ? UserGenderExtension.fromValue(json["gender"])
            : null,
    photo: json["photo"],
    externalId: json["externalId"],
    isAnSS0User: json["isAnSS0User"] ?? false,
  );

  factory User.fromOdoo(Map<String, dynamic> json) => User(
    id: json["id"].toString(),
    completeName: json["name"],
    username: json["login"],
    email: json["email"],
    photo: json["image_1920"], // base64
    externalId: json["external_id"] ?? null,
    phoneNumber: json["phone"],
    birthday:
        json["birthday"] != null ? DateTime.parse(json["birthday"]) : null,
    nationality: json["country_of_birth"]?["display_name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "identity": identity?.replaceAll('-', ''),
    "identityType": identityType,
    "completeName": completeName,
    "username": username,
    "password": password,
    "email": email,
    "birthday": birthday?.toIso8601String(),
    "phoneNumber": phoneNumber?.replaceAll(RegExp(r'[() -]'), ''),
    "address": address,
    "nationality": nationality,
    "url": url,
    "gender": gender?.value,
    "photo": photo,
    "externalId": externalId,
    "isAnSS0User": isAnSS0User,
  };
}
