import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

const Duration _kBottomSheetDuration = Duration(milliseconds: 200);
const double _kMinFlingVelocity = 700.0;
const double _kCloseProgressThreshold = 0.5;

class BottomSheet extends StatefulWidget {
  const BottomSheet({
    Key key,
    this.animationController,
    this.borderRadius = const BorderRadius.all(Radius.circular(0)),
    @required this.onClosing,
    @required this.builder,
  })  : assert(onClosing != null),
        assert(builder != null),
        super(key: key);

  final AnimationController animationController;
  final VoidCallback onClosing;
  final WidgetBuilder builder;
  final BorderRadius borderRadius;

  @override
  _BottomSheetState createState() => _BottomSheetState();

  static AnimationController createAnimationController(
    TickerProvider vsync, {
    Duration duration,
  }) {
    return AnimationController(
      duration: duration ?? _kBottomSheetDuration,
      debugLabel: 'BottomSheet',
      vsync: vsync,
    );
  }
}

class _BottomSheetState extends State<BottomSheet> {
  final GlobalKey _childKey = GlobalKey(debugLabel: 'BottomSheet child');

  double get _childHeight {
    final RenderBox renderBox = _childKey.currentContext.findRenderObject();
    return renderBox.size.height;
  }

  bool get _dismissUnderway =>
      widget.animationController.status == AnimationStatus.reverse;

  void _handleDragUpdate(DragUpdateDetails details) {
    if (_dismissUnderway) {
      return;
    }
    widget.animationController.value -=
        details.primaryDelta / (_childHeight ?? details.primaryDelta);
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_dismissUnderway) {
      return;
    }
    if (details.velocity.pixelsPerSecond.dy > _kMinFlingVelocity) {
      final double flingVelocity =
          -details.velocity.pixelsPerSecond.dy / _childHeight;
      if (widget.animationController.value > 0.0)
        widget.animationController.fling(velocity: flingVelocity);
      if (flingVelocity < 0.0) {
        widget.onClosing();
      }
    } else if (widget.animationController.value < _kCloseProgressThreshold) {
      if (widget.animationController.value > 0.0)
        widget.animationController.fling(velocity: -1.0);
      widget.onClosing();
    } else {
      widget.animationController.forward();
    }
  }

  @override
  Widget build(context) {
    return GestureDetector(
      onVerticalDragUpdate: _handleDragUpdate,
      onVerticalDragEnd: _handleDragEnd,
      child: Material(
        key: _childKey,
        child: widget.builder(context),
        borderRadius: widget.borderRadius,
      ),
    );
  }
}

class _ModalBottomSheetLayout extends SingleChildLayoutDelegate {
  _ModalBottomSheetLayout(
    this.progress,
    this.bottomInset,
    this.dialogHeightPercentage,
  );

  final double progress;
  final double bottomInset;
  final double dialogHeightPercentage;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints(
        minWidth: constraints.maxWidth,
        maxWidth: constraints.maxWidth,
        minHeight: 0.0,
        maxHeight: constraints.maxHeight * dialogHeightPercentage);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return Offset(0.0, size.height - bottomInset - childSize.height * progress);
  }

  @override
  bool shouldRelayout(_ModalBottomSheetLayout oldDelegate) {
    return progress != oldDelegate.progress ||
        bottomInset != oldDelegate.bottomInset;
  }
}

class _ModalBottomSheet<T> extends StatefulWidget {
  const _ModalBottomSheet({
    Key key,
    this.route,
    this.dialogHeightPercentage,
    this.borderRadius,
  }) : super(key: key);

  final _ModalBottomSheetRoute<T> route;
  final double dialogHeightPercentage;
  final BorderRadius borderRadius;

  @override
  _ModalBottomSheetState<T> createState() => _ModalBottomSheetState<T>();
}

class _ModalBottomSheetState<T> extends State<_ModalBottomSheet<T>> {
  @override
  Widget build(context) => GestureDetector(
        onTap: widget.route.dismissOnTap ? () => Navigator.pop(context) : null,
        child: AnimatedBuilder(
          animation: widget.route.animation,
          builder: (BuildContext context, Widget child) {
            final double bottomInset = widget.route.resizeToAvoidBottomPadding
                ? MediaQuery.of(context).viewInsets.bottom
                : 0.0;
            return ClipRect(
              child: CustomSingleChildLayout(
                delegate: _ModalBottomSheetLayout(widget.route.animation.value,
                    bottomInset, widget.dialogHeightPercentage),
                child: BottomSheet(
                  animationController: widget.route._animationController,
                  onClosing: () => Navigator.pop(context),
                  builder: widget.route.builder,
                  borderRadius: widget.borderRadius,
                ),
              ),
            );
          },
        ),
      );
}

class _ModalBottomSheetRoute<T> extends PopupRoute<T> {
  _ModalBottomSheetRoute({
    this.builder,
    this.theme,
    this.barrierLabel,
    RouteSettings settings,
    this.resizeToAvoidBottomPadding,
    this.dismissOnTap,
    this.dialogHeightPercentage,
    this.padding,
    this.duration,
    this.borderRadius,
  }) : super(settings: settings);

  final WidgetBuilder builder;
  final ThemeData theme;
  final bool resizeToAvoidBottomPadding;
  final bool dismissOnTap;
  final double dialogHeightPercentage;
  final EdgeInsets padding;
  final Duration duration;
  final BorderRadius borderRadius;

  @override
  Duration get transitionDuration => duration ?? _kBottomSheetDuration;

  @override
  bool get barrierDismissible => true;

  @override
  final String barrierLabel;

  @override
  Color get barrierColor => Colors.black54;

  AnimationController _animationController;

  @override
  AnimationController createAnimationController() {
    assert(_animationController == null);
    _animationController = BottomSheet.createAnimationController(
        navigator.overlay,
        duration: duration);
    return _animationController;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    Widget bottomSheet = MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Padding(
        padding: padding.copyWith(bottom: 0),
        child: _ModalBottomSheet<T>(
          route: this,
          dialogHeightPercentage: dialogHeightPercentage,
          borderRadius: borderRadius,
        ),
      ),
    );
    if (theme != null) {
      bottomSheet = Theme(data: theme, child: bottomSheet);
    }
    return bottomSheet;
  }
}

Future<T> showModalBottomSheetApp<T>({
  @required BuildContext context,
  @required WidgetBuilder builder,
  bool dismissOnTap = true,
  bool resizeToAvoidBottomPadding = true,
  double dialogHeightPercentage = 9.0 / 16.0,
  EdgeInsets padding = const EdgeInsets.all(0),
  Duration duration,
  BorderRadius borderRadius,
}) {
  assert(context != null);
  assert(builder != null);
  return Navigator.push(
    context,
    _ModalBottomSheetRoute<T>(
      builder: builder,
      theme: Theme.of(context, shadowThemeOnly: true),
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      resizeToAvoidBottomPadding: resizeToAvoidBottomPadding,
      dismissOnTap: dismissOnTap,
      dialogHeightPercentage: dialogHeightPercentage,
      padding: padding,
      duration: duration,
      borderRadius: borderRadius,
    ),
  );
}

PersistentBottomSheetController<T> showBottomSheet<T>({
  @required BuildContext context,
  @required WidgetBuilder builder,
}) {
  assert(context != null);
  assert(builder != null);
  return Scaffold.of(context).showBottomSheet<T>(builder);
}
