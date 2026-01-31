import 'dart:math';

import 'package:intl_phone_field/phone_number.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const List<int> initialAgeRange = [18, 120];

class FormMetadata {
  final String? docID;
  bool notSubmitted;

  FormMetadata(this.docID, this.notSubmitted);
}

class FormData {
  final Profile formResponse;
  final FormMetadata metadata;

  FormData(this.formResponse, this.metadata);
}

Map<String, dynamic>? phoneNumberToJson(PhoneNumber phoneNumber) {
  if (phoneNumber.number.isEmpty) {
    return null;
  } else {
    return {
      'countryISOCode': phoneNumber.countryISOCode,
      'countryCode': phoneNumber.countryCode,
      'number': phoneNumber.number,
    };
  }
}

PhoneNumber phoneNumberFromJson(Map<String, dynamic> json) {
  return PhoneNumber(
    countryISOCode: json['countryISOCode'] as String,
    countryCode: json['countryCode'] as String,
    number: json['number'] as String,
  );
}

class Location {
  final double latitude;
  final double longitude;
  final bool consent;
  final String? name;

  Location(this.latitude, this.longitude, this.consent, [this.name]);

  Map<String, dynamic> toFirestore() {
    return {
      "latitude": latitude,
      "longitude": longitude,
      "consent": consent,
      "name": name,
    };
  }

  Location fromMap(Map<String, dynamic> map) {
    return Location(
      map['latitude'],
      map['longitude'],
      map['consent'],
      map['name'],
    );
  }
}

class Profile {
  String? name;
  String? dob; // dd/mm/yyyy
  List<int> ageRange;
  PhoneNumber? phoneNumber;
  String? gender;
  List<String>? orientation;
  String? profileImage;
  Location? location;
  int? distanceRangeKm;
  bool neverRefreshedMatches = true;

  Profile({
    this.name,
    this.dob,
    this.ageRange = initialAgeRange,
    this.phoneNumber,
    this.gender,
    this.orientation,
    this.profileImage,
    this.location,
    this.distanceRangeKm,
    this.neverRefreshedMatches = true,
  });

  void setSensibleAgeRange(String dob) {
    final parts = dob.split('/');
    final int age = DateTime.now()
            .difference(DateTime.parse('${parts[2]}-${parts[1]}-${parts[0]}'))
            .inDays ~/
        365;
    final int lowerAge = max(18, age - 10);
    final int upperAge = min(120, age + 10);
    ageRange = [lowerAge, upperAge];
  }

  factory Profile.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    final orientation = (data?['orientation'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList();
    return Profile(
      name: data?['name'],
      dob: data?['dob'],
      ageRange: data?['age_range'] != null
          ? List<int>.from(data?['age_range'])
          : initialAgeRange,
      phoneNumber: data?['phone_number'] != null
          ? phoneNumberFromJson(data?['phone_number'])
          : null,
      gender: data?['gender'],
      orientation: orientation,
      profileImage: data?['profile_image'],
      location: data?['location'] != null
          ? Location(0, 0, false).fromMap(data?['location'])
          : null,
      distanceRangeKm: data?['distance_range_km'],
      neverRefreshedMatches: data?['never_refreshed_matches'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "name": name,
      "dob": dob,
      "age_range": ageRange,
      "phone_number":
          phoneNumber != null ? phoneNumberToJson(phoneNumber!) : null,
      "gender": gender,
      "orientation": orientation,
      "profile_image": profileImage,
      "location": location?.toFirestore(),
      "distance_range_km": distanceRangeKm,
      "never_refreshed_matches": neverRefreshedMatches,
    };
  }
}
