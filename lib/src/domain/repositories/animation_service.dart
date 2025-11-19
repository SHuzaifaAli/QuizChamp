import 'package:flutter/widgets.dart';

abstract class AnimationService {
  Widget buildCorrectAnimation();
  Widget buildIncorrectAnimation();
  Widget buildTimeoutAnimation();
  Duration get animationDuration;
}