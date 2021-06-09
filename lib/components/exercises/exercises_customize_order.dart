import 'dart:async';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:moxie_fitness/components/components.dart';
import 'package:flutter_list_drag_and_drop/drag_and_drop_list.dart';
import 'package:moxie_fitness/models/models.dart';

class ExercisesWorkoutCustom extends StatefulWidget {
  final StreamController<CreateWorkoutExerciseUpdate> exercisesAddController;
  final List<ExerciseWorkout> exercises;
  final Color fontAndIconColors;
  final Color backgroundColor;
  final num maxExercises;

  ExercisesWorkoutCustom({
    @required this.exercises,
    this.fontAndIconColors = Colors.white,
    this.backgroundColor = Colors.white,
    this.maxExercises,
    this.exercisesAddController
  });

  @override
  _ExercisesWorkoutCustom createState() {
    return new _ExercisesWorkoutCustom();
  }
}

class _ExercisesWorkoutCustom extends State<ExercisesWorkoutCustom> {

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: widget.backgroundColor,
      appBar: new AppBar(
        backgroundColor: widget.backgroundColor,
        centerTitle: true,
        title: new Text('Customize exercises'),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.check),
            onPressed: () {
              Navigator.of(context).pop();
            }
          )
        ],
        elevation: 0.0,
      ),
      body: new SafeArea(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            new Expanded(
              child: new Container(
                child: new DragAndDropList<ExerciseWorkout>(
                  widget.exercises,
                  itemBuilder: (BuildContext context,  item) {
                    return new SizedBox(
                      child: new CustomizeExerciseDetails(
                        exerciseWorkout: item,
                        exercisesAddController: widget.exercisesAddController,
                      ),
                    );
                  },
                  canBeDraggedTo: (int oldIndex, int newIndex) => true,
                  onDragFinish: (oldIndex, newIndex) {
                    print('$oldIndex, $newIndex');
                    if(widget.exercisesAddController != null) {
                      widget.exercisesAddController.add(
                        new CreateWorkoutExerciseUpdate(
                          onDragFinishNewIndex: newIndex,
                          onDragFinishOldIndex: oldIndex,
                          type: CreateWorkoutExerciseUpdateType.order
                        )
                      );
                    }
                  },
                ),
              ),
            ),
          ]
        ),
      ),
    );
  }
}

class CustomizeExerciseDetails extends StatefulWidget {

  final ExerciseWorkout exerciseWorkout;
  final StreamController<CreateWorkoutExerciseUpdate> exercisesAddController;

  CustomizeExerciseDetails({
    this.exerciseWorkout,
    this.exercisesAddController
  });

  @override
  CustomizeExerciseDetailsState createState() {
    return new CustomizeExerciseDetailsState();
  }
}

class CustomizeExerciseDetailsState extends State<CustomizeExerciseDetails> {
  @override
  Widget build(BuildContext context) {
    return new Card(
      child: new Container(
        color: Theme.of(context).primaryColorDark,
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            new Row(
              children: <Widget>[
                new Expanded(
                  child: new ListTile(
                    title: new Text(
                      '${widget.exerciseWorkout.exercise.name}',
                      style: new TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                new Container(
                  margin: const EdgeInsets.only(right: 8.0),
                  child: new Icon(
                    Icons.reorder,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                new Expanded(
                  flex: 1,
                  child: new Container(
                    margin: const EdgeInsets.all(8.0),
                    child: new MoxieNumberPicker(
                      hint: '${widget.exerciseWorkout.sets} Sets',
                      title: 'Sets',
                      current: widget.exerciseWorkout.sets,
                      max: 6,
                      min: 0,
                      icon: Icons.fitness_center,
                      onUpdated: (val) {
                        setState(() {
                          widget.exerciseWorkout.sets = val;
                        });
                        _sendUpdate(
                          widget.exerciseWorkout
                        );
                      },
                    ),
                  ),
                ),
                new Expanded(
                  flex: 1,
                  child: new Container(
                    margin: const EdgeInsets.all(8.0),
                    child: new MoxieNumberPicker(
                      hint: '${widget.exerciseWorkout.reps} Reps',
                      title: 'Repetitions',
                      max: 100,
                      min: 0,
                      icon: Icons.fitness_center,
                      current: widget.exerciseWorkout.reps,
                      onUpdated: (val) {
                        setState(() {
                          widget.exerciseWorkout.reps = val;
                        });
                        _sendUpdate(
                          widget.exerciseWorkout
                        );
                      },
                    ),
                  ),
                )
              ],
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                new Expanded(
                  flex: 1,
                  child: new Container(
                    margin: const EdgeInsets.all(8.0),
                    child: new MoxieNumberPicker(
                      hint: '${widget.exerciseWorkout.weight} TODO',
                      title: 'Weight',
                      max: 1000,
                      min: 0,
                      icon: Icons.line_weight,
                      current: widget.exerciseWorkout.weight,
                      decimalPlaces: 1,
                      onUpdated: (val) {
                        setState(() {
                          widget.exerciseWorkout.weight = val;
                        });
                        _sendUpdate(
                          widget.exerciseWorkout
                        );
                      },
                    ),
                  ),
                ),
                new Expanded(
                  flex: 1,
                  child: new Container(
                    margin: const EdgeInsets.all(8.0),
                    child: new MoxieNumberPicker(
                      hint: '${widget.exerciseWorkout.duration_secs} s',
                      title: 'Duration in seconds',
                      current: widget.exerciseWorkout.duration_secs,
                      max: 1000,
                      min: 0,
                      onUpdated: (val) {
                        setState(() {
                          widget.exerciseWorkout.duration_secs = val;
                        });
                        _sendUpdate(
                          widget.exerciseWorkout
                        );
                      },
                      icon: Icons.av_timer,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _sendUpdate(ExerciseWorkout updated) {
    widget.exercisesAddController.add(
        new CreateWorkoutExerciseUpdate(
            exercise: updated,
            type: CreateWorkoutExerciseUpdateType.update
        )
    );
  }
}

