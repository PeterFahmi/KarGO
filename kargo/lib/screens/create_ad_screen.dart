import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:kargo/components/my_scaffold.dart';
import 'package:kargo/components/my_textfield.dart';

class CreateAdScreen extends StatefulWidget {
  @override
  State<CreateAdScreen> createState() => _CreateAdScreenState();
}

class _CreateAdScreenState extends State<CreateAdScreen> {
  static const _subheader = TextStyle(fontWeight: FontWeight.w600);
  static const _header = TextStyle(fontSize: 20, fontWeight: FontWeight.w800);
  static const list = ["audi", "honda", "balabizo"];
  static const carList = ["audi", "honda", "balabizo"];
  static const modelList = ["civic", "corrola", "balabizo"];
  static const List<String> imgUrls = [
    'https://www.hdcarwallpapers.com/download/abt_sportsline_audi_tt-2880x1800.jpg',
    'https://th.bing.com/th/id/OIP.zpu1nHs3RCyeRXikR-nFGgHaFj?pid=ImgDet&w=1600&h=1200&rs=1'
  ];
  static const fav = 0;

  final manufacturerDropdownCtrl = TextEditingController(),
      modelDropdownCtrl = TextEditingController(),
      yearCtrl = TextEditingController(),
      kmCtrl = TextEditingController(),
      colorCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var carPart = [
      Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 4,
          color: Colors.black,
          margin: EdgeInsets.all(10),
          child: Stack(
            children: [
// child 1 of stack is the recipe image
              ClipRRect(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15)),
                  child: CarouselSlider(
                    options: CarouselOptions(height: 200.0),
                    items: imgUrls.map((i) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            margin: EdgeInsets.symmetric(horizontal: 5.0),
                            decoration: BoxDecoration(color: Colors.amber),
                            child: Image.network(
                              i,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit
                                  .cover, //byzbot shakl image expand to fit box
                            ),
                          );
                        },
                      );
                    }).toList(),
                  )),
// child 2 of stack is the recipe title

              Positioned(
                  right: 0,
                  child: fav == 0
                      ? Container(
                          margin: EdgeInsets.all(3),
                          width: 40.0,
                          height: 40.0,
                          decoration: new BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        )
                      : Container(
                          margin: EdgeInsets.all(3),
                          width: 40.0,
                          height: 40.0,
                          decoration: new BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        )),
              Positioned(
                  right: 0,
                  child: fav == 0
                      ? IconButton(
                          onPressed: null,
                          icon: Icon(
                            Icons.favorite_border,
                            size: 30,
                            color: Colors.black,
                          ))
                      : IconButton(
                          onPressed: null,
                          icon: Icon(
                            Icons.favorite,
                            size: 30,
                            color: Colors.black,
                          ))),
            ],
          )),
      const Text('Car details', style: _header),
      const Divider(
        height: 30,
        thickness: 3,
      ),
      const Text('Car manufacturer', style: _subheader),
      CustomDropdown.search(
        hintText: 'Select manufacturer',
        items: carList,
        controller: manufacturerDropdownCtrl,
        excludeSelected: false,
      ),
      const Divider(height: 24),
      const Text('Car model', style: _subheader),
      CustomDropdown.search(
        hintText: 'Select model',
        items: modelList,
        controller: modelDropdownCtrl,
        excludeSelected: false,
      ),
      const Divider(height: 24),
      const Text('Car model year', style: _subheader),
      MyTextField(
        controller: yearCtrl,
        labelText: "Model year",
        keyboardType: TextInputType.number,
      ),
      const Divider(height: 24),
      const Text('Car km', style: _subheader),
      MyTextField(
        controller: kmCtrl,
        labelText: "Car km",
        keyboardType: TextInputType.number,
      ),
      const Divider(height: 24),
      const Text('Car color', style: _subheader),
      MyTextField(
        controller: colorCtrl,
        labelText: "Car color",
      ),
    ];

    return MyScaffold(
        hasLeading: false,
        body: Container(
          color: Colors.black12,
          child: ListView(
              padding: const EdgeInsets.all(16.0), children: [...carPart]),
        ));
  }
}
