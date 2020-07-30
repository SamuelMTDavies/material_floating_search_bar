import 'dart:math';

import 'package:flutter/material.dart';

import 'package:material_floating_search_bar/material_floating_search_bar.dart';

import 'floating_search_bar_actions.dart';
import 'floating_search_bar_dismissable.dart';
import 'floating_search_bar_style.dart';
import 'floating_search_bar_transition.dart';
import 'text_controller.dart';
import 'util/util.dart';
import 'widgets/widgets.dart';

// ignore_for_file: public_member_api_docs

typedef FloatingSearchBarBuilder = Widget Function(
    BuildContext context, Animation<double> transition);

typedef OnQueryChangeCallback = void Function(String query);

typedef OnFocusChangeCallback = void Function(bool isFocused);

/// An expandable material floating search bar with customizable
/// transitions similar to the ones used extensively
/// by Google in their apps.
class FloatingSearchBar extends ImplicitAnimation {
  /// The widget displayed below the [FloatingSearchBar].
  ///
  /// This is useful, if the [FloatingSearchBar] should react
  /// to scroll events (i.e. hide from view when a [Scrollable]
  /// is being scrolled down and show it again when scrolled up).
  final Widget body;
  // * --- Style properties --- *

  /// The color used for elements such as the progress
  /// indicator.
  ///
  /// Defaults to the themes accent color if not specified.
  final Color accentColor;

  /// The color of the card.
  ///
  /// If not specified, defaults to `theme.cardColor`.
  final Color backgroundColor;

  /// The color of the shadow drawn when `elevation > 0`.
  ///
  /// If not specified, defaults to `Colors.black54`.
  final Color shadowColor;

  /// When specified, overrides the themes icon color for
  /// this [FloatingSearchBar], for example to easily adjust
  /// the icon color for all [actions] and [startActions].
  final Color iconColor;

  /// The color that fills the available space when the
  /// [FloatingSearchBar] is opened.
  ///
  /// Typically a black-ish color.
  ///
  /// If not specified, defaults to `Colors.black26`.
  final Color backdropColor;

  /// The insets from the edges of its parent.
  ///
  /// This can be used to position the [FloatingSearchBar].
  ///
  /// If not specifed, the [FloatingSearchBar] will try to
  /// position itself at the top offsetted by
  /// `MediaQuery.of(context).viewPadding.top` to avoid
  /// the status bar.
  final EdgeInsetsGeometry margins;

  /// The padding of the card.
  ///
  /// Only the horizontal values will be honored.
  final EdgeInsetsGeometry padding;

  /// The padding between [startActions], the input field and [actions],
  /// respectively.
  ///
  /// Only the horizontal values will be honored.
  final EdgeInsetsGeometry insets;

  /// The height of the card.
  ///
  /// If not specified, defaults to `48.0` pixels.
  final double height;

  /// The elevation of the card.
  ///
  /// See also:
  /// * [shadowColor] to adjust the color of the shadow.
  final double elevation;

  /// The max width of the [FloatingSearchBar].
  ///
  /// By default the [FloatingSearchBar] will expand
  /// to fill all the available width. This value can
  /// be set to avoid this.
  final double maxWidth;

  /// The max width of the [FloatingSearchBar] when opened.
  ///
  /// This can be used, when the max width when opened should
  /// be different from the one specified by [maxWidth].
  ///
  /// When not specified, will use the value of [maxWidth].
  final double openMaxWidth;

  /// How the [FloatingSearchBar] should be aligned when the
  /// available width is bigger than the width specified by [maxWidth].
  ///
  /// When not specified, defaults to `0.0` which centers
  /// the [FloatingSearchBar].
  final double axisAlignment;

  /// How the [FloatingSearchBar] should be aligned when the
  /// available width is bigger than the width specified by [openMaxWidth].
  ///
  /// When not specified, will use the value of [axisAlignment].
  final double openAxisAlignment;

  /// The border of the card.
  final BorderSide border;

  /// The [BorderRadius] of the card.
  ///
  /// When not specified, defaults to `BorderRadius.circular(4)`.
  final BorderRadius borderRadius;

