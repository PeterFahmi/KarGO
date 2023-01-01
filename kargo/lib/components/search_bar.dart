import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class SearchBar extends StatelessWidget {
  SearchBar({super.key});
  TextEditingController searchCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 16,left: 16,right: 16),
        child: TextField(
          controller: searchCtrl,
          decoration: InputDecoration(
            hintText: "Search for chats...",
            hintStyle: TextStyle(color: Colors.grey.shade600),
            prefixIcon: Icon(Icons.search,color: Colors.grey.shade600, size: 20,),
            filled: true,
            fillColor: Colors.grey.shade100,
            contentPadding: EdgeInsets.all(8),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                  color: Colors.grey.shade100
              )
            ),
          ),
        ),
      ),
    );
  }

  // getSearchController(){
  //   return searchCtrl;
  // }
}