import 'package:flutter/material.dart';
import 'package:vcontroller/src/layouts/button_diamond.dart';
import 'package:vcontroller/src/services/controller_client.dart';
import 'package:vcontroller/src/widgets/widgets.dart';

class LeftPanel extends StatelessWidget {
  const LeftPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      // clipBehavior: Clip.none,
      children: [
        Column(
          crossAxisAlignment: .start,
          children: [
            Padding(
              padding: .directional(bottom: 10),
              child: SizedBox(
                width: 180, // TODO: Remove Hard Code
                child: Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    ControllerButton(bitmask: 256, textContent: "LT"),
                    ControllerButton(bitmask: 512, textContent: "LB"),
                  ],
                ),
              ),
            ),
            ButtonDiamond(
              up: ControllerButton(bitmask: 1, textContent: "1"),
              right: ControllerButton(bitmask: 2, textContent: "2"),
              down: ControllerButton(bitmask: 4, textContent: "3"),
              left: ControllerButton(bitmask: 8, textContent: "4"),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: ControllerButton(bitmask: 16384, textContent: "L3"),
            ),
          ],
        ),
        Positioned(
          // TODO: Sửa Hard Code
          left: 140,
          top: 200,
          child: VirtualJoystick(
            onJoystickChanged: (double x, double y) {
              VControllerClient().updateLeftJoystick(x, y);
            },
          ),
        ),
      ],
    );
  }
}
