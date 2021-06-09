import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:moxie_fitness/components/components.dart';
import 'package:moxie_fitness/config/routes.dart';
import 'package:moxie_fitness/models/models.dart';
import 'package:moxie_fitness/utils/utils.dart';
import 'package:youtube_player/youtube_player.dart';

class ExerciseListItem extends StatelessWidget {
  final Exercise exercise;
  final bool dense;

  // When [exercisesAddController] is null, then the add icon is not shown.
  // Set a non-null list to add items to it, will be returned when popped.
  final StreamController<CreateWorkoutExerciseUpdate> exercisesAddController;

  // When [exercisesAddController] is not null, [maxExercises] is compared against
  // [currentExercises] before sending add update to stream.
  final num maxExercises;
  final num currentExercises;

  // [autoplay] for the images Carousel, if false [autoplayDuration] is ignored.
  final autoplay;
  final autoplayDuration;

  ExerciseListItem(
      {@required this.exercise,
      this.exercisesAddController,
      this.autoplay = false,
      this.autoplayDuration = const Duration(seconds: 3),
      this.maxExercises,
      this.currentExercises,
      this.dense = false});

  @override
  Widget build(BuildContext context) {
    final List carouselWidgets = carouselWidgetsFromPost(exercise?.post);

    if (exercise.youtube_url != null && exercise.youtube_url.isNotEmpty) {
      carouselWidgets.add(Builder(builder: (BuildContext context) {
        return YoutubePlayer(
          context: context,
          source: exercise.youtube_url,
          quality: YoutubeQuality.HD,
        );
      }));
    }

    return Utils.addClick(
      param: () =>
          Routes.router.navigateTo(context, '/exercises/${exercise.id}'),
      widget: !dense
          ? buildExerciseCard(carouselWidgets, context)
          : buildExerciseTile(),
    );
  }

  buildExerciseCard(List carouselWidgets, BuildContext context) {
    return new Container(
      color: Theme.of(context).primaryColor,
      child: new Card(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            new Container(
              height: 200.0,
              child: new Stack(
                children: <Widget>[
                  new Carousel(
                    widgets: carouselWidgets,
                    autoplay: false,
                  ),
                  exercisesAddController != null
                      ? new Align(
                          alignment: Alignment.centerRight,
                          child: new IconButton(
                              icon: new Icon(
                                Icons.add,
                                color: Theme.of(context).primaryColor,
                              ),
                              onPressed: () {
                                if (currentExercises + 1 < maxExercises) {
                                  exercisesAddController.add(
                                      new CreateWorkoutExerciseUpdate(
                                          exercise: new ExerciseWorkout()
                                            ..exercise = this.exercise,
                                          type: CreateWorkoutExerciseUpdateType
                                              .add));
                                  Scaffold.of(context)
                                      .showSnackBar(new SnackBar(
                                    content: Text(
                                        'Added ${exercise.name} to workout.'),
                                  ));
                                } else {
                                  Scaffold.of(context)
                                      .showSnackBar(new SnackBar(
                                    content: Text(
                                        'Limit of $maxExercises exercises.'),
                                  ));
                                }
                              }),
                        )
                      : new Container()
                ],
              ),
            ),
            new MoxieFlatButton(
              data: exercise.name,
              onPressed: null,
              textColor: Theme.of(context).textTheme.button.color,
              fontSize: 22.0,
            )
          ],
        ),
      ),
    );
  }

  buildExerciseTile() {
    return new MoxieCircleImgListTile(
      imgUrl: exercise?.post?.media[0],
      onTap: () {},
      description: exercise.name,
    );
  }
}

class CreateWorkoutExerciseUpdate {
  final ExerciseWorkout exercise;
  final num onDragFinishOldIndex;
  final num onDragFinishNewIndex;
  final CreateWorkoutExerciseUpdateType type;

  CreateWorkoutExerciseUpdate(
      {this.exercise,
      this.type,
      this.onDragFinishOldIndex,
      this.onDragFinishNewIndex});
}

enum CreateWorkoutExerciseUpdateType { add, order, update }