  /// The [TextStyle] for the hint in the [TextField].
  final TextStyle hintStyle;

  /// The [TextStyle] for the input of the [TextField].
  final TextStyle queryStyle;

  // * --- Utility --- *
  /// Whether the current query should be cleared when
  /// the [FloatingSearchBar] was closed.
  ///
  /// When not specifed, defaults to `true`.
  final bool clearQueryOnClose;

  /// Whether a hamburger menu should be shown when
  /// there is a [Scaffold] with a [Drawer] in the widget
  /// tree.
  ///
  /// When not specified, defaults to `true`.
  final bool showDrawerHamburger;

  /// Whether the [FloatingSearchBar] should be closed when
  /// the backdrop was tapped.
  ///
  /// When not specified, defaults to `true`.
  final bool closeOnBackdropTap;

  /// The progress of the [LinearProgressIndicator] inside the card.
  ///
  /// When set to a `double` between [0..1], will show
  /// show a determined [LinearProgressIndicator].
  ///
  /// When set to `true`, the [FloatingSearchBar] will
  /// show an indetermined [LinearProgressIndicator].
  ///
  /// When `null` or `false`, will hide the [LinearProgressIndicator].
  ///
  /// When not specified, defaults to `null`.
  final dynamic progress;

  /// The duration of the animation between opened and closed
  /// state.
  final Duration transitionDuration;

  /// The curve for the animation between opened and closed
  /// state.
  final Curve transitionCurve;

  /// The delay between the time the user stopped typing
  /// and the invocation of the [onQueryChanged] callback.
  ///
  /// This is useful for example if you want to avoid doing
  /// expensive tasks, such as making a network call, for every
  /// single character.
  final Duration debounceDelay;

  /// A widget that is shown in place of the [TextField] when the
  /// [FloatingSearchBar] is closed.
  final Widget title;

  /// The text value of the hint of the [TextField].
  final String hint;

  /// A list of widgets displayed in a row after the [TextField].
  ///
  /// Consider using [FloatingSearchBarAction]s for more advanced
  /// actions that can interact with the [FloatingSearchBar].
  ///
  /// In LTR languages, they will be displayed to the left of
  /// the [TextField].
  final List<Widget> actions;

  /// A list of widgets displayed in a row before the [TextField].
  ///
  /// Consider using [FloatingSearchBarAction]s for more advanced
  /// actions that can interact with the [FloatingSearchBar].
  ///
  /// In LTR languages, they will be displayed to the right of
  /// the [TextField].
  final List<Widget> startActions;

  /// A callback that gets invoked when the input of
  /// the query inside the [TextField] changed.
  ///
  /// See also:
  ///   * [debounceDelay] to delay the invocation of the callback
  ///   until the user stopped typing.
  final OnQueryChangeCallback onQueryChanged;

  /// A callback that gets invoked when the user submitted
  /// their query (e.g. hit the search button).
  final OnQueryChangeCallback onSubmitted;

  /// A callback that gets invoked when the [FloatingSearchBar]
  /// receives or looses focus.
  final OnFocusChangeCallback onFocusChanged;

  /// The transition to be used for animating between closed
  /// and opened state.
  ///
  /// See also:
  ///  * [FloatingSearchBarTransition], which is the base class for all transitions
  ///    and can be used to create your own custom transition.
  ///  * [ExpandingFloatingSearchBarTransition], which expands to eventually fill
  ///    all of its available space, similar to the ones in Gmail or Google Maps.
  ///  * [CircularFloatingSearchBarTransition], which clips its child in an
  ///    expanding circle while animating.
  ///  * [SlideFadeFloatingSearchBarTransition], which fades and translate its
  ///    child.
  final FloatingSearchBarTransition transition;

  /// The builder for the body of this [FloatingSearchBar].
  ///
  /// Usually, a list of items. Note that unless [isScrollControlled]
  /// is set to `true`, the body of a [FloatingSearchBar] must not
  /// have an unbounded height meaning that `shrinkWrap` should be set
  /// to `true` on all [Scrollable]s.
  final FloatingSearchBarBuilder builder;

