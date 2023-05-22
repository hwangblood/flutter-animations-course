import 'dart:math' show pi;

import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Animations Course',
      home: HomePage(),
    );
  }
}

enum CircleSide {
  left,
  right,
}

extension ToPath on CircleSide {
  /// parameter size is the size of Container
  Path toPath(Size size) {
    final path = Path();

    late Offset offset;
    late bool clockwise;

    switch (this) {
      case CircleSide.left:
        path.moveTo(size.width, 0);
        offset = Offset(size.width, size.height);
        clockwise = false;
        break;
      case CircleSide.right:
        // path.moveTo(0, 0);  // this is the default origin point
        offset = Offset(0, size.height);
        clockwise = true;
        break;
    }
    path.arcToPoint(
      offset,
      radius: Radius.elliptical(size.width / 2, size.height / 2),
      clockwise: clockwise,
    );

    path.close();
    return path;
  }
}

class HalfCircleClipper extends CustomClipper<Path> {
  final CircleSide circleSide;

  HalfCircleClipper(this.circleSide);

  @override
  Path getClip(Size size) => circleSide.toPath(size);

  // in here, we want to redraw clip path
  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}

extension on VoidCallback {
  Future<dynamic> delayed({required Duration duration}) =>
      Future.delayed(duration, this);
}

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _counterClockwiseRotationController;
  late Animation<double> _counterClockwiseRotationAnimation;

  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  final startAnimationDuration = const Duration(seconds: 1);
  final rotationAnimationDuration = const Duration(seconds: 1);
  final flipAnimationDuration = const Duration(seconds: 1);

  @override
  void initState() {
    super.initState();

    // rotation animation
    _counterClockwiseRotationController = AnimationController(
      vsync: this,
      duration: rotationAnimationDuration,
    );
    _counterClockwiseRotationAnimation = Tween<double>(
      begin: 0,
      end: -(pi / 2),
    ).animate(
      CurvedAnimation(
        parent: _counterClockwiseRotationController,
        curve: Curves.bounceOut,
      ),
    );

    // flip animation
    _flipController = AnimationController(
      vsync: this,
      duration: flipAnimationDuration,
    );
    _flipAnimation = Tween<double>(
      begin: 0,
      end: pi,
    ).animate(
      CurvedAnimation(
        parent: _flipController,
        curve: Curves.bounceOut,
      ),
    );

    /* status listeners */

    _counterClockwiseRotationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _flipAnimation = Tween<double>(
          begin: _flipAnimation.value,
          end: _flipAnimation.value + pi,
        ).animate(
          CurvedAnimation(
            parent: _flipController,
            curve: Curves.bounceOut,
          ),
        );
        // reset flip controller and start the animation
        _flipController
          ..reset()
          ..forward();
      }
    });

    _flipController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _counterClockwiseRotationAnimation = Tween<double>(
          begin: _counterClockwiseRotationAnimation.value,
          end: _counterClockwiseRotationAnimation.value + -(pi / 2),
        ).animate(
          CurvedAnimation(
            parent: _counterClockwiseRotationController,
            curve: Curves.bounceOut,
          ),
        );
        // reset counter clockwise rotation controller and start the animation
        _counterClockwiseRotationController
          ..reset()
          ..forward();
      }
    });
  }

  @override
  void dispose() {
    _counterClockwiseRotationController.dispose();
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _counterClockwiseRotationController
      // reset the counter clockwise rotation controller, to start animation with 0 degree
      ..reset()
      ..forward.delayed(duration: startAnimationDuration);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Chained Animations'),
      ),
      body: Center(
        child: AnimatedBuilder(
            animation: _counterClockwiseRotationController,
            builder: (context, child) {
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..rotateZ(
                    _counterClockwiseRotationAnimation.value,
                  ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _flipAnimation,
                      builder: (context, child) {
                        return Transform(
                          alignment: Alignment.centerRight,
                          transform: Matrix4.identity()
                            ..rotateY(
                              _flipAnimation.value,
                            ),
                          child: ClipPath(
                            clipper: HalfCircleClipper(CircleSide.left),
                            child: Container(
                              width: 200,
                              height: 200,
                              color: const Color(0xff0057b7),
                            ),
                          ),
                        );
                      },
                    ),
                    AnimatedBuilder(
                        animation: _flipAnimation,
                        builder: (context, child) {
                          return Transform(
                            alignment: Alignment.centerLeft,
                            transform: Matrix4.identity()
                              ..rotateY(
                                _flipAnimation.value,
                              ),
                            child: ClipPath(
                              clipper: HalfCircleClipper(CircleSide.right),
                              child: Container(
                                width: 200,
                                height: 200,
                                color: const Color(0xffffd700),
                              ),
                            ),
                          );
                        }),
                  ],
                ),
              );
            }),
      ),
    );
  }
}
