import 'package:flutter/cupertino.dart';

extension NumExt on num {
  double get e => toDouble();
}

typedef GestureDetectorWithSound = GestureDetector;

enum ToolboxType { album, camera, voice, video, asmr, sleep, drink, cat, gift }
