import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:moxie_fitness/models/models.dart';
import 'package:moxie_fitness/pages/pages.dart';
import 'dart:math';

class ActiveWorkoutPager extends StatefulWidget {
  final Complete completableWorkout;

  ActiveWorkoutPager({this.completableWorkout});

  @override
  _ActiveWorkoutPageState createState() => _ActiveWorkoutPageState();
}

class _ActiveWorkoutPageState extends State<ActiveWorkoutPager> {
  PageController _pageController = PageController();
  final _kDuration = const Duration(milliseconds: 300);
  final _kCurve = Curves.ease;

  @override
  initState() {
    widget.completableWorkout.workout.workout_exercises
        .sort((ex1, ex2) => ex1.pos.compareTo(ex2.pos));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Sort the exercises
    widget.completableWorkout.workout.workout_exercises
        .sort((ex1, ex2) => ex1.pos.compareTo(ex2.pos));

    List<Widget> pages = <Widget>[];
    List<Widget> exercisePages = widget
        .completableWorkout.workout.workout_exercises
        .map((ew) => ExercisePage(
            id: ew.exercise_id, completableId: widget.completableWorkout.id))
        .toList();

    pages.addAll(exercisePages);
    pages.add(_getFinishWorkoutPage());

    return Stack(
      children: <Widget>[
        PageView.builder(
          physics: AlwaysScrollableScrollPhysics(),
          controller: _pageController,
          itemCount: pages.length,
          itemBuilder: (BuildContext context, int index) {
            return pages[index];
          },
        ),
        Positioned(
          bottom: 0.0,
          left: 50.0,
          right: 50.0,
          child: Container(
            height: 30.0,
            color: Colors.transparent,
            padding: const EdgeInsets.all(10.0),
            child: Center(
              child: DotsIndicator(
                controller: _pageController,
                itemCount: pages.length,
                onPageSelected: (int page) {
                  _pageController.animateToPage(
                    page,
                    duration: _kDuration,
                    curve: _kCurve,
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  _getFinishWorkoutPage() {
    return FinishWorkoutPage();
  }
}

class DotsIndicator extends AnimatedWidget {
  DotsIndicator({
    this.controller,
    this.itemCount,
    this.onPageSelected,
    this.color: Colors.white,
  }) : super(listenable: controller) {
    _kDotSize = 16.0 / (log(itemCount) * 1.25);
    _kDotSpacing = 50 / (log(itemCount) * 1.25);
  }

  /// The PageController that this DotsIndicator is representing.
  final PageController controller;

  /// The number of items managed by the PageController
  final int itemCount;

  /// Called when a dot is tapped
  final ValueChanged<int> onPageSelected;

  /// The color of the dots.
  ///
  /// Defaults to `Colors.white`.
  final Color color;

  // The base size of the dots
  num _kDotSize = 8.0;

  // The increase in the size of the selected dot
  num _kMaxZoom = 2.0;

  // The distance between the center of each dot
  num _kDotSpacing = 25.0;

  Widget _buildDot(int index) {
    double selectedness = Curves.easeOut.transform(
      max(
        0.0,
        1.0 - ((controller.page ?? controller.initialPage) - index).abs(),
      ),
    );
    double zoom = 1.0 + (_kMaxZoom - 1.0) * selectedness;
    return Container(
      width: _kDotSpacing,
      child: Center(
        child: Material(
          color: Color.fromRGBO(
              255 - (selectedness * 255).floor(),
              255 - (selectedness * 255).floor(),
              255 - (selectedness * 255).floor(),
              1.0),
          type: MaterialType.circle,
          child: Container(
            width: _kDotSize * zoom,
            height: _kDotSize * zoom,
            child: InkWell(
              onTap: () => onPageSelected(index),
            ),
          ),
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(itemCount, _buildDot),
    );
  }
}
