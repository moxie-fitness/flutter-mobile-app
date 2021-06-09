import 'dart:async';

import 'package:flutter/material.dart';
import 'package:moxie_fitness/components/components.dart';
import 'package:moxie_fitness/config/routes.dart';
import 'package:moxie_fitness/models/models.dart';
import 'package:numberpicker/numberpicker.dart';

class WorkoutListItem extends StatelessWidget {
  // When [exercisesAddController] is null, then the add icon is not shown.
  // Set a non-null list to add items to it, will be returned when popped.
  final StreamController<CreateRoutineWorkoutUpdate>
      createRoutineWorkoutsAddController;

  // The [workoutsInWeeklyOrder] map contains all of the currently added workouts
  // when adding from the routine.
  final Map<int, List<Workout>> workoutsInWeeklyOrder;

  // When [exercisesAddController] is not null, [maxExercises] is compared against
  // [currentExercises] before sending add update to stream.
  final num createRoutineMaxWeeks;

  final Workout workout;
  final bgColor;
  final bool dense;

  WorkoutListItem(
      {@required this.workout,
      this.createRoutineWorkoutsAddController,
      this.workoutsInWeeklyOrder,
      this.createRoutineMaxWeeks,
      this.bgColor,
      this.dense = false});

  WorkoutListItem.withAdd(
      {@required this.workout,
      @required this.createRoutineWorkoutsAddController,
      @required this.workoutsInWeeklyOrder,
      @required this.createRoutineMaxWeeks,
      this.bgColor,
      this.dense = false})
      : assert(workout != null),
        assert(workoutsInWeeklyOrder != null),
        assert(createRoutineMaxWeeks != null);

  @override
  Widget build(BuildContext context) {
    return !dense ? _buildWorkoutCard(context) : _buildWorkoutTile();
  }

  _buildWorkoutTile() {
    return MoxieCircleImgListTile(
      imgUrl: workout?.post?.media[0],
      onTap: () {},
      description: workout.name,
    );
  }

  _buildWorkoutCard(ctx) {
    return Container(
      color: bgColor ?? Theme.of(ctx).primaryColor,
      child: Card(
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                _buildBody(ctx),
                Container(
                  height: 200.0,
                  child: _buildAddButton(ctx),
                )
              ],
            ),
            _ExercisesFooter(
                workout: workout,
                openable: createRoutineWorkoutsAddController == null),
            _buildCreatorUsername()
          ],
        ),
      ),
    );
  }

  _buildBody(ctx) {
    var carousel = MoxieCarouselListItem(
      title: workout.name,
      onTap: () => Routes.router.navigateTo(ctx, '/workouts/${workout.id}'),
      carouselWidgets: carouselWidgetsFromWorkout(workout),
      textColor: Theme.of(ctx).textTheme.button.color,
    );
    return carousel;
  }

  _buildCreatorUsername() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, right: 8.0),
      child: Align(
        alignment: Alignment.bottomRight,
        child: CustomText.qarmicSans(
          text: 'by ${workout.moxieuser.username}',
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildAddButton(context) {
    return createRoutineWorkoutsAddController != null
        ? Align(
            alignment: Alignment.centerRight,
            child: IconButton(
                icon: Icon(
                  Icons.add,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: () async {
                  int week = await _pickWeekDialog(context) ?? -1;

                  // Ensure a valid selected week
                  if (week >= 0) {
                    // Check limit of 7 per week
                    final List<Workout> workoutsInWeek =
                        workoutsInWeeklyOrder[week] ?? <Workout>[];
                    if (workoutsInWeek.length >= 7) {
                      _showSnackBar(context,
                          '${workout.name} not added. Limit of 7 workouts assigned to week $week');
                      return;
                    }

                    _showSnackBar(
                        context, '${workout.name} added at week $week.');

                    createRoutineWorkoutsAddController.add(
                        CreateRoutineWorkoutUpdate(
                            workout: workout,
                            week: week,
                            type: CreateRoutineWorkoutUpdateType.add));
                  }
                }),
          )
        : Container();
  }

  Future<int> _pickWeekDialog(context) async {
    return await showDialog<int>(
        context: context,
        builder: (BuildContext context) {
          return NumberPickerDialog.integer(
            minValue: 1,
            maxValue: createRoutineMaxWeeks,
            title: Text('Which week to add to?'),
            initialIntegerValue: 1,
          );
        });
  }

  void _showSnackBar(ctx, String content) {
    Scaffold.of(ctx).showSnackBar(SnackBar(
      content: Text(content),
    ));
  }
}

class _ExercisesFooter extends StatelessWidget {
  final Workout workout;
  final bool openable;

  _ExercisesFooter({@required this.workout, this.openable = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                  '${workout.workout_exercises.length == 0 ? '' : '${workout.workout_exercises.length ?? 0} Exercise${(workout.workout_exercises.length > 1 || workout.workout_exercises.length == 0) ? 's' : ''}'}')),
        ),
        workout.workout_exercises.length > 0
            ? Container(
                height: 83.0,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _buildBubbles(context),
                ),
              )
            : Container(),
      ],
    );
  }

  _buildBubbles(ctx) {
    List<Widget> bubbles = <Widget>[];
    workout?.workout_exercises?.forEach((ExerciseWorkout ew) {
      bubbles.add(_buildWorkoutBubble(ew, ctx));
    });
    return bubbles;
  }

  _buildWorkoutBubble(ExerciseWorkout ew, ctx) {
    try {
      final image = ew.exercise?.post?.media?.first;
      return MoxieCircularHero.withUrl(
        diameter: 75.0,
        imgUrl: image,
        onTap: () => openable
            ? Routes.router.navigateTo(ctx, '/exercises/${ew.exercise_id}')
            : null,
      );
    } catch (err) {
      // For when media is empty
      return Container();
    }
  }
}

class CreateRoutineWorkoutUpdate {
  final Workout workout;
  final num onDragFinishOldIndex;
  final num onDragFinishNewIndex;
  final num week;
  final num removeIndex;
  final CreateRoutineWorkoutUpdateType type;

  CreateRoutineWorkoutUpdate(
      {this.workout,
      this.type,
      this.onDragFinishOldIndex,
      this.onDragFinishNewIndex,
      this.week,
      this.removeIndex});
}

enum CreateRoutineWorkoutUpdateType { add, order, remove }
