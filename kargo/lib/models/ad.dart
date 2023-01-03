import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';

class Ad {
  List<String> imagePaths;
  String adId;
  String highestBidderId;
  String ownerId;
  String manufacturer;
  String model;
  int askPrice;
  int highestBid;
  int year;
  String typeId;
  int fav;
  String colour;
  int km;
  String title;
  String desc;
  String carId;
  Timestamp startDate;
  Timestamp endDate;
  int cc;
  int auto;
  Ad(
      {required this.imagePaths,
      required this.adId,
      required this.highestBidderId, //
      required this.ownerId, //
      required this.manufacturer,
      required this.model,
      required this.askPrice,
      required this.highestBid,
      required this.cc,
      required this.auto,
      required this.year,
      required this.typeId,
      required this.colour, //
      required this.km,
      required this.title, //
      required this.desc, //
      required this.carId,
      required this.startDate,
      required this.endDate,
      required this.fav});
}
