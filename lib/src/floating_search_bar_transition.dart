import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import 'floating_search_bar.dart';
import 'util/util.dart';
import 'widgets/widgets.dart';

// ignore_for_file: public_member_api_docs

/// Base class for all open/close transitions
/// for a [FloatingSearchBar].
///
/// This class exposes various fields from the [FloatingSearchBar]
/// and lets it interpolate them based on the animation progress.
///
/// See also:
///  * [ExpandingFloatingSearchBarTransition], which expands to eventually fill
///     all of its available space, similar to the ones in Gmail or Google Maps.
///  * [CircularFloatingSearchBarTransition], which clips its child in an
///    expanding circle while animating.
///  * [SlideFadeFloatingSearchBarTransition], which fades and translate its
///    child.
abstract class FloatingSearchBarTransition {
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

/// A [FloatingSearchBarTransition]
/// {@template expanding_floating_search_bar_transition}
/// which expands to eventually fill all of its available space,
/// similar to the ones in Gmail or Google Maps.
///
/// An example of this can be viewed [here](https://github.com/bnxm/material_floating_search_bar/blob/master/assets/expanding_example.gif):
/// {@endtemplate}
class ExpandingFloatingSearchBarTransition extends FloatingSearchBarTransition {
  /// The elevation of the bar to create a lift on scroll effect
  /// when the body of the [FloatingSearchBar] gets scrolled beneath the
  /// bar.
  final double innerElevation;

  /// A divider to be shown between the bar and the body of the [FloatingSearchBar].
  final Widget divider;

  /// Creates a [FloatingSearchBarTransition]
  /// {@macro expanding_floating_search_bar_transition}
  ExpandingFloatingSearchBarTransition({
    this.innerElevation = 8,
    this.divider,
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
  double lerpInnerMaxWidth() => lerpDouble(maxWidth, openMaxWidth, t);

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
  EdgeInsetsGeometry lerpMargin() =>
      EdgeInsetsGeometry.lerp(margin, EdgeInsets.zero, t);

  @override
  BorderRadius lerpBorderRadius() =>
      BorderRadius.lerp(borderRadius, BorderRadius.zero, t);

  @override
  void onBodyScrolled() {
    if (lerpInnerElevation() < innerElevation) rebuild();
  }

  @override
  Widget buildDivider() {
    return Opacity(
      opacity: t,
      child: divider ??
          const Opacity(
            opacity: 0.75,
            child: Divider(
              height: 0,
              thickness: 1,
            ),
          ),
    );
  }
}

/// The base class for all overlaying [FloatingSearchBarTransition]s, which are
/// those, where the body of the [FloatingSearchBar] is displayed outside of the
/// bar.
abstract class OverlayingFloatingSearchBarTransition
    extends FloatingSearchBarTransition {
  /// The vertical spacing between the bar of the [FloatingSearchBar] and its body.
  final double _spacing;

  /// A divider to seperate the body of the [FloatingSearchBar] from the bar.
  ///
  /// Typically this gets revealed when the body has scrolled the amount specifieds
  /// by [spacing].
  final Widget divider;
  // ignore: public_member_api_docs
  OverlayingFloatingSearchBarTransition({
    double spacing,
    this.divider,
  }) : _spacing = spacing;

  double get spacing =>
      _spacing ?? searchBar?.widget?.scrollPadding?.top ?? 0.0;

  @override
  bool get isBodyInsideSearchBar => false;

  bool get reachedTop => spacing <= offset;

  double get scrollT {
    if (spacing == 0.0) {
      return offset <= 0.0 ? 0.0 : 1.0;
    } else {
      return (offset / spacing).clamp(0.0, 1.0) * t;
    }
  }

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
    if (spacing == 0.0) return super.lerpBorderRadius();

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
    final margin = this.margin.resolve(Directionality.of(context)).copyWith(
          top: 0.0,
          bottom: 0.0,
        );

    return Padding(
      padding: margin,
      child: content,
    );
  }

  @override
  void onBodyScrolled() {
    if (offset < spacing) rebuild();
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is OverlayingFloatingSearchBarTransition &&
        o.spacing == spacing &&
        o.divider == divider;
  }

  @override
  int get hashCode => spacing.hashCode ^ divider.hashCode;
}

/// A [FloatingSearchBarTransition]
/// {@template circular_floating_search_bar_transition}
/// which clips its child in an expanding circle.
///
/// An example of this can be viewed [here](https://github.com/bnxm/material_floating_search_bar/blob/master/assets/circular_example.gif):
/// {@endtemplate}
class CircularFloatingSearchBarTransition
    extends OverlayingFloatingSearchBarTransition {
  /// Creates a [FloatingSearchBarTransition],
  /// {@macro circular_floating_search_bar_transition}
  CircularFloatingSearchBarTransition({
    double spacing,
    Widget divider,
  }) : super(
          spacing: spacing,
          divider: divider,
        );

  @override
  Widget buildTransition(Widget content) {
    final spacing = math.max(this.spacing - offset, 0.0);

    return super.buildTransition(
      Transform.translate(
        offset: Offset(0, -spacing * (1 - t)),
        child: CircularReveal(
          fraction: t,
          origin: const Alignment(0.0, 1.0),
          child: content,
        ),
      ),
    );
  }
}

/// A [FloatingSearchBarTransition]
/// {@template fade_in_floating_search_bar_transition}
/// which fades and vertically translates its child.
///
/// An example of this can be viewed [here](https://github.com/bnxm/material_floating_search_bar/blob/master/assets/slide_fade_example.gif)
/// {@endtemplate}
class SlideFadeFloatingSearchBarTransition
    extends OverlayingFloatingSearchBarTransition {
  final double translation;

  /// Creates a [FloatingSearchBarTransition],
  /// {@macro fade_in_floating_search_bar_transition}
  SlideFadeFloatingSearchBarTransition({
    double spacing,
    Widget divider,
    this.translation = 32.0,
  }) : super(
          spacing: spacing,
          divider: divider,
        );

  @override
  Widget buildTransition(Widget content) {
    final offset = lerpDouble(
      translation,
      0.0,
      Curves.easeIn.transform(t),
    );

    return super.buildTransition(
      Transform.translate(
        offset: Offset(0, offset),
        child: Opacity(
          opacity: t,
          child: content,
        ),
      ),
    );
  }
}
