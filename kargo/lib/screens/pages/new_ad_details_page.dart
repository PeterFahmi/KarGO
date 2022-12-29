import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:stepper_counter_swipe/stepper_counter_swipe.dart';

import '../../components/my_textfield.dart';

class AdDetailsPage extends StatefulWidget {
  static const _subheader = TextStyle(fontWeight: FontWeight.w600);
  const AdDetailsPage({super.key});

  @override
  State<AdDetailsPage> createState() => _AdDetailsPageState();
}

class _AdDetailsPageState extends State<AdDetailsPage> {
  final adTitle = TextEditingController();
  final adDescription = TextEditingController();
  final askPrice = TextEditingController();
  final adDuration = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        height: 55,
        padding: EdgeInsets.all(5),
        width: double.infinity,
        color: Color.fromRGBO(0, 0, 0, 0.2),
        child: const Text(
          'Ad. details',
          style: TextStyle(
              color: Colors.white, fontSize: 40, fontWeight: FontWeight.w700),
        ),
      ),
      Expanded(
          child: Center(
        child: ListView(padding: EdgeInsets.all(15), children: [
          const Text('Ad title', style: AdDetailsPage._subheader),
          MyTextField(
            controller: adTitle,
            labelText: "Title",
            maxLength: 20,
          ),
          const Divider(height: 24),
          const Text('Ad description', style: AdDetailsPage._subheader),
          MyTextField(
            controller: adDescription,
            labelText: "Description",
            maxLength: 100,
            height: 140.0,
          ),
          const Divider(height: 24),
          const Text('Ask price', style: AdDetailsPage._subheader),
          MyTextField(
            controller: askPrice,
            labelText: "Ask price",
            keyboardType: TextInputType.number,
          ),
          const Divider(height: 24),
          const Text('Ad duration', style: AdDetailsPage._subheader),
          MyTextField(
            controller: adDuration,
            labelText: "Days",
            keyboardType: TextInputType.number,
          ),
        ]),
      ))
    ]);
  }
}
