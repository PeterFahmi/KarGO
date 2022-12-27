import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class MyTextField extends StatefulWidget {
  final controller;
  final keyboardType;
  final labelText;
  MyTextField(
      {required this.controller,
      this.keyboardType = TextInputType.text,
      required this.labelText});
  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: TextField(
        decoration: InputDecoration(
            floatingLabelBehavior: FloatingLabelBehavior.never,
            border: InputBorder.none,
            labelText: widget.labelText,
            labelStyle: TextStyle(color: Colors.grey, fontSize: 17)),
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        style: TextStyle(fontSize: 20),
      ),
    );
  }
}
