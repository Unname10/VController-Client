import 'package:flutter/material.dart';
import 'package:vcontroller/src/widgets/button.dart';

class CenterPanel extends StatelessWidget {
  const CenterPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: .center,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 100),
          child: ControllerButton(
            bitmask: 4096,
            buttonType: .rounded,
            iconContent: Icons.arrow_left_rounded,
          ),
        ),
        ControllerButton(
          bitmask: 8192,
          buttonType: .rounded,
          iconContent: Icons.arrow_right_rounded,
        ),
      ],
    );
  }
}
