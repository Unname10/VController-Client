import 'package:flutter/material.dart';
import 'package:vcontroller/src/services/controller_client.dart';

const double buttonCircleSize = 65; // Cỡ nút tròn
const double buttonRoundedHeight = 40; // Cỡ nút bo cong
const double buttonRoundedWidth = 70;
const double textSize = 18;
const double size = 40; // Cỡ chữ/biểu tượng

enum ButtonShape { circle, rounded } // Cỡ chữ

class ControllerButton extends StatelessWidget {
  final int bitmask;
  final String? textContent;
  final IconData? iconContent;
  final Widget? widgetContent;
  final ButtonShape buttonType;

  const ControllerButton({
    super.key,
    required this.bitmask,
    this.textContent,
    this.iconContent,
    this.widgetContent,
    this.buttonType = ButtonShape.circle,
  });

  void _buttonDown(PointerEvent event) {
    VControllerClient().updateButton(bitmask, true);
  }

  void _buttonUp(PointerEvent event) {
    VControllerClient().updateButton(bitmask, false);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _buttonDown,
      onPointerUp: _buttonUp,
      onPointerCancel: _buttonUp,
      child: Container(
        width: buttonType == .circle ? buttonCircleSize : buttonRoundedWidth,
        height: buttonType == .circle ? buttonCircleSize : buttonRoundedHeight,
        decoration: buttonType == .circle
            ? BoxDecoration(
                shape: .circle,
                color: Colors.transparent,
                border: Border.all(color: Colors.white),
              )
            : BoxDecoration(
                color: Colors.transparent,
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.all(.circular(30)),
              ),
        child: Center(
          child: textContent != null
              ? Text(
                  textContent!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: textSize,
                  ),
                )
              : Icon(iconContent, size: size, color: Colors.white),
        ),
      ),
    );
  }
}
