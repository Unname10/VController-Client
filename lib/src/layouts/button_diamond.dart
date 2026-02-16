import 'package:flutter/material.dart';

const double gap = 60;

class ButtonDiamond extends StatelessWidget {
  final Widget up;
  final Widget right;
  final Widget down;
  final Widget left;
  final MainAxisAlignment rowDirectional;
  const ButtonDiamond({
    super.key,
    required this.up,
    required this.right,
    required this.down,
    required this.left,
    this.rowDirectional = .start,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: rowDirectional,
            children: [
              Placeholder(
                // Todo: Remove Hard code
                fallbackHeight: gap,
                fallbackWidth: gap,
                color: Colors.transparent,
              ),
              up,
              Placeholder(
                // Todo: Remove Hard code
                fallbackHeight: gap,
                fallbackWidth: gap,
                color: Colors.transparent,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: rowDirectional,
            children: [
              left,
              Placeholder(
                // Todo: Remove Hard code
                fallbackHeight: gap,
                fallbackWidth: gap,
                color: Colors.transparent,
              ),
              right,
            ],
          ),
          Row(
            mainAxisAlignment: rowDirectional,
            children: [
              Placeholder(
                // Todo: Remove Hard code
                fallbackHeight: gap,
                fallbackWidth: gap,
                color: Colors.transparent,
              ),
              down,
              Placeholder(
                // Todo: Remove Hard code
                fallbackHeight: gap,
                fallbackWidth: gap,
                color: Colors.transparent,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
