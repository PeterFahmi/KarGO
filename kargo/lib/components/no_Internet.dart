import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

class noInternet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                margin: EdgeInsets.all(15),
                color: Color.fromRGBO(239, 235, 235, 1),
                borderOnForeground: true,
                elevation: 4,
                child: Container(
                    height: 100,
                    child: Center(
                        child: Text("Please Check Your Internet Connection!",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            )))))));
  }
}
