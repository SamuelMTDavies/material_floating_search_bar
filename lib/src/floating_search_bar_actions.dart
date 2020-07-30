import 'package:flutter/material.dart';

import 'floating_search_bar.dart';
import 'util/util.dart';
import 'widgets/widgets.dart';

/// A widget to display in a row before or after the
/// input text of a [FloatingSearchBar].
///
/// Typically this widget wraps a [CircularButton].
class FloatingSearchBarAction extends StatefulWidget {
  /// The action.
  ///
  /// Typically a [CircularButton].
  final Widget child;

  /// A builder that can be used when the action needs
  /// to react to changes in its [FloatingSearchBar].
  ///
  /// View [FloatingSearchBarAction.searchToClear] for an example.
  final Widget Function(BuildContext context, Animation animation) builder;

  /// Whether this action should be shown when the [FloatingSearchBar]
  /// is opened.
  ///
  /// If false, this action will be animated out when the
  /// bar [FloatingSearchBar] closed.
  final bool showIfOpened;

  /// Whether this action should be shown when the [FloatingSearchBar]
  /// is closed.
  ///
  /// If false, this action will be animated out when the
  /// bar [FloatingSearchBar] closed.
  final bool showIfClosed;

  /// Creates a widget to be displayed in a row before or after the
  /// input text of a [FloatingSearchBar].
  ///
  /// Typically this widget wraps a [CircularButton].
  const FloatingSearchBarAction({
    Key key,
    this.child,
    this.builder,
    this.showIfOpened = false,
    this.showIfClosed = true,
  })  : assert(builder != null || child != null),
        super(key: key);

  /// Whether this [FloatingSearchBarAction] is shown when opened
  /// and when closed.
  bool get isAlwaysShown => showIfOpened && showIfClosed;

  /// A hamburger menu that when tapped opens the [Drawer]
  /// of the nearest [Scaffold].
  ///
  /// When the [FloatingSearchBar] opens, the hamburger
  /// transitions into a back button.
  factory FloatingSearchBarAction.hamburgerToBack({
    double size = 24,
    Color color,
    bool showIfOpened,
    bool showIfClosed,
  }) {
    return FloatingSearchBarAction(
      showIfOpened: showIfOpened ?? true,
      showIfClosed: showIfClosed ?? true,
      builder: (context, animation) {
        return CircularButton(
          size: size,
          onPressed: () {
            final searchBar = FloatingSearchBar.of(context);
            if (searchBar?.isOpen == true) {
              searchBar?.close();
            } else {
              Scaffold.of(context)?.openDrawer();
            }
          },
          icon: AnimatedIcon(
            icon: AnimatedIcons.menu_arrow,
            progress: animation,
            color: color ?? FloatingSearchBar.of(context)?.iconColor,
            size: size,
          ),
        );
      },
    );
  }

  /// A search icon that transitions into a clear icon
  /// when the query of the [FloatingSearchBar] is not empty.
  factory FloatingSearchBarAction.searchToClear({
    double size = 24,
    Color color,
    bool showIfOpened,
    bool showIfClosed,
    Duration duration = const Duration(milliseconds: 900),
  }) {
    return FloatingSearchBarAction(
      showIfOpened: showIfOpened ?? true,
      showIfClosed: showIfClosed ?? true,
      builder: (context, animation) {
        final searchBar = FloatingSearchBar.of(context);

        return ValueListenableBuilder<String>(
          valueListenable: searchBar.queryListener,
          builder: (context, value, _) {
            final isEmpty = value.isEmpty;

            return _SearchToClear(
              isEmpty: isEmpty,
              size: size,
              color: color ?? searchBar?.iconColor,
              duration: (duration ?? searchBar.duration) * 0.5,
              onTap: () {
                if (!isEmpty) {
                  searchBar.clear();
                } else {
                  searchBar.isOpen = !searchBar.isOpen;
                }
              },
            );
          },
        );
      },
    );
  }

  /// A convenience factory to wrap an [Icon] or an [IconData]
  /// into an action.
  factory FloatingSearchBarAction.icon({
    @required dynamic icon,
    @required VoidCallback onTap,
    double size = 24.0,
    bool showIfOpened = false,
    bool showIfClosed = true,
  }) {
    assert(size != null);
    assert(icon != null);
    assert(onTap != null);

    return FloatingSearchBarAction(
      child: CircularButton(
        size: size,
        icon: icon is IconData ? Icon(icon) : icon,
        onPressed: onTap,
      ),
      showIfClosed: showIfClosed,
      showIfOpened: showIfOpened,
    );
  }

  @override
  _FloatingSearchBarActionState createState() =>
      _FloatingSearchBarActionState();
}

class _FloatingSearchBarActionState extends State<FloatingSearchBarAction> {
  @override
  Widget build(BuildContext context) {
    if (widget.child != null) {
      return widget.child;
    }

    final searchBar = FloatingSearchBar.of(context);
    assert(searchBar != null);

    return widget.builder(context, searchBar.animation);
  }
}

class _SearchToClear extends StatelessWidget {
  final bool isEmpty;
  final Duration duration;
  final VoidCallback onTap;
  final Color color;
  final double size;
  const _SearchToClear({
    Key key,
    @required this.isEmpty,
    this.duration = const Duration(milliseconds: 500),
    @required this.onTap,
    this.color,
    this.size = 24.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedValue(
      value: isEmpty ? 0.0 : 1.0,
      duration: duration,
      builder: (context, value) {
        return CircularButton(
          onPressed: onTap,
          icon: CustomPaint(
            size: Size.square(size),
            painter: _SearchToClearPainter(
              color ?? Theme.of(context).iconTheme.color,
              value,
            ),
          ),
        );
      },
    );
  }
}

class _SearchToClearPainter extends CustomPainter {
  final Color color;
  final double progress;
  _SearchToClearPainter(
    this.color,
    this.progress,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final t = progress;

    final circleProgress = interval(0.0, 0.4, t, curve: Curves.easeIn);
    final lineProgress = interval(0.3, 0.8, t, curve: Curves.ease);
    final sLineProgress = interval(0.5, 1.0, t, curve: Curves.easeOut);

    canvas.clipRect(Rect.fromLTWH(0, 0, w, h));
    const padding = 0.225;
    canvas.translate(w * (padding / 2), h * (padding / 2));
    canvas.scale(1 - padding, 1 - padding);

    final sw = w * 0.125;
    final paint = Paint()
      ..color = color
      ..isAntiAlias = true
      ..strokeWidth = sw
      ..style = PaintingStyle.stroke;

    final radius = w * 0.26;
    final offset = radius + (sw / 2);

    // Draws the handle of the loop.
    final lineStart = Offset(radius * 2, radius * 2);
    final lineEnd = Offset(sw, sw);
    canvas.drawLine(
      Offset.lerp(lineStart, lineEnd, lineProgress),
      Offset(w - sw, h - sw),
      paint,
    );

    // Draws the circle of the loop.
    final circleStart = Offset(offset, offset);
    final circleEnd = Offset(-offset, -offset);
    final circle = Path()
      ..addArc(
        Rect.fromCircle(
          center: Offset.lerp(circleStart, circleEnd, lineProgress),
          radius: radius,
        ),
        32.0.radians,
        (360 * (1 - circleProgress)).radians,
      );
    canvas.drawPath(circle, paint);

    // Draws the second line that will make the cross.
    final sLineStart = Offset(sw, h - sw);
    final sLineEnd = Offset(w - sw, sw);
    canvas.drawLine(
      sLineStart,
      Offset.lerp(sLineStart, sLineEnd, sLineProgress),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
