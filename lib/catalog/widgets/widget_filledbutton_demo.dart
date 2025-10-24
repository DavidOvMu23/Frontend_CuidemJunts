import 'package:flutter/material.dart';

Widget widget_filledbutton_demo(
  String texto, {
  VoidCallback? onPressed,
  bool tonal = false,
}) {
  final callback = onPressed ?? () {};
  return tonal
      ? FilledButton.tonal(onPressed: callback, child: Text(texto))
      : FilledButton(onPressed: callback, child: Text(texto));
}
