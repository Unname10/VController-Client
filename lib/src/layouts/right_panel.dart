import 'package:flutter/material.dart';
import 'package:vcontroller/src/layouts/button_diamond.dart';
import 'package:vcontroller/src/services/controller_client.dart';
import 'package:vcontroller/src/widgets/widgets.dart';

class RightPanel extends StatelessWidget {
  const RightPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      // clipBehavior: Clip.none,
      children: [
        Column(
          crossAxisAlignment: .end,
          children: [
            Padding(
              padding: .directional(bottom: 10),
              child: SizedBox(
                width: 190, // TODO: Remove Hard Code
                child: Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    ControllerButton(bitmask: 1024, textContent: "RB"),
                    ControllerButton(bitmask: 2048, textContent: "RT"),
                  ],
                ),
              ),
            ),
            ButtonDiamond(
              rowDirectional: .end,
              up: ControllerButton(bitmask: 128, textContent: "Y"),
              right: ControllerButton(bitmask: 32, textContent: "B"),
              down: ControllerButton(bitmask: 16, textContent: "A"),
              left: ControllerButton(bitmask: 64, textContent: "X"),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: ControllerButton(bitmask: 32768, textContent: "R3"),
            ),
          ],
        ),
        Positioned(
          // TODO: Sửa Hard Code
          right: 170,
          top: 200,
          child: VirtualJoystick(
            onJoystickChanged: (double x, double y) {
              VControllerClient().updateRightJoystick(x, y);
            },
          ),
        ),
      ],
    );
  }
}
