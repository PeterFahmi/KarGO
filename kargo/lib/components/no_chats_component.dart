import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class NoChatsComponent extends StatelessWidget {
  const NoChatsComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              //TODO: on press, redirect the user to the ads page
              Navigator.of(context).pop();
            },
            child: Icon(
              Icons.ads_click,
              color: Colors.grey[700],
              size: 75,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            "You've not started any conversations, tap on the icon to start looking for ads!",
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
  
  void popUpDialog(BuildContext context) {}
}