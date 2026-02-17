import 'package:flutter/material.dart';
import 'package:vcontroller/src/services/controller_client.dart';

const double buttonSize = 60; // Cỡ nút
const double textSize = 18; // Cỡ chữ

class ControllerButton extends StatelessWidget {
  final VControllerClient client;
  final int bitmask;
  final String? textContent;
  final Widget? widgetContent;

  const ControllerButton({
    super.key,
    required this.client,
    required this.bitmask,
    this.textContent,
    this.widgetContent,
  });

  void _buttonDown(PointerEvent event) {
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
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          shape: .circle,
          color: Colors.transparent,
          border: Border.all(color: Colors.white),
        ),
        child: Center(
          child: textContent != null
              ? Text(
                  textContent!,
                  style: TextStyle(color: Colors.white, fontSize: textSize),
                )
              : widgetContent,
        ),
      ),
    );
  }
}