  /// The controller for this [FloatingSearchBar] which can be used
  /// to programatically open, close, show or hide the [FloatingSearchBar].
  final FloatingSearchBarController controller;

  /// The [TextInputAction] to be used by the [TextField]
  /// of this [FloatingSearchBar].
  final TextInputAction textInputAction;

  /// The [TextInputType] of the [TextField]
  /// of this [FloatingSearchBar].
  final TextInputType textInputType;

  /// Enable or disable autocorrection of the [TextField] of
  /// this [FloatingSearchBar].
  final bool autocorrect;

  /// The [ToolbarOptions] of the [TextField] of
  /// this [FloatingSearchBar].
  final ToolbarOptions toolbarOptions;

  // * --- Scrolling --- *
  /// Whether the body of this [FloatingSearchBar] is using its
  /// own [Scrollable].
  ///
  /// This will allow the body of the [FloatingSearchBar] to have an
  /// unbounded height.
  ///
  /// Note that when set to `true`, the [FloatingSearchBar] won't be able
  /// to dismiss itself when tapped below the height of child inside the
  /// [Scrollable], when the child is smaller than the avaialble height.
  final bool isScrollControlled;

  /// The [ScrollPhysics] of the [SingleChildScrollView] for the body of
  /// this [FloatingSearchBar].
  final ScrollPhysics physics;

  /// The [ScrollController] of the [SingleChildScrollView] for the body of
  /// this [FloatingSearchBar].
  final ScrollController scrollController;

  /// The [EdgeInsets] of the [SingleChildScrollView] for the body of
  /// this [FloatingSearchBar].
  final EdgeInsets scrollPadding;
  const FloatingSearchBar({
    Key key,
    Duration implicitDuration = const Duration(milliseconds: 600),
    Curve implicitCurve = Curves.linear,
    this.body,
    this.accentColor,
    this.backgroundColor,
    this.shadowColor = Colors.black87,
    this.iconColor,
    this.backdropColor,
    this.margins,
    this.padding,
    this.insets,
    this.height = 48.0,
    this.elevation = 4.0,
    this.maxWidth,
    this.openMaxWidth,
    this.axisAlignment = 0.0,
    this.openAxisAlignment,
    this.border,
    this.borderRadius = const BorderRadius.all(Radius.circular(4)),
    this.hintStyle,
    this.queryStyle,
    this.clearQueryOnClose = true,
    this.showDrawerHamburger = true,
    this.closeOnBackdropTap = true,
    this.progress = false,
    this.transitionDuration = const Duration(milliseconds: 500),
    this.transitionCurve = Curves.ease,
    this.debounceDelay = Duration.zero,
    this.title,
    this.hint = 'Search...',
    this.actions,
    this.startActions,
    this.onQueryChanged,
    this.onSubmitted,
    this.onFocusChanged,
    this.transition,
    @required this.builder,
    this.controller,
    this.textInputAction = TextInputAction.search,
    this.textInputType,
    this.autocorrect = true,
    this.toolbarOptions,
    this.isScrollControlled = true,
    this.physics,
    this.scrollController,
    this.scrollPadding = const EdgeInsets.symmetric(vertical: 16),
  })  : assert(builder != null),
        assert(progress == null || (progress is num || progress is bool)),
        super(key, implicitDuration, implicitCurve);

  @override
  _FloatingSearchBarState createState() => _FloatingSearchBarState();

  static FloatingSearchBarState of(BuildContext context) {
    return context.findAncestorStateOfType<FloatingSearchBarState>();
  }
}

