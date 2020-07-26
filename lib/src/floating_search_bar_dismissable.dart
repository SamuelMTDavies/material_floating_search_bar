
import 'package:flutter/material.dart';

import 'floating_search_bar.dart';
import 'util/util.dart';

class FloatingSearchBarDismissable extends StatefulWidget {
  final Widget child;

  /// The amount of space by which to inset the child.
  final EdgeInsets padding;

  /// An object that can be used to control the position to which this scroll
  /// view is scrolled.
  ///
  /// Must be null if [primary] is true.
  ///
  /// A [ScrollController] serves several purposes. It can be used to control
  /// the initial scroll position (see [ScrollController.initialScrollOffset]).
  /// It can be used to control whether the scroll view should automatically
  /// save and restore its scroll position in the [PageStorage] (see
  /// [ScrollController.keepScrollOffset]). It can be used to read the current
  /// scroll position (see [ScrollController.offset]), or change it (see
  /// [ScrollController.animateTo]).
  final ScrollController controller;

  /// How the scroll view should respond to user input.
  ///
  /// For example, determines how the scroll view continues to animate after the
  /// user stops dragging the scroll view.
  ///
  /// Defaults to matching platform conventions.
  final ScrollPhysics physics;

  const FloatingSearchBarDismissable({
    Key key,
    @required this.child,
    this.padding,
    this.controller,
    this.physics,
  })  : assert(child != null),
        super(key: key);

  @override
  _FloatingSearchBarDismissableState createState() => _FloatingSearchBarDismissableState();
}

class _FloatingSearchBarDismissableState<E> extends State<FloatingSearchBarDismissable> {
  final _key = GlobalKey();

  double _listHeight = 0;
  double _tapDy = 0;

  void _measure() => postFrame(() {
        _listHeight = _key?.height;
      });

  @override
  Widget build(BuildContext context) {
    _measure();

    return Stack(
      children: <Widget>[
        GestureDetector(
          onTapDown: (details) => _tapDy = details.localPosition.dy,
          onPanDown: (details) => _tapDy = details.localPosition.dy,
          onPanUpdate: (details) => _tapDy = details.localPosition.dy,
          onTap: () {
            if (_tapDy > _listHeight) {
              FloatingSearchBar.of(context).close();
            }
          },
          child: SingleChildScrollView(
            controller: widget.controller,
            physics: widget.physics,
            padding: widget.padding,
            child: NotificationListener<SizeChangedLayoutNotification>(
              onNotification: (_) {
                _measure();
                return true;
              },
              child: SizeChangedLayoutNotifier(
                key: _key,
                child: widget.child,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
