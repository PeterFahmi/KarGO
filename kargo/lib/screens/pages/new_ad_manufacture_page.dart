import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import '../../models/ad.dart';

import '../../components/my_textfield.dart';

class ManufacturePage extends StatefulWidget {
  static const _subheader = TextStyle(fontWeight: FontWeight.w600);
  TextEditingController manufacturerDropdownCtrl,
      modelDropdownCtrl,
      transmissionCtrl,
      manufacturerOtherCtrl,
      modelOtherCtrl;
  Ad? ad;
  VoidCallback onChanged;

  ManufacturePage({
    this.ad,
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
  bool hasLoaded = false;
  bool isReady = false;

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
      setState(() {
        isReady = true;
        print(isReady);
      });
    }).catchError((err) {
      print("err");
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final myWidget = Column(children: [
      Container(
        height: 55,
        padding: EdgeInsets.all(5),
        width: double.infinity,
        color: Colors.black,
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
          getCustomDropDown(
              'Select manufacturer', carList, widget.manufacturerDropdownCtrl,
              (_) {
            chooseManufacturer();
          }, widget.ad, 1, hasLoaded, isReady),
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
            getCustomDropDown(
              'Select model',
              modelList,
              widget.modelDropdownCtrl,
              (_) => widget.onChanged(),
              widget.ad,
              2,
              hasLoaded,
              isReady,
            ),
          ],
          if (widget.modelDropdownCtrl.text == "other..." &&
              (widget.manufacturerDropdownCtrl.text != 'other...' ||
                  widget.manufacturerOtherCtrl.text.isNotEmpty))
            MyTextField(
              controller: widget.modelOtherCtrl,
              labelText: "Specify model",
              onSubmitted: widget.onChanged,
            ),
          const Divider(height: 24),
          const Text('Transmission', style: ManufacturePage._subheader),
          getCustomDropDown(
              'Select Transmission',
              transmissionList,
              widget.transmissionCtrl,
              (_) => widget.onChanged(),
              widget.ad,
              3,
              hasLoaded,
              isReady)
        ]),
      ))
    ]);
    hasLoaded = true;
    return myWidget;
  }

  void chooseManufacturer() {
    widget.modelDropdownCtrl.value = TextEditingValue(text: "other...");
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

  Widget getCustomDropDown(
      hintText, itemsList, ctrl, onChgd, Ad? ad, type, hasLoaded, isReady) {
    var wdgt = CustomDropdown.search(
      hintText: hintText,
      items: itemsList,
      controller: ctrl,
      excludeSelected: false,
      onChanged: onChgd,
    );
    if (ad != null && !hasLoaded) {
      if (type == 1) {
        // print(isReady);
        // if (isReady)
        //   ctrl.value = TextEditingValue(text: ad.manufacturer.toString());
      } else if (type == 2) {
        // if (isReady)
        //   FirebaseFirestore.instance
        //       .collection('types')
        //       .where('manufacturer',
        //           isEqualTo: widget.manufacturerDropdownCtrl.text)
        //       .get()
        //       .then((value) {
        //     setState(() {
        //       modelList = ['other...'];
        //     });
        //     for (var doc in value.docs) {
        //       final data = doc.data() as Map<String, dynamic>;
        //       final model = data['model'];
        //       if (!modelList.contains(model)) {
        //         setState(() {
        //           modelList.add(model);
        //         });
        //       }
        //     }
        //     ctrl.value = TextEditingValue(text: ad.model.toString());
        //   });
      } else {
        ctrl.value =
            TextEditingValue(text: ad.auto == 0 ? 'Automatic' : 'Manual');
      }
    }
    return wdgt;
  }
}
