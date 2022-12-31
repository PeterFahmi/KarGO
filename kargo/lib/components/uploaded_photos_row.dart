import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class UploadedPhotosRow extends StatelessWidget {
  List<Image> imgs;
  Function? removeCallback;
  UploadedPhotosRow({required this.imgs, required this.removeCallback});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 250,
        height: 70,
        child: ListView(
            scrollDirection: Axis.horizontal,
            children: (imgs.map((e) {
              var stack = Stack(children: [
                Container(
                    color: Colors.grey,
                    margin:
                        EdgeInsets.only(top: 10, right: 10, left: 5, bottom: 5),
                    height: 50,
                    width: 50,
                    child: e),
                if (removeCallback != null)
                  Positioned(
                      right: 0,
                      child: Container(
                        margin: EdgeInsets.all(3.5),
                        width: 20.0,
                        height: 20.0,
                        decoration: new BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                            padding: EdgeInsets.all(0),
                            onPressed: () => removeCallback!(e),
                            icon: Icon(
                              Icons.close,
                              size: 15,
                              color: Colors.black,
                            )),
                      )),
              ]);
              return stack;
            }).toList())));
  }
}
