import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 15),
      child: Center(
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeShimmer(
                  height: 150,
                  width: 300,
                  radius: 10,
                  millisecondsDelay: 2,
                  fadeTheme: FadeTheme.light,
                ),
                SizedBox(
                  height: 6,
                ),
                FadeShimmer(
                  height: 12,
                  width: 300,
                  radius: 10,
                  millisecondsDelay: 20,
                  fadeTheme: FadeTheme.light,
                ),
                SizedBox(
                  height: 6,
                ),
                FadeShimmer(
                  height: 12,
                  width: 300,
                  radius: 10,
                  millisecondsDelay: 20,
                  fadeTheme: FadeTheme.light,
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
            Divider(
              thickness: 1,
            )
          ],
        ),
      ),
    );
  }
}
