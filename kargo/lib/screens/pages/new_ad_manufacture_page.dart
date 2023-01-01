import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class ManufacturePage extends StatefulWidget {
  static const _subheader = TextStyle(fontWeight: FontWeight.w600);
  final manufacturerDropdownCtrl, modelDropdownCtrl;

  VoidCallback onChanged;

  ManufacturePage(
      {required this.manufacturerDropdownCtrl,
      required this.modelDropdownCtrl,
      required this.onChanged});

  @override
  State<ManufacturePage> createState() => _ManufacturePageState();
}

class _ManufacturePageState extends State<ManufacturePage> {
  var carList = ["audi", "honda", "balabizo"];
  var modelList = ["civic", "corrola", "balabizo"];

  @override
  void initState() {
    CollectionReference types = FirebaseFirestore.instance.collection('types');
    types.get().then((value) {
      for (var doc in value.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final manufacturer = data['manufacturer'];
        final model = data['model'];
        if (!carList.contains(manufacturer)) carList.add(manufacturer);
        if (!modelList.contains(model)) modelList.add(model);
      }
    }).catchError((err) {
      print("err");
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        height: 55,
        padding: EdgeInsets.all(5),
        width: double.infinity,
        color: Color.fromRGBO(0, 0, 0, 0.2),
        child: const Text(
          'Manufacture details',
          style: TextStyle(
              color: Colors.white, fontSize: 40, fontWeight: FontWeight.w700),
        ),
      ),
      Expanded(
          child: Center(
        child: ListView(padding: EdgeInsets.all(15), children: [
          const Text('Car manufacturer', style: ManufacturePage._subheader),
          CustomDropdown.search(
            hintText: 'Select manufacturer',
            items: carList,
            controller: widget.manufacturerDropdownCtrl,
            excludeSelected: false,
            onChanged: (_) {
              widget.onChanged();
            },
          ),
          const Divider(height: 24),
          const Text('Car model', style: ManufacturePage._subheader),
          CustomDropdown.search(
            hintText: 'Select model',
            items: modelList,
            controller: widget.modelDropdownCtrl,
            excludeSelected: false,
            onChanged: (_) => widget.onChanged(),
          ),
        ]),
      ))
    ]);
  }
}
