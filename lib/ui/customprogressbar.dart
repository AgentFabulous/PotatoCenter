import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class CustomProgressBar extends StatefulWidget {
  final bool roundBoi;
  final double percentage;
  final Color positiveColor;
  final Color negativeColor;
  final double thickness;
  final bool vertical;
  final bool autoPad;

  CustomProgressBar(
      {this.percentage,
      this.positiveColor,
      this.negativeColor,
      this.roundBoi = false,
      this.thickness = 30.0,
      this.vertical = false,
      this.autoPad = true});

  @override
  _CustomProgressBarState createState() => _CustomProgressBarState();
}

class _CustomProgressBarState extends State<CustomProgressBar>
    with TickerProviderStateMixin {
  GlobalKey widgetKey = GlobalKey();
  OverlayEntry oe;
  double _sliderSize = 1;
  AnimationController _controller;
  Animation _curve;

  @override
  void initState() {
    animControllerSetup();
    if (oe != null) {
      oe.remove();
    }
    oe = OverlayEntry(
      opaque: false,
      builder: (context) {
        setSize();
        return Container();
      },
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      Overlay.of(context).insert(oe);
    });
    super.initState();
  }

  void animControllerSetup() {
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 750));
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed)
        _controller.reverse();
      else if (status == AnimationStatus.dismissed) _controller.forward();
    });
    _curve = CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
        reverseCurve: Curves.easeInOut);
    Tween<double>(begin: 0, end: 1).animate(_curve);
    _controller.forward();
  }

  @override
  void dispose() {
    oe.remove();
    _controller.dispose();
    super.dispose();
  }

  void setSize() {
    if (widgetKey != null && widgetKey.currentContext != null)
      _sliderSize = widget.vertical
          ? (widgetKey.currentContext.findRenderObject() as RenderBox)
              .size
              .height
          : (widgetKey.currentContext.findRenderObject() as RenderBox)
              .size
              .width;
  }

  @override
  Widget build(BuildContext context) {
    setSize();
    if (_controller.isAnimating && widget.percentage != null)
      _controller.stop(canceled: true);
    else if ((_controller == null || !_controller.isAnimating) &&
        widget.percentage == null) _controller.forward();

    return Padding(
      padding:
          EdgeInsets.symmetric(vertical: widget.autoPad ? widget.thickness : 0),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(widget.thickness / 2)),
        child: Stack(
          children: <Widget>[
            Container(
              key: widgetKey,
              width: widget.vertical ? widget.thickness : double.maxFinite,
              height: widget.vertical ? double.maxFinite : widget.thickness,
              decoration: BoxDecoration(
                  color: widget.negativeColor,
                  borderRadius:
                      BorderRadius.all(Radius.circular(widget.thickness / 2))),
            ),
            Container(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: widget.vertical
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                crossAxisAlignment: widget.vertical
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
                children: <Widget>[
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) => Opacity(
                          opacity: widget.percentage == null ? _curve.value : 1,
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            decoration: BoxDecoration(
                                color: widget.positiveColor,
                                borderRadius: BorderRadius.all(Radius.circular(
                                    widget.roundBoi
                                        ? widget.thickness / 2
                                        : 0.0))),
                            height: widget.vertical
                                ? widget.percentage == null
                                    ? double.maxFinite
                                    : _sliderSize * widget.percentage / 100
                                : widget.thickness,
                            width: widget.vertical
                                ? widget.thickness
                                : widget.percentage == null
                                    ? double.maxFinite
                                    : _sliderSize * widget.percentage / 100,
                          ),
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
