import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class CustomSnackBarContent extends StatelessWidget{
  
  const CustomSnackBarContent ({
    Key? key,
     required this.errorText,
   }) : super(key: key);
   final String errorText;
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip. none,
      children: [
        Container(
           
          child: Row(
             children: [
              const SizedBox (width: 48),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Oh snap!",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    )
                    , const Spacer(),
                    Text(
                      errorText,
                       style: const TextStyle(
                        color: Colors.white,
                         fontSize: 12,),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                       ),
                  ],
                ),
              ),
             ],
          ),
        ),

                   ],
                 );
   }
 } // Close Icon
