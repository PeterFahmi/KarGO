import 'package:flutter/material.dart';
import 'package:kargo/screens/home_page.dart';
import 'package:carousel_slider/carousel_slider.dart';

class Ad_Card extends StatelessWidget {
  var fav = 0;
  var year;
  var manufacturer;
  var model;
  var km;
  var bid;
  var ask;
  List imgUrls = [];

  Ad_Card(
      {required,
      this.model,
      required this.year,
      required this.manufacturer,
      required this.km,
      required this.fav,
      required this.imgUrls,
      required this.bid,
      required this.ask});
  void onPressed() {}

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => HomePage(),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 4,
        color: Colors.black,
        margin: EdgeInsets.all(10),
        child: Column(
          children: [
            // child 1 of column is image + title
            Stack(
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
                            onPressed: onPressed,
                            icon: Icon(
                              Icons.favorite_border,
                              size: 30,
                              color: Colors.black,
                            ))
                        : IconButton(
                            onPressed: onPressed,
                            icon: Icon(
                              Icons.favorite,
                              size: 30,
                              color: Colors.black,
                            ))),
              ],
            ),
            // child 2 of colum is the white row
            Container(
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(5),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$manufacturer $model',
                                style: TextStyle(
                                  color: Colors.yellow,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25.0,
                                )),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('3 hours ago',
                                style: TextStyle(
                                  color: Colors.yellow,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.0,
                                )),
                          ],
                        ),
                      ],
                    ),
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                      Wrap(spacing: 75, children: [
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 13),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text('Ask: $ask LE',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15.0,
                                        )),
                                  ]),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text('Year: $year',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        )),
                                  ])
                            ]),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 14),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text('Bid: $bid LE',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15.0,
                                        )),
                                  ]),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text('KM: $km',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        )),
                                  ])
                            ]),
                      ])
                    ]),
                  ]),
            )
          ],
        ),
      ),
    );
  }
}
