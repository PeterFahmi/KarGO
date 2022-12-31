import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import '../components/ad_card2.dart';
import '../components/multiChip.dart';
import 'package:flutter/material.dart';
class FilteredScreen extends StatefulWidget {
    final List<String> values;
    
FilteredScreen({ required this.values});
  @override
  State<FilteredScreen> createState() => _FilteredScreenState();
}






class _FilteredScreenState extends State<FilteredScreen> {


  void initState() {
    super.initState();
    getCars();
  }

List<Map<String, String>> ads=[];
void getCars () async {
List<Map<String, String>> CarADs=[];
  List carsIDs=widget.values;
   carsIDs.forEach((id) async {

    Map<String, String> map = Map();
     await FirebaseFirestore.instance
  .collection('ads')
  .where(FieldPath.documentId, isEqualTo:id )
  .get()
  .then((value) {
    value.docs.forEach((element) async {
      String askPrice=element["ask_price"].toString();

      String bid="0";
      if(element["bid"]!=null)
       bid=element["bid"].toString();
       map['askPrice'] = askPrice;

  map['bid'] = bid;



  String carID=element["car_id"];

print(map);
     await FirebaseFirestore.instance
  .collection('cars')
  .where(FieldPath.documentId, isEqualTo:carID )
  .get()
  .then((value) {
    value.docs.forEach((element) async {

String km=element["km"].toString();
      String url="https://t3.ftcdn.net/jpg/04/62/93/66/360_F_462936689_BpEEcxfgMuYPfTaIAOC1tCDurmsno7Sp.jpg";
      if(element["photos"]!=null ||!element["photos"].length==0)
      url=element["photos"].join(',');
String year=element["year"].toString();


  map['url'] = url;
    map['year'] = year;
      map['km'] = km;
      

print(map);

  String typeID=element["type_id"];


    var x= await FirebaseFirestore.instance
  .collection('types')
  .where(FieldPath.documentId, isEqualTo:typeID )
  .get()
  .then((value) {
    value.docs.forEach((element){

String model=element["model"];
String manufacturer=element["manufacturer"];

  map['model'] = model;
    map['manufacturer'] = manufacturer;


      CarADs.add(map);
      print("f $CarADs");
          print("f2 $CarADs");
     ads=CarADs;
      setState(() {
 ads=CarADs;
 });
     print("f3 $ads");
     
    }); 
 
     });


    });



    });
    



  });
  });
  
  
  
  });


}
 Widget build(BuildContext context) {
   print("f4 $ads");
 return Scaffold(

           appBar: AppBar(
        title: Text('Filter Results'),
        backgroundColor: Colors.black
      ),
           body: ads.length==0? Text("No results found"): ListView.builder(
        itemCount: ads.length,
        itemBuilder: (context, index) {
          // Get the map object at the current index
          Map<String, String> item = ads[index];

          // Turn the map object into a card widget
          return Ad_Card2(ask: int.parse(item["askPrice"]!),
         bid: int.parse(item["bid"]!), 
          fav: 0,
           imgUrls:item["url"]!.split(",") 
           , km: int.parse(item["km"]!),
            year: int.parse(item["year"]!),
             manufacturer: item["manufacturer"], model: item["model"],
    
          );      },
      )
 );

 
 }
}