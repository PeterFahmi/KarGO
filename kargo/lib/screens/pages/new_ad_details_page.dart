import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:stepper_counter_swipe/stepper_counter_swipe.dart';

import '../../components/my_textfield.dart';

class AdDetailsPage extends StatefulWidget {
  static const _subheader = TextStyle(fontWeight: FontWeight.w600);
  final adTitle;
  final adDescription;
  final askPrice;
  final adDuration;
  VoidCallback onChange;
  AdDetailsPage({
    required this.adDescription,
    required this.adTitle,
    required this.adDuration,
    required this.askPrice,
    required this.onChange,
  });

  @override
  State<AdDetailsPage> createState() => _AdDetailsPageState();
}

class _AdDetailsPageState extends State<AdDetailsPage> {
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
            'Ad. details',
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
          ),
        ),
      ),
      Expanded(
          child: Center(
        child: ListView(padding: EdgeInsets.all(15), children: [
          const Text('Ad title', style: AdDetailsPage._subheader),
          MyTextField(
            controller: widget.adTitle,
            labelText: "Title",
            maxLength: 20,
            onSubmitted: widget.onChange,
          ),
          const Divider(height: 24),
          const Text('Ad description', style: AdDetailsPage._subheader),
          MyTextField(
            controller: widget.adDescription,
            labelText: "Description",
            maxLength: 100,
            height: 140.0,
            onSubmitted: widget.onChange,
          ),
          const Divider(height: 24),
          const Text('Ask price', style: AdDetailsPage._subheader),
          MyTextField(
            controller: widget.askPrice,
            labelText: "Ask price",
            keyboardType: TextInputType.number,
            onSubmitted: widget.onChange,
          ),
          const Divider(height: 24),
          const Text('Ad duration', style: AdDetailsPage._subheader),
          MyTextField(
            controller: widget.adDuration,
            labelText: "Days",
            keyboardType: TextInputType.number,
            onSubmitted: widget.onChange,
          ),
        ]),
      ))
    ]);
  }
}
