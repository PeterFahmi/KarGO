import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:kargo/screens/home_page.dart';

class noInternet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // backgroundColor: Colors.green[200],
        body: Center(
            child: Container(
                height: 500,
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Image(
                      image: AssetImage('assets/images/pngWifi.png'),
                      width: 200,
                      height: 200,
                    )
                  ]),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 30),
                        Text("NO INTERNET",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w300,
                            )),
                        Text("CONNECTION",
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                            )),
                        Text("Please Check Your Connection and Try Again!",
                            style: TextStyle(
                              fontSize: 14,
                              //     fontWeight: FontWeight,
                            )),
                        SizedBox(height: 45),
                      ]),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                          onPressed: () => {Navigator.pushNamed(context, '/')},
                          child: Text('   Try Again   ',
                              style: TextStyle(
                                  color: Colors.white,
                                  //fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.black),
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                      side: BorderSide(color: Colors.black)))))
                    ],
                  )
                ]))));
  }
}
