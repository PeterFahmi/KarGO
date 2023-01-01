import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:kargo/screens/filtered_screen.dart';
import '../components/multiChip.dart';

class FilterPage extends StatefulWidget {
  @override
  _FilterPageState createState() => _FilterPageState();
}
Map<String, List<String>> models={};
Future<Map<String, List<String>>> getModels() async {
  

// Get a reference to the "car_ads" collection
final carAdsRef = FirebaseFirestore.instance.collection('types');
Map<String, List<String>> models1={};
// Query the collection to get all documents
final querySnapshot = await carAdsRef.get();

// create a map to store the models for each manufacturer
double minp=1000.0;
double maxp=0;

int miny=10000;
int maxy=0;

// Iterate through the car ad documents and get the models for each manufacturer
querySnapshot.docs.forEach((carAdDoc) {
  // get the manufacturer name
  
  String manufacturer = carAdDoc.data()['manufacturer'];
  // get the model
  // double p= carAdDoc.data()['price'].toDouble();
  // int y= carAdDoc.data()['year'];
  // if(p>maxp)
  // maxp=p;


  //   if(p<minp)
  // minp=p;
  

  //     if(y<miny)
  // miny=y;

  //   if(y>maxy)
  // maxy=y;

  String model = carAdDoc.data()['model'];
  // check if the manufacturer already exists in the map
  if ( models1.containsKey(manufacturer)) {
    // if it does, add the model to the list of models for that manufacturer
    models1[manufacturer]!.add(model);
  } else {
    // if it doesn't, add the manufacturer and model to the map
    models1[manufacturer] = [model];
  }
});
 await FirebaseFirestore.instance
  .collection('extrema')
  .where(FieldPath.documentId, isEqualTo:"extremes" )
  .get()
  .then((value) {
    value.docs.forEach((element) {
      minp=element["min_price"].toDouble();
      maxp=element["max_price"].toDouble();
      miny=element["min_year"];
      maxy=element["max_year"];
    });
  });
models1["price"]=[maxp.toString(),minp.toString()];
models1["year"]=[maxy.toString(),miny.toString()];

return models1;
  }



  @override
 
class _FilterPageState extends State<FilterPage> {
     void initState() {
    super.initState();

    // get the models when the widget is first created
    getModels().then((newModels) {
      // update the models map and trigger a rebuild
      setState(() {
        models = newModels;
        minp=double.parse((newModels["price"]![1]));
        maxp=double.parse((newModels["price"]![0]));
        if(_minPrice2==0){
          _minPrice2=minp;
        _maxPrice2=maxp;
        }

        miny=int.parse((newModels["year"]![1]));
        maxy=int.parse((newModels["year"]![0]));
        if(_minyear2==0){
          _minyear2=miny;
        _maxyear2=maxy;
        }
                        print(minp);
                print(maxp);
        newModels.remove("price");
        models.remove("price");
        newModels.remove("year");
        models.remove("year");
        availableModels=models.values.toList().expand((i) => i).toList();

      });
    });
  }
  final _formKey = GlobalKey<FormState>();
  List<String> _manufacturers = [];
  List<String> _models = [];
  late String _year;
  late String _minyear;
  late String _maxyear;
int _maxyear2=2000;
int _minyear2=0;
   late double _minPrice2=0;
  late double _maxPrice2=100;
  
  List<String> availableModels=[];
double minp=1000;
double maxp=0;
int miny=10000;
int maxy=0;
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Filter Car Ads'),
        backgroundColor: Colors.black
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [ Row(
              children: [SizedBox(width: 5),Text("Manufacturers: "),SizedBox(width: 5),
                Expanded( child:
            MultiSelectChip(
              labels: models.keys.toList(),
              onSelectionChanged: (selected) {
                setState(() {
                  
                  _manufacturers = selected;
                  if(_manufacturers.isEmpty)
                  availableModels=models.values.toList().expand((i) => i).toList();
                  else
                  availableModels= models.entries
    .where((entry) => _manufacturers.contains(entry.key))
    .expand((entry) => entry.value)
    .toList();
               _models = _models.where((element) => availableModels.contains(element)).toList();  });
              },
              
            ))]),
             Row(
              children: [SizedBox(width: 5),Text("Models: "),SizedBox(width: 5),
                Expanded( child:
            MultiSelectChip(
              labels:availableModels,
              onSelectionChanged: (selected) {
                setState(() {
                  _models = selected;

                });
              },
            ))]),
          


Row(
              children: [SizedBox(width: 5),Text("Price: "),SizedBox(width: 5),



  Expanded( child:
    RangeSlider(
        activeColor: Colors.black,
  inactiveColor: Color.fromARGB(255, 191, 190, 190),
            values: RangeValues(_minPrice2, _maxPrice2),
            min:minp>maxp?maxp:minp,
            max: minp>maxp? minp:maxp,
            divisions: 100,
            labels: RangeLabels(_minPrice2.toString(),_maxPrice2.toString() ),
            onChanged: (values) {
              setState(() {
                _minPrice2 = values.start;
                _maxPrice2 = values.end;
                print(_minPrice2);
                print(_maxPrice2);
              });
            },
          ))])


,
   Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Min: '+_minPrice2.toString()),
              SizedBox(width: 10),
              Text('Max: '+_maxPrice2.toString()),
            ],
          ),
          
          
        SizedBox(height: 10)  ,


