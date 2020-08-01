import 'package:flutter/material.dart';

/// A Widget that notifies a parent [FloatingSearchBar] about
/// scroll events of its child [Scrollable].
///
/// This is useful, if you want to implement the common pattern
/// with floating search bars, in which the search bar is hidden
/// when the user scrolls down and shown again when the user scrolls
/// up.
class FloatingSearchBarScrollNotifier extends StatelessWidget {
  /// The vertically scrollable child.
  final Widget child;

  /// Creates a [FloatingSearchBarScrollNotifier].
  ///
  /// This widget is useful, if you want to implement the common pattern
  /// with floating search bars, in which the search bar is hidden
  /// when the user scrolls down and shown again when the user scrolls
  /// up.
  const FloatingSearchBarScrollNotifier({
    Key key,
    @required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        final metrics = notification.metrics;

        // Dispatch the notifcation only for vertical
        // scrollables.
        if (metrics.axis == Axis.vertical) {
          FloatingSearchBarScrollNotification(
            metrics,
            context,
          ).dispatch(context);
        }

        return false;
      },
      child: child,
    );
  }
}

/// The [ScrollNotifcation] used by [FloatingSearchBarScrollNotifier].
class FloatingSearchBarScrollNotification extends ScrollNotification {
  /// Creates a [ScrollNotifcation] used by [FloatingSearchBarScrollNotifier].
  FloatingSearchBarScrollNotification(
    ScrollMetrics metrics,
    BuildContext context,
  ) : super(
          metrics: metrics,
          context: context,
        );
}
