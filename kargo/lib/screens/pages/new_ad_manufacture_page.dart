import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import '../../components/my_textfield.dart';

class ManufacturePage extends StatefulWidget {
  static const _subheader = TextStyle(fontWeight: FontWeight.w600);
  TextEditingController manufacturerDropdownCtrl,
      modelDropdownCtrl,
      transmissionCtrl,
      manufacturerOtherCtrl,
      modelOtherCtrl;

  VoidCallback onChanged;

  ManufacturePage({
    required this.manufacturerDropdownCtrl,
    required this.modelDropdownCtrl,
    required this.transmissionCtrl,
    required this.onChanged,
    required this.manufacturerOtherCtrl,
    required this.modelOtherCtrl,
  });

  @override
  State<ManufacturePage> createState() => _ManufacturePageState();
}

class _ManufacturePageState extends State<ManufacturePage> {
  var carList = ["other..."];
  var modelList = ["other..."];
  var transmissionList = ["Automatic", "Manual"];

  @override
  void initState() {
    CollectionReference types = FirebaseFirestore.instance.collection('types');
    types.get().then((value) {
      for (var doc in value.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final manufacturer = data['manufacturer'];
        if (!carList.contains(manufacturer)) carList.add(manufacturer);
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
        color: Colors.green[400],
        child: Center(
          child: const Text(
            'Manufacture details',
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
          ),
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
              chooseManufacturer();
            },
          ),
          if (widget.manufacturerDropdownCtrl.text == "other...")
            MyTextField(
              controller: widget.manufacturerOtherCtrl,
              labelText: "Specify manufacturer",
              onSubmitted: widget.onChanged,
            ),
          if (widget.manufacturerDropdownCtrl.text.isNotEmpty &&
              (widget.manufacturerDropdownCtrl.text != 'other...' ||
                  widget.manufacturerOtherCtrl.text.isNotEmpty)) ...[
            const Divider(height: 24),
            const Text('Car model', style: ManufacturePage._subheader),
            CustomDropdown.search(
              hintText: 'Select model',
              items: modelList,
              controller: widget.modelDropdownCtrl,
              excludeSelected: false,
              onChanged: (_) => widget.onChanged(),
            ),
          ],
          if (widget.modelDropdownCtrl.text == "other...")
            MyTextField(
              controller: widget.modelOtherCtrl,
              labelText: "Specify model",
              onSubmitted: widget.onChanged,
            ),
          const Divider(height: 24),
          const Text('Transmission', style: ManufacturePage._subheader),
          CustomDropdown.search(
            hintText: 'Select Transmission',
            items: transmissionList,
            controller: widget.transmissionCtrl,
            excludeSelected: false,
            onChanged: (_) => widget.onChanged(),
          ),
        ]),
      ))
    ]);
  }

  void chooseManufacturer() {
    FirebaseFirestore.instance
        .collection('types')
        .where('manufacturer', isEqualTo: widget.manufacturerDropdownCtrl.text)
        .get()
        .then((value) {
      setState(() {
        modelList = ['other...'];
      });
      for (var doc in value.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final model = data['model'];
        if (!modelList.contains(model)) {
          setState(() {
            modelList.add(model);
          });
        }
      }
    });
    widget.onChanged();
  }
}
