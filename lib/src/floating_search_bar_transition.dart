import 'dart:ui';

import 'package:flutter/material.dart';

import 'floating_search_bar.dart';
import 'util/util.dart';
import 'widgets/widgets.dart';


abstract class FloatingSearchBarTransition {
  bool get isExpanding => this is ExpandingFloatingSearchBarTransition;

  FloatingSearchBarState searchBar;
  BuildContext get context => searchBar?.context;
  Animation get animation => searchBar?.animation;
  double get t => searchBar?.value;

  double get offset => searchBar?.offset ?? 0.0;
  double get fullHeight => context?.height ?? height;
  double get fullWidth => context?.width ?? 0.0;
  double get height => searchBar?.height;
  double get elevation => searchBar?.elevation;
  EdgeInsetsGeometry get padding => searchBar?.padding;
  EdgeInsetsGeometry get margin => searchBar?.margins;
  Color get backgroundColor => searchBar?.backgroundColor;
  BorderRadius get borderRadius => searchBar?.borderRadius;
  double get maxWidth => searchBar?.maxWidth;
  double get openMaxWidth => searchBar?.openMaxWidth;

  bool get isBodyInsideSearchBar;
  Color get backdropColor => Colors.black38;

  double lerpHeight() => height;
  double lerpElevation() => elevation;
  double lerpInnerElevation() => 0.0;
  double lerpMaxWidth() => lerpDouble(maxWidth, openMaxWidth, t);
  double lerpInnerMaxWidth() => lerpMaxWidth();
  EdgeInsetsGeometry lerpPadding() => padding;
  EdgeInsetsGeometry lerpMargin() => margin;
  Color lerpBackgroundColor() => backgroundColor;
  BorderRadius lerpBorderRadius() => borderRadius;

  Widget buildTransition(Widget content) => content;
  Widget buildDivider() => const SizedBox(height: 0);
  void onBodyScrolled() {}

  void rebuild() => searchBar?.rebuild();

  @override
  // ignore: hash_and_equals
  bool operator ==(dynamic other) => other.runtimeType == runtimeType;
}

class ExpandingFloatingSearchBarTransition extends FloatingSearchBarTransition {
  final double expandedMaxWidth;
  final double innerElevation;
  ExpandingFloatingSearchBarTransition({
    this.expandedMaxWidth,
    this.innerElevation = 12,
  });

  @override
  bool get isBodyInsideSearchBar => true;

  @override
  Color get backdropColor => Colors.transparent;

  @override
  double lerpHeight() => lerpDouble(height, fullHeight, t);

  @override
  double lerpMaxWidth() => lerpDouble(maxWidth, fullWidth, t);

  @override
  double lerpInnerMaxWidth() => lerpDouble(maxWidth, expandedMaxWidth ?? maxWidth, t);

  @override
  double lerpInnerElevation() {
    return lerpDouble(
        0.0, innerElevation, (offset / (innerElevation * 10)).clamp(0.0, 1.0));
  }

  @override
  EdgeInsetsGeometry lerpPadding() {
    final p = padding.resolve(Directionality.of(context));
    final margin = this.margin.resolve(Directionality.of(context));

    return EdgeInsetsGeometry.lerp(
      padding,
      EdgeInsets.only(left: p.left, right: p.right, top: margin.top),
      t,
    );
  }

  @override
  EdgeInsetsGeometry lerpMargin() => EdgeInsetsGeometry.lerp(margin, EdgeInsets.zero, t);

  @override
  BorderRadius lerpBorderRadius() =>
      BorderRadius.lerp(borderRadius, BorderRadius.zero, t);

  @override
  void onBodyScrolled() {
    if (lerpInnerElevation() < innerElevation) rebuild();
  }
}

abstract class OverlayingFloatingSearchBarTransition extends FloatingSearchBarTransition {
  final EdgeInsetsGeometry contentMargin;
  final double topScrollPadding;
  final Widget divider;
  OverlayingFloatingSearchBarTransition({
    EdgeInsetsGeometry margin,
    this.topScrollPadding = 0.0,
    this.divider,
  }) : contentMargin = margin;

  @override
  bool get isBodyInsideSearchBar => false;

  bool get reachedTop => topScrollPadding <= offset;

  double get scrollT =>
      topScrollPadding == 0.0 ? 0.0 : (offset / topScrollPadding).clamp(0.0, 1.0) * t;

  @override
  Widget buildDivider() {
    return Opacity(
      opacity: scrollT,
      child: divider ??
          Container(
            height: 2 * scrollT,
            color: Theme.of(context).dividerColor,
          ),
    );
  }

  @override
  BorderRadius lerpBorderRadius() {
    if (topScrollPadding == 0.0) return super.lerpBorderRadius();

    return BorderRadius.lerp(
      borderRadius,
      BorderRadius.only(
        topLeft: borderRadius.topLeft,
        topRight: borderRadius.topRight,
        bottomLeft: Radius.zero,
        bottomRight: Radius.zero,
      ),
      scrollT,
    );
  }

  @override
  Widget buildTransition(Widget content) {
    final margin = this.margin.resolve(Directionality.of(context));
    final startMargin = EdgeInsets.only(
      left: margin.left,
      right: margin.right,
    );

    return Padding(
      padding: EdgeInsets.lerp(startMargin, contentMargin, t),
      child: buildChildTransition(content),
    );
  }

  Widget buildChildTransition(Widget content);

  @override
  void onBodyScrolled() {
    if (offset < topScrollPadding) rebuild();
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is OverlayingFloatingSearchBarTransition &&
        o.contentMargin == contentMargin &&
        o.topScrollPadding == topScrollPadding &&
        o.divider == divider;
  }

  @override
  int get hashCode =>
      contentMargin.hashCode ^ topScrollPadding.hashCode ^ divider.hashCode;
}

class CircularRevealFloatingSearchBarTransition
    extends OverlayingFloatingSearchBarTransition {
  CircularRevealFloatingSearchBarTransition({
    EdgeInsets margin = const EdgeInsets.symmetric(horizontal: 8),
    double topScrollPadding = 0.0,
    Widget divider,
  }) : super(
          margin: margin,
          topScrollPadding: topScrollPadding,
          divider: divider,
        );

  @override
  Widget buildChildTransition(Widget content) {
    return Transform.translate(
      offset: Offset(0, -16 * (1 - t)),
      child: CircularReveal(
        fraction: t,
        origin: const Alignment(0.0, 1.0),
        child: content,
      ),
    );
  }
}

class FadeInFloatingSearchBarTransition extends OverlayingFloatingSearchBarTransition {
  final double translation;
  FadeInFloatingSearchBarTransition({
    EdgeInsetsGeometry margin = const EdgeInsets.symmetric(horizontal: 8),
    double topScrollPadding = 0.0,
    Widget divider,
    this.translation,
  }) : super(
          margin: margin,
          topScrollPadding: topScrollPadding,
          divider: divider,
        );

  @override
  Widget buildChildTransition(Widget content) {
    final translation = this.translation ??
        height + contentMargin.resolve(Directionality.of(context)).top;

    return Transform.translate(
      offset: Offset(0, -translation * (1 - Curves.easeIn.transform(t))),
      child: Opacity(
        opacity: t,
        child: content,
      ),
    );
  }
}