Row(
              children: [SizedBox(width: 5),Text("Year: "),SizedBox(width: 5),



  Expanded( child:
    RangeSlider(
        activeColor: Colors.black,
  inactiveColor: Color.fromARGB(255, 191, 190, 190),
            values: RangeValues(_minyear2.toDouble(), _maxyear2.toDouble()),
            min:miny>maxy?maxy.toDouble():miny.toDouble(),
            max: miny>maxy?miny.toDouble():maxy.toDouble(),
            divisions: 100,
            labels: RangeLabels(_minyear2.toString(),_maxyear2.toString() ),
            onChanged: (values) {
              setState(() {
                _minyear2 = values.start.toInt();
                _maxyear2 = values.end.toInt();
            
              });
            },
          ))])


,
   Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Min: '+_minyear2.toString()),
              SizedBox(width: 10),
              Text('Max: '+_maxyear2.toString()),
            ],
          )









          ,SizedBox(height: 10),
            ElevatedButton(
              style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.black)),
              child: Text("Filter"),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  CollectionReference carAdsRef = FirebaseFirestore.instance.collection('types');
                  Query query = carAdsRef;
                  if (_manufacturers.isNotEmpty) {
                    query = query.where('manufacturer', whereIn: _manufacturers);
                  }
                  // if (!_models.isEmpty) {
                  //   query = query.where('model', whereIn: _models);
                  // }
                  // if (!(_minyear2==miny)) {
                  //   query = query.where('year', isGreaterThanOrEqualTo: _minyear2);
                  // }
                  // if (!(_maxyear2==maxy)) {
                  //   query = query.where('year', isLessThanOrEqualTo: _maxyear2);
                  // }
                  // if (!(_minPrice2==minp)  ) {
                  //   query = query.where('price', isGreaterThanOrEqualTo: _minPrice2);
                  // }
                  // if (!( _maxPrice2==maxp) ) {
                  //   query = query.where('price', isLessThanOrEqualTo: _maxPrice2);
                  // }
                 
              query.get().then(( snapshot) async {
                 List<String> cars=[];
  List<DocumentSnapshot> carAds = snapshot.docs;
carAds.forEach((document) {
String k=document.id;
    var temp=document.data().toString();
    temp = temp.replaceAllMapped(new RegExp(r'(\w+):'),  (match) =>'"${match[1]}":');
    temp = temp.replaceAllMapped(new RegExp(r': (\w+)'),  (match) =>': "${match[1]}"');
    //print(temp);
    Map<String,dynamic> map =jsonDecode(temp);
 //Car_ad ad=Car_ad.fromJson( jsonDecode(temp)); 
  if ( ((!_models.any((model) =>models[map["manufacturer"]]!.contains(model)) && _manufacturers.isNotEmpty)|| _models.contains(map["model"]))||(_manufacturers.isEmpty &&_models.isEmpty)) 

 {

cars.add(k);

 }
});

print(cars);
List<List<String>> subList = [];
for (var i = 0; i < cars.length; i += 10) {
    subList.add(
        cars.sublist(i, i + 10> cars.length ? cars.length : i + 10));
}
CollectionReference carRef = FirebaseFirestore.instance.collection('cars');
List<String> cars3=[];
int sub1=0;
int len=subList.length;
subList.forEach((element) {

Query query = carRef;
if (!(_minyear2==miny)) {
  query = query.where('year', isGreaterThanOrEqualTo: _minyear2);
}
if (!(_maxyear2==maxy)) {
  query = query.where('year', isLessThanOrEqualTo: _maxyear2);
}
                  if (_manufacturers.isNotEmpty||_models.isNotEmpty) {
                    query = query.where("type_id", whereIn: element);
                  }
query.get().then(( snapshot) async {
                 List<String> cars2=[];
  List<DocumentSnapshot> carAds = snapshot.docs;
carAds.forEach((document) {
String k=document.id;

cars2.add(k);

    });
    

CollectionReference carRef2 = FirebaseFirestore.instance.collection('ads');
List<List<String>> subList2 = [];
int c2=0;
for (var i = 0; i < cars2.length; i += 10) {
    subList2.add(
        cars2.sublist(i, i + 10> cars2.length ? cars2.length : i + 10));
}
subList2.forEach((element2) async {
Query query = carRef2;

if (!(_minPrice2==minp)  ) {
  query = query.where('price', isGreaterThanOrEqualTo: _minPrice2);
}
if (!( _maxPrice2==maxp) ) {
  query = query.where('price', isLessThanOrEqualTo: _maxPrice2);
}

if(!element2.isEmpty)

{query = query.where("car_id", whereIn: element2);
await query.get().then(( snapshot) async {
                 
  List<DocumentSnapshot> carAds = snapshot.docs;
carAds.forEach((document) {
String k=document.id;
c2=c2+1;
cars3.add(k);

    });
 
    });
   } 
       if(c2==cars2.length){ sub1=sub1+1;}
        
        if(c2==cars2.length && sub1==len)
       {
         Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => FilteredScreen(values: cars3 ),
              ),
            );
       }
        
         print("cars3 $cars3");});//batch2
  
    


    });
              });
              print("cars3b1 $cars3");//batch1
  // Display the filtered list of car ads
});

                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
class Car_ad {
  final String manufacturer;
  final String model;
  final int year;
final int price;
  Car_ad({required this.manufacturer,  required this.model,required this.year,required this.price});

  factory Car_ad.fromJson(Map<String, dynamic> json) {
    return Car_ad(
      manufacturer: json['manufacturer'],
      model: json['model'],
      year: int.parse(json['year']),
       price: int.parse(json['price']),
    );
  }}