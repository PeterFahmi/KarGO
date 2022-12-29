import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class MyTextField extends StatefulWidget {
  final controller;
  final keyboardType;
  final labelText;
  final maxLength;
  final height;
  VoidCallback onSubmitted;
  MyTextField(
      {required this.controller,
      required this.onSubmitted,
      this.keyboardType = TextInputType.text,
      required this.labelText,
      this.maxLength,
      this.height});
  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: getHeight(),
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
        maxLength: widget.maxLength,
        maxLines: widget.maxLength == null ? 1 : null,
        onChanged: ((value) {
          widget.onSubmitted();
        }),
      ),
    );
  }

  getHeight() {
    if (widget.height != null) return widget.height;
    if (widget.maxLength != null) return 100.0;
    return 45.0;
  }
}
