import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:moxie_fitness/components/components.dart';

class PageDragger extends StatefulWidget {
  final bool canDragLeftToRight;
  final bool canDragRightToLeft;
  final StreamController<FormWizardUpdate> formWizardUpdateStream;

  PageDragger({
    this.canDragLeftToRight,
    this.canDragRightToLeft,
    @required this.formWizardUpdateStream,
  });

  @override
  _PageDraggerState createState() => new _PageDraggerState();
}

class _PageDraggerState extends State<PageDragger> {

  static const fullTransitionPixels = 300.0;

  Offset dragStart;
  Offset dragEnd;
  var dragStartTime;
  SlideDirection slideDirection;
  double slidePercent = 0.0;

  onDragStart(DragStartDetails details){
    dragStart = details.globalPosition;
    dragStartTime = new DateTime.now().millisecondsSinceEpoch;
  }

  onDragUpdate(DragUpdateDetails details) {
    if(dragStart != null) {
      final newPosition = details.globalPosition;
      final dx = dragStart.dx - newPosition.dx;

      if (dx > 0.0 && widget.canDragRightToLeft) {
        slideDirection = SlideDirection.rightToLeft;
      } else if (dx < 0.0 && widget.canDragLeftToRight) {
        slideDirection = SlideDirection.leftToRight;
      } else {
        slideDirection = SlideDirection.none;
      }

      if(slideDirection != SlideDirection.none){
        slidePercent = (dx / fullTransitionPixels).abs().clamp(0.0, 1.0);
      } else {
        slidePercent = 0.0;
      }

      // Access PageDragger widget
      widget.formWizardUpdateStream.add(
        new FormWizardUpdate(
          slideDirection,
          slidePercent,
          FormWizardUpdateType.dragging,
          null
        )
      );

      print('Dragging $slideDirection at $slidePercent%');
    }
  }

  onDragEnd(DragEndDetails details) {
    // cleanup
    dragStart = null;

    final velocity = details.velocity.pixelsPerSecond.dx / ((dragStartTime - new DateTime.now().millisecondsSinceEpoch));

    widget.formWizardUpdateStream.add(
      new FormWizardUpdate(
        SlideDirection.none,
        0.0,
        FormWizardUpdateType.doneDragging,
        velocity
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onHorizontalDragStart: onDragStart,
      onHorizontalDragUpdate: onDragUpdate,
      onHorizontalDragEnd: onDragEnd,
    );
  }
}

class AnimatedPageDragger {
  static const percentPerMillisecond = 0.005;

  final slideDirection;
  final transitionGoal;
  final dragVelocity;

  AnimationController completionAnimationController;

  AnimatedPageDragger({
    this.slideDirection,
    this.transitionGoal,
    slidePercent,
    StreamController<FormWizardUpdate> formWizardUpdateStream,
    TickerProvider vsync,
    this.dragVelocity
  }) {
    final startSlidePercent = slidePercent;
    var endSlidePercent;
    var duration;

    if(transitionGoal == TransitionGoal.open) {
      endSlidePercent = 1.0;
      final slideRemaining = 1.0 - slidePercent;
      duration = new Duration(
        milliseconds: (slideRemaining / percentPerMillisecond).round()
      );
    } else {
      endSlidePercent = 0.0;
      duration = new Duration(
        milliseconds: (slidePercent / percentPerMillisecond).round()
      );
    }

    completionAnimationController = new AnimationController(
      vsync: vsync,
      duration: duration
    )
    ..addListener(() {
      slidePercent = lerpDouble(
        startSlidePercent,
        endSlidePercent,
        completionAnimationController.value
      );
      formWizardUpdateStream.add(
        new FormWizardUpdate(
          slideDirection,
          slidePercent,
          FormWizardUpdateType.animating,
          this.dragVelocity
        )
      );
    })
    ..addStatusListener((AnimationStatus status) {
      if(status == AnimationStatus.completed) {
        formWizardUpdateStream.add(
          new FormWizardUpdate(
            slideDirection,
            endSlidePercent,
            FormWizardUpdateType.doneAnimating,
            this.dragVelocity,
          )
        );
      }
    });
  }

  run() {
    completionAnimationController.forward(from: 0.0);
  }

  dispose() {
    completionAnimationController.dispose();
  }
}

class FormWizardUpdate {
  final SlideDirection direction;
  final double slidePercent;
  final FormWizardUpdateType updateType;
  final double dragVelocity;


  FormWizardUpdate(
    this.direction,
    this.slidePercent,
    this.updateType,
    [
      this.dragVelocity = 0.0,
    ]
  );
}