import 'package:flutter/material.dart';
import 'package:vcontroller/src/services/controller_client.dart';
import 'package:vcontroller/src/widgets/fn_button.dart';

class CenterPanel extends StatelessWidget {
  final VControllerClient client;
  const CenterPanel({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: .start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 70),
          child: ControllerFnButton(
            client: client,
            bitmask: 4096,
            iconContent: Icons.arrow_left_rounded,
          ),
        ),
        ControllerFnButton(
          client: client,
          bitmask: 8192,
          iconContent: Icons.arrow_right_rounded,
        ),
      ],
    );
  }
}
