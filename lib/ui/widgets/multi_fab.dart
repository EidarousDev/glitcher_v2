import 'package:flutter/material.dart';
import 'package:glitcher/style/colors.dart';

class MultiFab extends StatefulWidget {
  final Function onTap1;
  final Function onTap2;
  final Color color1;
  final IconData icons1;

  const MultiFab({Key key, this.onTap1, this.onTap2, this.color1, this.icons1})
      : super(key: key);

  @override
  _MultiFabState createState() => _MultiFabState();
}

degreeToRadians(double degree) {
  return degree / 57.295779513;
}

class _MultiFabState extends State<MultiFab>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation _translationAnimation;
  Animation _rotationAnimation;
  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 250));
    _translationAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _rotationAnimation = Tween<double>(begin: 180.0, end: 0.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    _animationController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        IgnorePointer(
          child: Container(
            color: Colors.transparent,
            height: 120.0,
            width: 120.0,
          ),
        ),

        ///FAB 1
        Transform.translate(
          offset: Offset.fromDirection(
              degreeToRadians(180), _translationAnimation.value * 70),
          child: Transform(
            transform:
                Matrix4.rotationZ(degreeToRadians(_rotationAnimation.value))
                  ..scale(_translationAnimation.value),
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: widget.onTap1,
              child: CircularBtn(
                key: Key('Follow'),
                child: Icon(widget.icons1),
                color: widget.color1,
              ),
            ),
          ),
        ),

        ///FAB 2
        Transform.translate(
          offset: Offset.fromDirection(
              degreeToRadians(270), _translationAnimation.value * 70),
          child: Transform(
            transform:
                Matrix4.rotationZ(degreeToRadians(_rotationAnimation.value))
                  ..scale(_translationAnimation.value),
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: widget.onTap2,
              child: CircularBtn(
                key: Key('New Post'),
                child: Icon(Icons.post_add),
                color: kLightAccent,
              ),
            ),
          ),
        ),
        Transform(
          transform:
              Matrix4.rotationZ(degreeToRadians(_rotationAnimation.value)),
          alignment: Alignment.center,
          child: FloatingActionButton(
            onPressed: () {
              if (_animationController?.status == AnimationStatus.completed) {
                _animationController.reverse();
              } else {
                _animationController.forward();
              }
            },
            child: Icon(Icons.menu),
          ),
        ),
      ],
    );
  }
}

class CircularBtn extends StatelessWidget {
  final color;
  final child;
  const CircularBtn({
    Key key,
    this.color,
    this.child,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      width: 45,
      child: child,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
