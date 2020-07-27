import 'dart:ui';

import 'package:flutter/material.dart';

// ignore_for_file: public_member_api_docs

class FloatingSearchBarStyle {
  final Color accentColor;
  final Color backgroundColor;
  final Color shadowColor;
  final Color iconColor;
  final Color backdropColor;
  final EdgeInsetsGeometry margins;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry insets;
  final double height;
  final double elevation;
  final double maxWidth;
  final double openMaxWidth;
  final double axisAlignment;
  final double openAxisAlignment;
  final BorderSide border;
  final BorderRadius borderRadius;
  final TextStyle hintStyle;
  final TextStyle queryStyle;
  const FloatingSearchBarStyle({
    @required this.accentColor,
    @required this.backgroundColor,
    @required this.shadowColor,
    @required this.iconColor,
    @required this.backdropColor,
    @required this.margins,
    @required this.padding,
    @required this.insets,
    @required this.height,
    @required this.elevation,
    @required this.maxWidth,
    @required this.openMaxWidth,
    @required this.axisAlignment,
    @required this.openAxisAlignment,
    @required this.border,
    @required this.borderRadius,
    @required this.hintStyle,
    @required this.queryStyle,
  });

  FloatingSearchBarStyle scaleTo(FloatingSearchBarStyle b, double t) {
    return FloatingSearchBarStyle(
      height: lerpDouble(height, b.height, t),
      elevation: lerpDouble(elevation, b.elevation, t),
      maxWidth: lerpDouble(maxWidth, b.maxWidth, t),
      openMaxWidth: lerpDouble(openMaxWidth, b.openMaxWidth, t),
      axisAlignment: lerpDouble(axisAlignment, b.axisAlignment, t),
      openAxisAlignment: lerpDouble(openAxisAlignment, b.openAxisAlignment, t),
      accentColor: Color.lerp(accentColor, b.accentColor, t),
      backgroundColor: Color.lerp(backgroundColor, b.backgroundColor, t),
      backdropColor: Color.lerp(backdropColor, b.backdropColor, t),
      shadowColor: Color.lerp(shadowColor, b.shadowColor, t),
      iconColor: Color.lerp(iconColor, b.iconColor, t),
      insets: EdgeInsetsGeometry.lerp(insets, b.insets, t),
      margins: EdgeInsetsGeometry.lerp(margins, b.margins, t),
      padding: EdgeInsetsGeometry.lerp(padding, b.padding, t),
      border: BorderSide.lerp(border, b.border, t),
      borderRadius: BorderRadius.lerp(borderRadius, b.borderRadius, t),
      hintStyle: TextStyle.lerp(hintStyle, b.hintStyle, t),
      queryStyle: TextStyle.lerp(queryStyle, b.queryStyle, t),
    );
  }

  @override
  String toString() {
    return 'FloatingSearchBarStyle(accentColor: $accentColor, backgroundColor: $backgroundColor, shadowColor: $shadowColor, iconColor: $iconColor, backdropColor: $backdropColor, margins: $margins, padding: $padding, insets: $insets, height: $height, elevation: $elevation, maxWidth: $maxWidth, openMaxWidth: $openMaxWidth, axisAlignment: $axisAlignment, openAxisAlignment: $openAxisAlignment, border: $border, borderRadius: $borderRadius, hintStyle: $hintStyle, queryStyle: $queryStyle)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is FloatingSearchBarStyle &&
        o.accentColor == accentColor &&
        o.backgroundColor == backgroundColor &&
        o.shadowColor == shadowColor &&
        o.iconColor == iconColor &&
        o.backdropColor == backdropColor &&
        o.margins == margins &&
        o.padding == padding &&
        o.insets == insets &&
        o.height == height &&
        o.elevation == elevation &&
        o.maxWidth == maxWidth &&
        o.openMaxWidth == openMaxWidth &&
        o.axisAlignment == axisAlignment &&
        o.openAxisAlignment == openAxisAlignment &&
        o.border == border &&
        o.borderRadius == borderRadius &&
        o.hintStyle == hintStyle &&
        o.queryStyle == queryStyle;
  }

  @override
  int get hashCode {
    return accentColor.hashCode ^
        backgroundColor.hashCode ^
        shadowColor.hashCode ^
        iconColor.hashCode ^
        backdropColor.hashCode ^
        margins.hashCode ^
        padding.hashCode ^
        insets.hashCode ^
        height.hashCode ^
        elevation.hashCode ^
        maxWidth.hashCode ^
        openMaxWidth.hashCode ^
        axisAlignment.hashCode ^
        openAxisAlignment.hashCode ^
        border.hashCode ^
        borderRadius.hashCode ^
        hintStyle.hashCode ^
        queryStyle.hashCode;
  }
}
