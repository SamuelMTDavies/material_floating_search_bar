import 'dart:math';

import 'package:flutter/material.dart';

import 'floating_search_bar_actions.dart';
import 'floating_search_bar_dismissable.dart';
import 'floating_search_bar_style.dart';
import 'floating_search_bar_transition.dart';
import 'text_controller.dart';
import 'util/util.dart';
import 'widgets/widgets.dart';

typedef FloatingSearchBarBodyBuilder = Widget Function(
    BuildContext context, Animation<double> transition);

typedef OnQueryChangeCallback = void Function(String query);

typedef OnFocusChangeCallback = void Function(bool isFocused);

class FloatingSearchBar extends ImplicitAnimation {
  // * --- Style properties --- *
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

  // * --- Utility --- *
  final bool clearQueryOnClose;
  final bool showDrawerHamburger;
  final bool closeOnBackdropTap;
  final dynamic progress;
  final Duration openDuration;
  final Curve openCurve;
  final Duration debounceDelay;
  final Text title;
  final dynamic hint;
  final List<Widget> actions;
  final List<Widget> startActions;
  final OnQueryChangeCallback onQueryChanged;
  final OnFocusChangeCallback onFocusChanged;
  final OnQueryChangeCallback onSubmitted;
  final FloatingSearchBarTransition transition;
  final FloatingSearchBarBodyBuilder bodyBuilder;
  final FloatingSearchBarController controller;
  final TextInputAction textInputAction;
  final TextInputType textInputType;

  // * --- Scrolling --- *
  final bool isScrollControlled;
  final ScrollPhysics physics;
  final ScrollController scrollController;
  final EdgeInsets scrollPadding;
  const FloatingSearchBar({
    Key key,
    Duration implicitDuration = const Duration(milliseconds: 600),
    Curve implicitCurve = Curves.linear,
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
    this.openDuration = const Duration(milliseconds: 500),
    this.openCurve = Curves.ease,
    this.debounceDelay = Duration.zero,
    this.title,
    this.hint,
    this.actions,
    this.startActions,
    this.onQueryChanged,
    this.onFocusChanged,
    this.onSubmitted,
    this.transition,
    @required this.bodyBuilder,
    this.controller,
    this.textInputAction = TextInputAction.search,
    this.textInputType,
    this.isScrollControlled = true,
    this.physics,
    this.scrollController,
    this.scrollPadding = const EdgeInsets.symmetric(vertical: 16),
  })  : assert(bodyBuilder != null),
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
        ? <Widget>[...actions, FloatingSearchBarAction.hamburger()]
        : actions;
  }

  bool get hasStartActions => startActions.isNotEmpty;
  List<Widget> get startActions {
    final actions = widget.startActions ?? const <Widget>[];
    final hasDrawer = Scaffold.of(context)?.hasDrawer ?? false;
    final showHamburgerMenu = hasDrawer && widget.showDrawerHamburger;
    return showHamburgerMenu
        ? <Widget>[FloatingSearchBarAction.hamburger(), ...actions]
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
              start: hasStartActions ? 8 : 24, end: hasActions ? 16 : 24),
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
      style: style,
      clearQueryOnClose: widget.clearQueryOnClose,
      showDrawerHamburger: widget.showDrawerHamburger,
      closeOnBackdropTap: widget.closeOnBackdropTap,
      progress: widget.progress,
      openDuration: widget.openDuration,
      openCurve: widget.openCurve,
      debounceDelay: widget.debounceDelay,
      title: widget.title,
      hint: widget.hint,
      actions: actions,
      startActions: startActions,
      onQueryChanged: widget.onQueryChanged,
      onFocusChanged: widget.onFocusChanged,
      onSubmitted: widget.onSubmitted,
      transition: widget.transition,
      bodyBuilder: widget.bodyBuilder,
      controller: widget.controller,
      textInputAction: widget.textInputAction,
      textInputType: widget.textInputType,
      isScrollControlled: widget.isScrollControlled,
      physics: widget.physics,
      scrollController: widget.scrollController,
      scrollPadding: widget.scrollPadding,
    );
  }
}

class _FloatingSearchBar extends StatefulWidget {
  final FloatingSearchBarStyle style;

  // * --- Utility --- *
  final bool clearQueryOnClose;
  final bool showDrawerHamburger;
  final bool closeOnBackdropTap;
  final dynamic progress;
  final Duration openDuration;
  final Curve openCurve;
  final Duration debounceDelay;
  final Text title;
  final dynamic hint;
  final List<Widget> actions;
  final List<Widget> startActions;
  final OnQueryChangeCallback onQueryChanged;
  final OnFocusChangeCallback onFocusChanged;
  final OnQueryChangeCallback onSubmitted;
  final FloatingSearchBarTransition transition;
  final FloatingSearchBarBodyBuilder bodyBuilder;
  final FloatingSearchBarController controller;
  final TextInputAction textInputAction;
  final TextInputType textInputType;

