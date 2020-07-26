import 'package:flutter/material.dart';

export 'extensions.dart';
export 'handler.dart';

double interval(double begin, double end, double t, {Curve curve = Curves.linear}) {
  assert(t != null);

  final v = ((t - begin) / (end - begin)).clamp(0.0, 1.0);
  return curve.transform(v);
}

void postFrame(VoidCallback callback) {
  assert(callback != null);
  WidgetsBinding.instance.addPostFrameCallback((_) => callback());
}