class _FloatingSearchBarState
    extends ImplicitAnimationState<FloatingSearchBarStyle, FloatingSearchBar> {
  bool get hasActions => actions.isNotEmpty;
  List<Widget> get actions {
    final actions = widget.actions ?? [FloatingSearchBarAction.searchToClear()];
    final hasEndDrawer = Scaffold.of(context)?.hasEndDrawer ?? false;
    final showHamburgerMenu = hasEndDrawer && widget.showDrawerHamburger;
    return showHamburgerMenu
        ? <Widget>[...actions, FloatingSearchBarAction.hamburgerToBack()]
        : actions;
  }

  bool get hasStartActions => startActions.isNotEmpty;
  List<Widget> get startActions {
    final actions = widget.startActions ?? const <Widget>[];
    final hasDrawer = Scaffold.of(context)?.hasDrawer ?? false;
    final showHamburgerMenu = hasDrawer && widget.showDrawerHamburger;
    return showHamburgerMenu
        ? <Widget>[FloatingSearchBarAction.hamburgerToBack(), ...actions]
        : actions;
  }

  @override
  FloatingSearchBarStyle get newValue {
    final theme = Theme.of(context);

    return FloatingSearchBarStyle(
      height: widget.height ?? 48.0,
      elevation: widget.elevation ?? 4.0,
      maxWidth: widget.maxWidth,
      openMaxWidth: widget.openMaxWidth ?? widget.maxWidth,
      axisAlignment: widget.axisAlignment ?? 0.0,
      openAxisAlignment: widget.openAxisAlignment ?? widget.axisAlignment ?? 0.0,
      accentColor: widget.accentColor ?? theme.accentColor,
      backgroundColor: widget.backgroundColor ?? theme.cardColor,
      iconColor: widget.iconColor ?? theme.iconTheme.color,
      backdropColor:
          widget.backdropColor ?? widget.transition.backdropColor ?? Colors.black26,
      shadowColor: widget.shadowColor ?? Colors.black54,
      border: widget.border ?? BorderSide.none,
      borderRadius: widget.borderRadius ?? BorderRadius.circular(4),
      margins: widget.margins ??
          EdgeInsets.fromLTRB(8, MediaQuery.of(context).viewPadding.top + 6, 8, 0),
      padding: widget.padding ??
          EdgeInsetsDirectional.only(
              start: hasStartActions ? 12 : 0, end: hasActions ? 12 : 0),
      insets: widget.insets ??
          EdgeInsetsDirectional.only(
              start: hasStartActions ? 16 : 24, end: hasActions ? 16 : 24),
      hintStyle: widget.hintStyle,
      queryStyle: widget.queryStyle,
    );
  }

  @override
  FloatingSearchBarStyle lerp(
          FloatingSearchBarStyle a, FloatingSearchBarStyle b, double t) =>
      a.scaleTo(b, t);

  @override
  Widget builder(BuildContext context, FloatingSearchBarStyle style) {
    return _FloatingSearchBar(
      body: widget.body,
      style: style,
      clearQueryOnClose: widget.clearQueryOnClose,
      showDrawerHamburger: widget.showDrawerHamburger,
      closeOnBackdropTap: widget.closeOnBackdropTap,
      progress: widget.progress,
      transitionDuration: widget.transitionDuration,
      transitionCurve: widget.transitionCurve,
      debounceDelay: widget.debounceDelay,
      title: widget.title,
      hint: widget.hint,
      actions: actions,
      startActions: startActions,
      onQueryChanged: widget.onQueryChanged,
      onFocusChanged: widget.onFocusChanged,
      onSubmitted: widget.onSubmitted,
      transition: widget.transition,
      bodyBuilder: widget.builder,
      controller: widget.controller,
      textInputAction: widget.textInputAction,
      textInputType: widget.textInputType,
      autocorrect: widget.autocorrect,
      toolbarOptions: widget.toolbarOptions,
      isScrollControlled: widget.isScrollControlled,
      physics: widget.physics,
      scrollController: widget.scrollController,
      scrollPadding: widget.scrollPadding,
    );
  }
}

class _FloatingSearchBar extends StatefulWidget {
  final Widget body;
  final FloatingSearchBarStyle style;

  // * --- Utility --- *
  final bool clearQueryOnClose;
  final bool showDrawerHamburger;
  final bool closeOnBackdropTap;
  final dynamic progress;
  final Duration transitionDuration;
  final Curve transitionCurve;
  final Duration debounceDelay;
  final Text title;
  final dynamic hint;
  final List<Widget> actions;
  final List<Widget> startActions;
  final OnQueryChangeCallback onQueryChanged;
  final OnFocusChangeCallback onFocusChanged;
  final OnQueryChangeCallback onSubmitted;
  final FloatingSearchBarTransition transition;
  final FloatingSearchBarBuilder bodyBuilder;
  final FloatingSearchBarController controller;
  final TextInputAction textInputAction;
  final TextInputType textInputType;
  final bool autocorrect;
  final ToolbarOptions toolbarOptions;

