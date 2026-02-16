import 'package:flutter/material.dart';
import 'package:vcontroller/src/services/controller_client.dart';

const double buttonHeight = 40;
const double buttonWidth = 70; // Chiều cao nút
const double size = 40; // Cỡ chữ/biểu tượng

class ControllerFnButton extends StatelessWidget {
  final VControllerClient client;
  final int bitmask;
  final String? textContent;
  final IconData? iconContent;

  const ControllerFnButton({
    super.key,
    required this.client,
    required this.bitmask,
    this.textContent,
    this.iconContent,
  });

  void _buttonDown(PointerEvent event) {
    print("Nút có bitmask: $bitmask đã được nhấn!");
    client.updateButton(bitmask, true);
  }

  void _buttonUp(PointerEvent event) {
    client.updateButton(bitmask, false);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _buttonDown,
      onPointerUp: _buttonUp,
      onPointerCancel: _buttonUp,
      child: Container(
        height: buttonHeight,
        width: buttonWidth,
        decoration: BoxDecoration(
          color: Colors.lightGreen,
          border: Border.all(),
          borderRadius: BorderRadius.all(.circular(30)),
        ),
        child: Center(
          child: textContent != null
              ? Text(
                  textContent!,
                  style: TextStyle(color: Colors.white, fontSize: size),
                )
              : Icon(iconContent, size: size, color: Colors.white),
        ),
      ),
    );
  }
}
