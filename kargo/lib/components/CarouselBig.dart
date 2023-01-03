import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class CarouselBig extends StatefulWidget {
  var imgList = [];
  bool isURLList;

  CarouselBig({
    required this.imgList,
    this.isURLList = true,
  });

  @override
  _CarouselBigState createState() => _CarouselBigState();
}

class _CarouselBigState extends State<CarouselBig> {
  int _current = 0;
  late List<Image> imgs;
  @override
  void initState() {
    if (widget.isURLList)
      imgs = widget.imgList
          .map(
              (e) => Image.network(e, fit: BoxFit.fill, width: double.infinity))
          .toList();
    else
      imgs = widget.imgList as List<Image>;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> imageSliders = imgs
        .map((item) => Container(
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15)),
                child: Stack(
                  children: [
                    item,
                    Positioned(
                      bottom: 0.0,
                      left: 0.0,
                      right: 0.0,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color.fromARGB(200, 0, 0, 0),
                              Color.fromARGB(0, 0, 0, 0),
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        child: Text(
                          ' ${imgs.indexOf(item) + 1} / ${imgs.length}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ))
        .toList();

    return Column(
      children: [
        CarouselSlider(
          items: imageSliders,
          options: CarouselOptions(
              viewportFraction: 1,
              autoPlay: false,
              enlargeCenterPage: false,
              aspectRatio: 1.1,
              onPageChanged: (index, reason) {
                setState(() {
                  _current = index;
                });
              }),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.imgList.map((url) {
            int index = widget.imgList.indexOf(url);
            return Container(
              width: 10,
              height: 8,
              margin: EdgeInsets.symmetric(vertical: 2, horizontal: 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _current == index
                    ? Color.fromRGBO(0, 0, 0, 0.9)
                    : Color.fromRGBO(0, 0, 0, 0.4),
              ),
            );
          }).toList(),
        )
      ],
    );
  }
}
