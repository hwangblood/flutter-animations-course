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

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  /* 
    AnimationController: 0.0 -- 0.5 -- 1.0  (value)
    Animation(wanted)  : 0.0 -- 180 -- 360  (degrees)
   */

  final double boxWidth = 100;
  final double boxHeight = 100;

  late AnimationController _controller;

  // from 0 to 360
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Tween is not an Animation
    _animation = Tween<double>(begin: 0.0, end: 2 * pi)
        // connect animation to controller
        .animate(_controller);

    // luanch the animation
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('AnimatedBuilder and Transform'),
      ),
      body: Center(
        child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform(
                alignment: Alignment.center, // recommended way
                // origin: Offset(boxWidth / 2, boxHeight / 2), // default 0,0
                transform: Matrix4.identity()..rotateY(_animation.value),
                child: Container(
                  width: boxWidth,
                  height: boxHeight,
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 10,
                          offset: const Offset(5, 5),
                        ),
                      ]),
                ),
              );
            }),
      ),
    );
  }
}