  // * --- Scrolling --- *
  final bool isScrollControlled;
  final ScrollPhysics physics;
  final ScrollController scrollController;
  final EdgeInsets scrollPadding;
  const _FloatingSearchBar({
    Key key,
    @required this.style,
    @required this.clearQueryOnClose,
    @required this.showDrawerHamburger,
    @required this.closeOnBackdropTap,
    @required this.progress,
    @required this.openDuration,
    @required this.openCurve,
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

  Curve get curve => widget.openCurve;
  Duration get duration => widget.openDuration;
  Duration get queryCallbackDelay => widget.debounceDelay;

  final Handler _handler = Handler();

  TextController _input;

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

  bool _isShown = true;
  bool get isShown => _isShown;
  set isShown(bool value) {
    if (value == isShown) return;

    // Only hide the bar when it is not opened.
    if (!isOpen || value) {
      _isShown = value;
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

    transition = widget.transition ?? ExpandingFloatingSearchBarTransition();

    _scrollController = widget.scrollController ?? ScrollController();

    _assignController();
  }

  @override
  void didUpdateWidget(_FloatingSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (curve != oldWidget.openCurve) {
      _animation = CurvedAnimation(parent: _controller, curve: curve);
    }

    if (duration != oldWidget.openDuration) {
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

  void show() => isShown = true;
  void hide() => isShown = false;

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

    return SizedBox.expand(
      child: WillPopScope(
        onWillPop: _onPop,
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
    );
  }

  double translation = 0.0;
  double lastScrollOffset = 0.0;

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
          hidden: !isShown,
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
            translation: Offset(0.0, isShown ? 0.0 : -1.0),
            isFractional: true,
            curve: Curves.ease,
            child: container,
          ),
        );
      },
    );

    if (isInside) return bar;

    final maxWidth = transition.lerpMaxWidth();

    return AnimatedAlign(
      duration: isAnimating ? duration : Duration.zero,
      curve: widget.openCurve,
      alignment: Alignment(isOpen ? openAxisAlignment : axisAlignment, 0.0),
      child: Column(
        children: <Widget>[
          bar,
          Expanded(
            child: Container(
              constraints: maxWidth != null
                  ? BoxConstraints(
                      maxWidth: maxWidth + transition.lerpMargin().horizontal)
                  : null,
              child: NotificationListener<ScrollNotification>(
                onNotification: _onBodyScroll,
                child: _buildBody(),
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
      child: body,
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

    return Stack(
      alignment: Alignment.topCenter,
      children: <Widget>[
        if (transition.isBodyInsideSearchBar && value > 0.0)
          Padding(
            padding: EdgeInsets.only(top: height),
            child: NotificationListener<ScrollNotification>(
              onNotification: _onBodyScroll,
              child: widget.bodyBuilder(context, animation),
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
    );
  }

  Widget _buildTextField() {
    final showTextInput = _controller.value > 0.5;
    if (showTextInput) {
      return Opacity(
        opacity: _queryToTitleAnimation.value,
        child: TextField(
          controller: _input,
          maxLines: 1,
          autofocus: false,
          cursorColor: accentColor,
          style: style.queryStyle,
          textInputAction: widget.textInputAction,
          keyboardType: widget.textInputType,
          onSubmitted: widget.onSubmitted,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: style.hintStyle,
            contentPadding: insets,
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
          ),
        ),
      );
    } else {
      return SingleChildScrollView(
        padding: insets,
        scrollDirection: Axis.horizontal,
        child: Opacity(
          opacity: _queryToTitleAnimation.value,
          child: widget.title ?? const SizedBox(),
        ),
      );
    }
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

    final currentActions = List.from(actions)
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
        }

        return SizeFadeTransition(
          animation: animation,
          axis: Axis.horizontal,
          axisAlignment: 1.0,
          sizeFraction: 0.25,
          child: action,
        );
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

class FloatingSearchBarController {
  FloatingSearchBarState _state;

  void open() => _open?.call();
  VoidCallback _open;

  void close() => _close?.call();
  VoidCallback _close;

  void clear() => _clear?.call();
  VoidCallback _clear;

  void show() => _show?.call();
  VoidCallback _show;

  void hide() => _hide?.call();
  VoidCallback _hide;

  bool get isOpen => _state?.isOpen == true;
  bool get isClosed => _state?.isOpen == false;

  bool get isShown => _state?.isShown == true;
  bool get isHidden => _state?.isShown == false;

  void dispose() {
    _open = null;
    _close = null;
    _clear = null;
    _show = null;
    _hide = null;
    _state = null;
  }
}
