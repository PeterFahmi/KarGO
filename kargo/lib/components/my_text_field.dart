import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  double inset;
  String label;
  bool? obscureText;
  TextEditingController controller;
  Function? onChanged;
  MyTextField(
      {super.key,
      required this.inset,
      required this.label,
      this.obscureText,
      this.onChanged,
      required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(inset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          TextField(
            style: TextStyle(height: 0.5),
            obscureText: obscureText ?? false,
            onChanged: ((value) {
              if (onChanged != null) onChanged!();
            }),
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
