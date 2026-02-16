import 'package:flutter/material.dart';
import 'package:vcontroller/src/layouts/button_diamond.dart';
import 'package:vcontroller/src/services/controller_client.dart';
import 'package:vcontroller/src/widgets/widgets.dart';

class LeftPanel extends StatelessWidget {
  final VControllerClient client;
  const LeftPanel({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
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
                      ControllerButton(
                        bitmask: 256,
                        textContent: "LT",
                        client: client,
                      ),
                      ControllerButton(
                        bitmask: 512,
                        textContent: "LB",
                        client: client,
                      ),
                    ],
                  ),
                ),
              ),
              ButtonDiamond(
                up: ControllerButton(
                  bitmask: 1,
                  textContent: "1",
                  client: client,
                ),
                right: ControllerButton(
                  bitmask: 2,
                  textContent: "2",
                  client: client,
                ),
                down: ControllerButton(
                  bitmask: 4,
                  textContent: "3",
                  client: client,
                ),
                left: ControllerButton(
                  bitmask: 8,
                  textContent: "4",
                  client: client,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: ControllerButton(
                  bitmask: 16384,
                  textContent: "L3",
                  client: client,
                ),
              ),
            ],
          ),
          Positioned(
            // TODO: Sửa Hard Code
            left: 130,
            top: 200,
            child: VirtualJoystick(
              onJoystickChanged: (double x, double y) {
                client.updateLeftJoystick(x, y);
              },
            ),
          ),
        ],
      ),
    );
  }
}