  // * --- Scrolling --- *
  final bool isScrollControlled;
  final ScrollPhysics physics;
  final ScrollController scrollController;
  final EdgeInsets scrollPadding;
  const _FloatingSearchBar({
    Key key,
    @required this.body,
    @required this.style,
    @required this.clearQueryOnClose,
    @required this.showDrawerHamburger,
    @required this.closeOnBackdropTap,
    @required this.progress,
    @required this.transitionDuration,
    @required this.transitionCurve,
    @required this.debounceDelay,
    @required this.title,
    @required this.hint,
    @required this.actions,
    @required this.startActions,
    @required this.onQueryChanged,
    @required this.onFocusChanged,
    @required this.onSubmitted,
    @required this.transition,
    @required this.bodyBuilder,
    @required this.controller,
    @required this.textInputAction,
    @required this.textInputType,
    @required this.autocorrect,
    @required this.toolbarOptions,
    @required this.isScrollControlled,
    @required this.physics,
    @required this.scrollController,
    @required this.scrollPadding,
  }) : super(key: key);

  @override
  FloatingSearchBarState createState() => FloatingSearchBarState();
}

class FloatingSearchBarState extends State<_FloatingSearchBar>
    with SingleTickerProviderStateMixin {
  dynamic get progress => widget.progress;

  FloatingSearchBarStyle get style => widget.style;
  double get height => style.height;
  double get elevation => style.elevation;
  double get maxWidth => style.maxWidth;
  double get openMaxWidth => style.openMaxWidth;
  double get axisAlignment => style.axisAlignment;
  double get openAxisAlignment => style.openAxisAlignment;

  Color get accentColor => style.accentColor;
  Color get backgroundColor => style.backgroundColor;
  Color get iconColor => style.iconColor;
  Color get backdropColor => style.backdropColor;
  Color get shadowColor => style.shadowColor;

  BorderRadius get borderRadius => style.borderRadius;

  EdgeInsetsGeometry get margins => style.margins;
  EdgeInsetsGeometry get padding => style.padding;
  EdgeInsetsGeometry get insets => style.insets;

  Text get title => widget.title;
  String get hint => widget.hint?.toString() ?? '';

  Curve get curve => widget.transitionCurve;
  Duration get duration => widget.transitionDuration;
  Duration get queryCallbackDelay => widget.debounceDelay;

  TextController _input;
  final Handler _handler = Handler();

  AnimationController _controller;
  CurvedAnimation _animation;
  CurvedAnimation get animation => _animation;
  Animation _queryToTitleAnimation;
  Duration get implicitDuration => const Duration(milliseconds: 400);

  FloatingSearchBarTransition transition;

  ScrollController _scrollController;

  bool _isOpen = false;
  bool get isOpen => _isOpen;
  set isOpen(bool value) {
    if (value == isOpen) return;

    _isOpen = value;
    widget.onFocusChanged?.call(isOpen);

    if (isOpen) {
      _input.requestFocus();
      _controller.forward();
    } else {
      _input.clearFocus(context);
      _controller.reverse();
    }

    setState(() {});
  }

  bool _isVisible = true;
  bool get isVisible => _isVisible;
  set isVisible(bool value) {
    if (value == isVisible) return;

    // Only hide the bar when it is not opened.
    if (!isOpen || value) {
      _isVisible = value;
      setState(() {});
    }
  }

  final ValueNotifier<String> queryListener = ValueNotifier('');
  String get query => queryListener.value;
  set query(String value) => _input.text = value;

  final ValueNotifier<int> _barRebuilder = ValueNotifier(0);
  void rebuild() => _barRebuilder.value++;

  double _offset = 0.0;
  double get offset => _offset;

  double get value => _animation.value;
  bool get isAnimating => _controller.isAnimating;

  @override
  void initState() {
    super.initState();
    _input = TextController()
      ..addListener(() {
        queryListener.value = _input.text;

        _handler.post(
          // Do not add a delay when the query is empty.
          query.isEmpty ? Duration.zero : queryCallbackDelay,
          () => widget.onQueryChanged?.call(query),
        );
      });

    _controller = AnimationController(vsync: this, duration: duration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.dismissed) {
          _onClosed();
        }
      });

    _animation = CurvedAnimation(parent: _controller, curve: curve);
    _queryToTitleAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 1),
    ]).animate(animation);

    transition = widget.transition ?? SlideFadeFloatingSearchBarTransition();

    _scrollController = widget.scrollController ?? ScrollController();

    _assignController();
  }

  @override
  void didUpdateWidget(_FloatingSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (curve != oldWidget.transitionCurve) {
      _animation = CurvedAnimation(parent: _controller, curve: curve);
    }

    if (duration != oldWidget.transitionDuration) {
      _controller.duration = duration;
    }

    if (widget.transition != null && widget.transition != transition) {
      transition = widget.transition;
    }

    if (widget.controller != null) {
      _assignController();
    }

    if (widget.scrollController != null && widget.scrollController != _scrollController) {
      _scrollController = widget.scrollController;
    }
  }

  void _assignController() {
    final controller = widget.controller;
    if (controller == null) return;

    controller._open = open;
    controller._close = close;
    controller._clear = clear;
    controller._show = show;
    controller._hide = hide;
  }

  void open() => isOpen = true;
  void close() => isOpen = false;

  void show() => isVisible = true;
  void hide() => isVisible = false;

  void clear() => _input.clear();

  Future<bool> _onPop() async {
    if (isOpen) {
      close();
      return false;
    }

    return true;
  }

  void _onClosed() {
    _offset = 0.0;
    _scrollController.jumpTo(0.0);

    if (widget.clearQueryOnClose) clear();
  }

  EdgeInsets toEdgeInsets(EdgeInsetsGeometry insets) =>
      insets.resolve(Directionality.of(context));

  bool _onBodyScroll(ScrollNotification notification) {
    _offset = notification.metrics.pixels;
    transition.onBodyScrolled();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    transition.searchBar = this;

    final searchBar = SizedBox.expand(
      child: WillPopScope(
        onWillPop: _onPop,
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) => _onBodyScroll(notification),
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, _) {
              return Stack(
                children: <Widget>[
                  _buildBackdrop(),
                  _buildSearchBar(),
                ],
              );
            },
          ),
        ),
      ),
    );

    if (widget.body != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          widget.body,
          searchBar,
        ],
      );
    } else {
      return searchBar;
    }
  }

  Widget _buildSearchBar() {
    final isInside = transition.isBodyInsideSearchBar;
    final boxConstraints =
        BoxConstraints(maxWidth: transition.lerpMaxWidth() ?? double.infinity);

    final bar = ValueListenableBuilder(
      valueListenable: _barRebuilder,
      builder: (context, __, _) {
        final padding = toEdgeInsets(transition.lerpPadding());
        final borderRadius = transition.lerpBorderRadius();

        final container = Semantics(
          hidden: !isVisible,
          focusable: true,
          focused: isOpen,
          child: Padding(
            padding: transition.lerpMargin(),
            child: Material(
              elevation: transition.lerpElevation(),
              shadowColor: shadowColor,
              borderRadius: borderRadius,
              child: Container(
                height: transition.lerpHeight(),
                padding: EdgeInsets.only(top: padding.top, bottom: padding.bottom),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: transition.lerpBackgroundColor(),
                  border:
                      style.border != null ? Border.fromBorderSide(style.border) : null,
                  borderRadius: borderRadius,
                ),
                constraints: boxConstraints,
                child: ClipRRect(
                  borderRadius: borderRadius,
                  child: Stack(
                    children: <Widget>[
                      _buildInnerBar(),
                      _buildProgressBar(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        return GestureDetector(
          onTap: () => isOpen = !isOpen,
          child: AnimatedTranslation(
            duration: duration,
            translation: Offset(0.0, isVisible ? 0.0 : -1.0),
            isFractional: true,
            curve: Curves.ease,
            child: container,
          ),
        );
      },
    );

    if (isInside) return bar;

    return AnimatedAlign(
      duration: isAnimating ? duration : Duration.zero,
      curve: widget.transitionCurve,
      alignment: Alignment(isOpen ? openAxisAlignment : axisAlignment, 0.0),
      child: Column(
        children: <Widget>[
          bar,
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildInnerBar() {
    Widget buildShader({bool isLeft}) {
      final insets = toEdgeInsets(this.insets);

      return Align(
        alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
        child: Transform.rotate(
          angle: isLeft ? pi : 0.0,
          child: Container(
            width: isLeft ? insets.left + 2 : insets.right,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  backgroundColor.withOpacity(0.0),
                  backgroundColor.withOpacity(1.0),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final content = Row(
      children: <Widget>[
        ..._mapActions(widget.startActions),
        Expanded(
          child: Stack(
            alignment: Alignment.centerLeft,
            children: <Widget>[
              _buildTextField(),
              buildShader(isLeft: true),
              buildShader(isLeft: false),
            ],
          ),
        ),
        ..._mapActions(widget.actions),
      ],
    );

    final padding = toEdgeInsets(transition.lerpPadding());

    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          if (transition.isBodyInsideSearchBar && value > 0.0)
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.only(top: height),
                child: _buildBody(),
              ),
            ),
          Material(
            elevation: transition.lerpInnerElevation(),
            shadowColor: shadowColor,
            child: Container(
              height: height,
              color: transition.lerpBackgroundColor(),
              alignment: Alignment.topCenter,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    constraints: maxWidth != null
                        ? BoxConstraints(maxWidth: transition.lerpInnerMaxWidth())
                        : null,
                    padding: EdgeInsets.only(left: padding.left, right: padding.right),
                    child: content,
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: transition.buildDivider(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final body = transition.buildTransition(
      FloatingSearchBarDismissable(
        controller: _scrollController,
        padding: widget.scrollPadding,
        physics: widget.physics,
        child: widget.bodyBuilder(context, animation),
      ),
    );

    return IgnorePointer(
      ignoring: widget.isScrollControlled && value < 1.0,
      child: Container(
        constraints: maxWidth != null
            ? BoxConstraints(
                maxWidth: maxWidth + transition.lerpMargin().horizontal,
              )
            : null,
        child: body,
      ),
    );
  }

  Widget _buildTextField() {
    final hasQuery = !widget.clearQueryOnClose && query.isNotEmpty;
    final showTitle = widget.title != null || (!hasQuery && query.isNotEmpty);
    final opacity = showTitle ? _queryToTitleAnimation.value : 1.0;

    final showTextInput = showTitle ? _controller.value > 0.5 : _controller.value > 0.0;

    Widget input;
    if (showTextInput) {
      input = IntrinsicWidth(
        child: TextField(
          controller: _input,
          scrollPhysics: const NeverScrollableScrollPhysics(),
          focusNode: _input.node,
          maxLines: 1,
          autofocus: false,
          autocorrect: widget.autocorrect,
          toolbarOptions: widget.toolbarOptions,
          cursorColor: accentColor,
          style: style.queryStyle,
          textInputAction: widget.textInputAction,
          keyboardType: widget.textInputType,
          onSubmitted: widget.onSubmitted,
          decoration: InputDecoration.collapsed(
            hintText: hint,
            hintStyle: style.hintStyle,
          ),
        ),
      );
    } else {
      if (widget.title != null) {
        input = widget.title;
      } else {
        final theme = Theme.of(context);
        final textTheme = theme.textTheme;

        final textStyle = hasQuery
            ? style.queryStyle ?? textTheme.subtitle1
            : style.hintStyle ?? textTheme.subtitle1.copyWith(color: theme.hintColor);

        input = Text(
          hasQuery ? query : widget.hint,
          style: textStyle,
          maxLines: 1,
        );
      }
    }

    return SingleChildScrollView(
      padding: insets,
      scrollDirection: Axis.horizontal,
      child: Opacity(
        opacity: opacity,
        child: input,
      ),
    );
  }

  Widget _buildProgressBar() {
    const progressBarHeight = 3.0;

    final progressBarColor = accentColor ?? Theme.of(context).accentColor;
    final showProgresBar =
        progress != null && (progress is num || (progress is bool && progress == true));
    final progressValue = progress is num ? progress.toDouble().clamp(0.0, 1.0) : null;

    return Transform.translate(
      offset: Offset(0, height - progressBarHeight),
      child: AnimatedOpacity(
        opacity: showProgresBar ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 150),
        child: SizedBox(
          height: progressBarHeight,
          child: LinearProgressIndicator(
            value: progressValue,
            semanticsValue: progressValue,
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation(progressBarColor),
          ),
        ),
      ),
    );
  }

  Widget _buildBackdrop() {
    if (value == 0.0) return const SizedBox(height: 0);

    return FadeTransition(
      opacity: animation,
      child: GestureDetector(
        onTap: () {
          if (widget.closeOnBackdropTap) {
            close();
          }
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: backdropColor,
        ),
      ),
    );
  }

  List<Widget> _mapActions(List<Widget> actions) {
    if (actions == null) return <Widget>[];

    final animation = _queryToTitleAnimation;
    final isOpen = _controller.value >= 0.5;

    var openCount = 0;
    var closedCount = 0;
    for (final action in actions) {
      if (action is FloatingSearchBarAction) {
        if (action.showIfOpened) openCount++;
        if (action.showIfClosed) closedCount++;
      }
    }

    final currentActions = List<Widget>.from(actions)
      ..removeWhere((action) {
        if (action is FloatingSearchBarAction) {
          return (isOpen && !action.showIfOpened) || (!isOpen && !action.showIfClosed);
        } else {
          return false;
        }
      });

    return currentActions.map((action) {
      if (action is FloatingSearchBarAction) {
        if (action.isAlwaysShown) return action;

        final index = currentActions.reversed.toList().indexOf(action);
        final shouldScale = index <= ((isOpen ? closedCount : openCount) - 1);
        if (shouldScale) {
          return ScaleTransition(
            scale: animation,
            child: action,
          );
        } else {
          return SizeFadeTransition(
            animation: animation,
            axis: Axis.horizontal,
            axisAlignment: 1.0,
            sizeFraction: 0.25,
            child: Center(child: action),
          );
        }
      }

      return action;
    }).toList();
  }

  @override
  void dispose() {
    queryListener.dispose();
    _barRebuilder.dispose();
    _controller.dispose();
    _handler.cancel();

    if (widget.scrollController == null) {
      _scrollController?.dispose();
    }

    super.dispose();
  }
}

/// A controller for a [FloatingSearchBar].
class FloatingSearchBarController {
  /// Creates a controller for a [FloatingSearchBar].
  FloatingSearchBarController();

  FloatingSearchBarState _state;

  /// Opens/Expands the [FloatingSearchBar].
  void open() => _open?.call();
  VoidCallback _open;

  /// Closes/Collapses the [FloatingSearchBar].
  void close() => _close?.call();
  VoidCallback _close;

  /// Cleares the current query.
  void clear() => _clear?.call();
  VoidCallback _clear;

  /// Visually reveals the [FloatingSearchBar] when
  /// it was previously hidden via [hide].
  void show() => _show?.call();
  VoidCallback _show;

  /// Visually hides the [FloatingSearchBar].
  void hide() => _hide?.call();
  VoidCallback _hide;

  /// Whether the [FloatingSearchBar] is currently
  /// opened/expanded.
  bool get isOpen => _state?.isOpen == true;

  /// Whether the [FloatingSearchBar] is currently
  /// closed/collapsed.
  bool get isClosed => _state?.isOpen == false;

  /// Whether the [FloatingSearchBar] is currently
  /// not hidden.
  bool get isVisible => _state?.isVisible == true;

  /// Whether the [FloatingSearchBar] is currently
  /// not visible.
  bool get isHidden => _state?.isVisible == false;

  /// Disposes this controller.
  void dispose() {
    _open = null;
    _close = null;
    _clear = null;
    _show = null;
    _hide = null;
    _state = null;
  }
}
