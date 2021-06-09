import 'dart:async';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:moxie_fitness/components/components.dart';
import 'package:moxie_fitness/models/models.dart';
import 'package:moxie_fitness/pages/pages.dart';

class ExercisesPickerOpener extends StatelessWidget {
  final List<ExerciseWorkout> exercises;
  final Color fontAndIconColors;
  final Color backgroundColor;

  final StreamController<CreateWorkoutExerciseUpdate> exercisesAddController;
  final num maxExercises;

  ExercisesPickerOpener(
      {@required this.exercises,
      this.fontAndIconColors = Colors.white,
      this.backgroundColor = Colors.white,
      this.maxExercises,
      this.exercisesAddController});

  @override
  Widget build(BuildContext context) {
    return new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new MoxieRoundButton(
              data:
                  "${(exercises?.length ?? 0) > 0 ? "Update" : "Select"} Exercises",
              color: Theme.of(context).primaryColor,
              width: 250.0,
              height: 50.0,
              onTap: () {
                Navigator.push(
                  context,
                  new MaterialPageRoute(
                    builder: (context) => new ExercisesListPage(
                      createWorkoutExercisesAddController:
                          exercisesAddController,
                      createWorkoutMaxExercises: maxExercises,
                      createWorkoutCurrentExercises: exercises.length,
                    ),
                  ),
                );
              }),
          exercises?.length != null && exercises.length > 0
              ? new Padding(
                  padding:
                      const EdgeInsets.only(top: 20.0, left: 8.0, right: 8.0),
                  child: new MoxieRoundButton(
                      data: "Customize Order",
                      color: Theme.of(context).accentColor,
                      width: 220.0,
                      height: 50.0,
                      onTap: () {
                        Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => new ExercisesWorkoutCustom(
                                    exercises: exercises,
                                    exercisesAddController:
                                        exercisesAddController,
                                    backgroundColor: backgroundColor,
                                    fontAndIconColors: fontAndIconColors,
                                    maxExercises: maxExercises,
                                  )),
                        );
                      }),
                )
              : new Container(),
          (exercises?.length ?? 0) > 0
              ? new Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: new Text(
                    '${exercises.length} Exercises',
                    style: new TextStyle(
                      color: Colors.white,
                      fontSize: 15.0,
                    ),
                  ),
                )
              : new Container(),
        ]);
  }
}
