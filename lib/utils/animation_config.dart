import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';


class AnimationConfig {
  static void init() {
    timeDilation = 1.0;
    Animate.restartOnHotReload = true;

    Animate.defaultDuration = 350.ms;
    Animate.defaultCurve = Curves.easeOutCubic;

  }
}