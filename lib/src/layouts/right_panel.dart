import 'package:flutter/material.dart';
import 'package:vcontroller/src/layouts/button_diamond.dart';
import 'package:vcontroller/src/services/controller_client.dart';
import 'package:vcontroller/src/widgets/widgets.dart';

class RightPanel extends StatelessWidget {
  final VControllerClient client;
  const RightPanel({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        // clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: .end,
            children: [
              Padding(
                padding: .directional(bottom: 10),
                child: SizedBox(
                  width: 180, // TODO: Remove Hard Code
                  child: Flex(
                    direction: Axis.horizontal,
                    mainAxisAlignment: .spaceBetween,
                    children: [
                      ControllerButton(
                        bitmask: 1024,
                        textContent: "RB",
                        client: client,
                      ),
                      ControllerButton(
                        bitmask: 2048,
                        textContent: "RT",
                        client: client,
                      ),
                    ],
                  ),
                ),
              ),
              ButtonDiamond(
                rowDirectional: .end,
                up: ControllerButton(
                  bitmask: 128,
                  textContent: "Y",
                  client: client,
                ),
                right: ControllerButton(
                  bitmask: 32,
                  textContent: "B",
                  client: client,
                ),
                down: ControllerButton(
                  bitmask: 16,
                  textContent: "A",
                  client: client,
                ),
                left: ControllerButton(
                  bitmask: 64,
                  textContent: "X",
                  client: client,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: ControllerButton(
                  bitmask: 32768,
                  textContent: "R3",
                  client: client,
                ),
              ),
            ],
          ),
          Positioned(
            // TODO: Sửa Hard Code
            right: 130,
            top: 200,
            child: VirtualJoystick(
              onJoystickChanged: (double x, double y) {
                client.updateRightJoystick(x, y);
              },
            ),
          ),
        ],
      ),
    );
  }
}
