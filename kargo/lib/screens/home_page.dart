import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:kargo/components/ad_card2.dart';
import 'package:kargo/components/my_bottom_navigator.dart';
import 'package:kargo/components/my_scaffold.dart';
import 'package:kargo/components/my_shimmering_card.dart';
import 'package:kargo/screens/loading_screen.dart';
import '../components/multiChip.dart';
import '../models/user.dart' as UserModel;
import 'filtered_screen.dart';
import 'my_ads_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    super.initState();
    final fbm = FirebaseMessaging.instance;
    fbm.getToken().then((value) => print(value));
    fbm.requestPermission();
  }

  var _selectedTabIndex = 0;
  List<String> imgUrls = [
    'https://www.hdcarwallpapers.com/download/abt_sportsline_audi_tt-2880x1800.jpg',
    'https://th.bing.com/th/id/OIP.zpu1nHs3RCyeRXikR-nFGgHaFj?pid=ImgDet&w=1600&h=1200&rs=1'
  ];
List<Map<String, String>> ads=[];
  var currentUser = getCurrentUser();
  List<String> searchResults=[];
  int _maxyear2=2000;
int _minyear2=0;
   late double _minPrice2=0;
  late double _maxPrice2=100;
      void initState() {
    super.initState();
getAllAds() ;

    
    }

void getAllAds() async {
  

// Get a reference to the "car_ads" collection
final carAdsRef = FirebaseFirestore.instance.collection('ads');
List<String> models1=[];
// Query the collection to get all documents
final querySnapshot = await carAdsRef.get();

// create a map to store the models for each manufacturer


// Iterate through the car ad documents and get the models for each manufacturer
querySnapshot.docs.forEach((carAdDoc) {
  // get the manufacturer name
  
String k=carAdDoc.id;
setState(() {
  searchResults.add(k);
  getCars();
});




});


return;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: currentUser,
      builder: (BuildContext context,
          AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.hasData) {
          var currentUserModel = createCurrentUserModel(snapshot);
          return MyScaffold(
            body: showTab(_selectedTabIndex),
            bottomNavigationBar: MyBottomNavagationBar(
              notifyParent: onNavigationBarChanged,
            ),
            currentUser: currentUserModel,
            updateUserFunction: updateUserProfile,
          );
        } else if (snapshot.hasError) {
          throw Exception("");
        }
        return LoadingScreen();
      },
    );
  }

  void updateUserProfile(UserModel.User updatedUser) async {
    final currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserUid)
        .update({'name': updatedUser.name, 'photoURL': updatedUser.imagePath});

    setState(() {
      currentUser = getCurrentUser();
    });
  }

  getSnapShotData(mySnapShot) {
    return mySnapShot.data!.data();
  }

  createCurrentUserModel(mySnapShot) {
    var snapShotData = getSnapShotData(mySnapShot);
    var curUserModel = UserModel.User(
        email: snapShotData['email'],
        name: snapShotData['name'],
        imagePath: snapShotData['photoURL']);
    return curUserModel;
  }

  onNavigationBarChanged(index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  Widget showTab(selectedTabIndex) {
    switch (selectedTabIndex) {
      case 0:

        return Column( children:[TextButton(
                        onPressed: Adfilter,
                        child: Text(
                          "Next",
                        
                        )),
                        Expanded( child: ads.length==0? Text("No results found"): ListView.builder(
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
      ))]);
      case 1:
        return Text("fav");
      case 2:
        return Text("bid");
      case 3:
        return MyAdsScreen();
      // return Column(children: [
      //   Ad_Card2(
      //     imgUrls: imgUrls,
      //     manufacturer: "Audi",
      //     model: "RS7",
      //     year: "2021",
      //     km: "9000",
      //     fav: 1,
      //     bid: "1,290,000",
      //     ask: "1,200,000",
      //   ),
      //   Ad_Card2(
      //       imgUrls: imgUrls,
      //       manufacturer: "Audi",
      //       model: "RS7",
      //       year: "2021",
      //       km: "9000",
      //       fav: 0,
      //       bid: "1,290,000",
      //       ask: "1,200,000")
      // ]);
      default:
        return Text("");
    }
  }



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


 Adfilter() {

  final _formKey = GlobalKey<FormState>();
  List<String> _manufacturers = [];
  List<String> _models = [];
  late String _year;
  late String _minyear;
  late String _maxyear;

  
  List<String> availableModels=[];
double minp=1000;
double maxp=0;
int miny=10000;
int maxy=0;
Map<String, List<String>> models={};
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
   
   showModalBottomSheet<dynamic>(
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        context: context,
        builder: (context) {
      return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState1 /*You can rename this!*/) {
           
return 





Wrap(children: <Widget>[
            Container(
              decoration: new BoxDecoration(
                  color: Colors.white,
                  borderRadius: new BorderRadius.only(
                      topLeft: const Radius.circular(25.0),
                      topRight: const Radius.circular(25.0))),
              width: double.infinity,
              child: Column(
                children: [




Form(
        key: _formKey,
        child: Column(
          children: [ Row(
              children: [SizedBox(width: 5),Text("Manufacturers: "),SizedBox(width: 5),
                Expanded( child:
            MultiSelectChip(
              labels: models.keys.toList(),
              onSelectionChanged: (selected) {
                setState1(() {
                  
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
                setState1(() {
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
              setState1(() {
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
              setState1(() {
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
if(cars.isEmpty){
      setState(() {
 searchResults=cars3;
  getCars();
 });
}
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
if(cars2.isEmpty){
      setState(() {
 searchResults=cars3;
 getCars();
 });
}
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
   } print(c2);
    print( sub1);
       if(c2==cars2.length){ sub1=sub1+1;}
        
        if(c2==cars2.length && sub1==len)
       {
      setState(() {
 searchResults=cars3;
  getCars();
 });
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
      )
    //form
                ]))]);
        });}//alala



);
 
});











}


















void getCars () async {
List<Map<String, String>> CarADs=[];
  List<String> carsIDs=searchResults;

 

  Set<String> set = new Set<String>.from(carsIDs);


 carsIDs= new List<String>.from(set);
 
  print(carsIDs);
  if(carsIDs.isEmpty){
        setState(() {
 ads=CarADs;
 });}
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
      // if(element["bid"]!=null)
      //  bid=element["bid"].toString();
       map['askPrice'] = askPrice;

  map['bid'] = bid;



  String carID=element["car_id"];

print(map);
   if(carID!="")
   {  await FirebaseFirestore.instance
  .collection('cars')
  .where(FieldPath.documentId, isEqualTo:carID )
  .get()
  .then((value) {
    value.docs.forEach((element) async {

String km=element["km"].toString();
      String url="https://t3.ftcdn.net/jpg/04/62/93/66/360_F_462936689_BpEEcxfgMuYPfTaIAOC1tCDurmsno7Sp.jpg";
      if(element["photos"]!=null ||!element["photos"].length==0)
      url=element["photos"].join(',').length<5? url:element["photos"].join(',');
String year=element["year"].toString();


  map['url'] = url;
    map['year'] = year;
      map['km'] = km;
      

print(map);

  String typeID=element["type_id"];

if(typeID!="") {
  

 await FirebaseFirestore.instance
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
    }

    });



    });
    }



  });
  });
  
  
  
  });


}


  
}

Future<DocumentSnapshot<Map<String, dynamic>>> getCurrentUser() async {
  final currentUserUid = FirebaseAuth.instance.currentUser!.uid;
  return FirebaseFirestore.instance
      .collection('users')
      .doc(currentUserUid)
      .get();
}
