import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kargo/components/CarouselWithDots.dart';
import 'package:kargo/screens/home_page.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:kargo/services/database_services.dart';

class Ad_Card2 extends StatelessWidget {
  var id;
  var fav = 0;
  var year;
  var manufacturer;
  var model;
  var km;
  var bid;
  var ask;
  String color;
  int daysRemaining;
  List<String> imgUrls = [];

  Ad_Card2(
      { required this.id,
      required this.model,
      required this.year,
      required this.manufacturer,
      required this.km,
      required this.fav,
      required this.imgUrls,
      required this.bid,
      required this.ask, 
      this.color="",
      this.daysRemaining=-1});
  onPressed(){}

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => HomePage(),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 4,
        color: Colors.white60,
        margin: EdgeInsets.all(10),
        child: Column(
          children: [
            // child 1 of column is image + title
            Stack(
              children: [
// child 1 of stack is the recipe image

                CarouselWithDotsPage(imgList: imgUrls),
// child 2 of stack is the recipe title

                Positioned(
                    right: 0,
                    child: fav == 0
                        ? Container(
                            margin: EdgeInsets.all(3.5),
                            width: 40.0,
                            height: 40.0,
                            decoration: new BoxDecoration(
                              color: Colors.white60,
                              shape: BoxShape.circle,
                            ),
                          )
                        : Container(
                            margin: EdgeInsets.all(3.5),
                            width: 40.0,
                            height: 40.0,
                            decoration: new BoxDecoration(
                              color: Colors.white60,
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
            // child 2 of column is the white row
            Container(
              margin: EdgeInsets.all(10),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('${daysRemaining} days remaining',
                                style: TextStyle(
                                  color: Color.fromRGBO(150, 150, 150, 1),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.0,
                                )),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$manufacturer $model $year',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                )),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text('EGP $ask',
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15.0,
                                          )),
                                    ]),
                              ]),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(bid == -1 ? "Be the first to bid!" : 'EGP $bid',
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15.0,
                                          )),
                                    ]),
                              ]),
                        ]),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('Ask Price',
                                style: TextStyle(
                                  color: Color.fromRGBO(150, 150, 150, 1),
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.bold,
                                )),
                          ],
                        ),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(bid == -1 ? "No bids yet" : 'Highest Bid',
                                  style: TextStyle(
                                    color: Color.fromRGBO(150, 150, 150, 1),
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.bold,
                                  )),
                            ]),
                      ],
                    ),
                  ]),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('AUTO',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 13.0,
                      fontWeight: FontWeight.bold,
                    )),
                Container(
                    height: 15,
                    child: VerticalDivider(
                        thickness: 2, color: Color.fromRGBO(150, 150, 150, 1))),
                Text(km.toString() + ' km',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 13.0,
                      fontWeight: FontWeight.bold,
                    )),
                Container(
                    height: 15,
                    child: VerticalDivider(
                        thickness: 2, color: Color.fromRGBO(150, 150, 150, 1))),
                Text(color,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 13.0,
                      fontWeight: FontWeight.bold,
                    )),
              ],
            ),
            SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}
