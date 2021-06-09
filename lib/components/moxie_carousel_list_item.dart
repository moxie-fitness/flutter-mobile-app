import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:moxie_fitness/components/components.dart';
import 'package:moxie_fitness/models/models.dart';
import 'package:moxie_fitness/utils/utils.dart';

class MoxieCarouselListItem extends StatelessWidget {
  final String title;
  final String desc;
  final height;
  final fontSize;
  final bool autoplay;
  final List carouselWidgets;
  final Color textColor;
  final Color dotColor;
  final Function onTap;

  MoxieCarouselListItem({
    this.title,
    this.desc,
    this.height = 200.0,
    this.autoplay = false,
    this.carouselWidgets,
    this.textColor = Colors.black,
    this.dotColor = Colors.black,
    this.onTap,
    this.fontSize = 22.0,
  });

  @override
  Widget build(BuildContext context) {
    return Utils.addClick(
        widget: Column(
          children: <Widget>[
            Container(
              height: height,
              color: Colors.transparent,
              child: Carousel(
                widgets: carouselWidgets,
                autoplay: autoplay,
                dotColor: dotColor,
                dotSize: 5.0,
              ),
            ),
            title != null
                ? MoxieFlatButton(
                    data: title,
                    onPressed: onTap,
                    textColor: textColor,
                    fontSize: fontSize,
                  )
                : Container(),
            desc != null
                ? CustomText.qarmicSans(
                    text: desc,
                    color: Theme.of(context).primaryTextTheme.title.color,
                    maxLines: 3,
                  )
                : Container(),
          ],
        ),
        param: onTap);
  }
}

carouselWidgetsFromUrls(List<String> media) {
  final carouselWidgets = media?.map((url) {
        return Builder(builder: (BuildContext context) {
          return Container(
            child: MoxieNetworkImage(
              imgUrl: url,
              margin: const EdgeInsets.all(0.0),
              fillCover: true,
            ),
          );
        });
      })?.toList() ??
      [];
  return carouselWidgets;
}

carouselWidgetsFromFiles(List<File> files) {
  final carouselWidgets = files?.map((file) {
        return Builder(builder: (BuildContext context) {
          return Utils.addClick(
            param: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ImageFullscreenPage(image: file),
                )),
            widget: Container(
              width: MediaQuery.of(context).size.width,
              child: Image.file(
                file,
                fit: BoxFit.cover,
              ),
            ),
          );
        });
      })?.toList() ??
      [];
  return carouselWidgets;
}

carouselWidgetsFromPost(Post post) {
  return post?.media?.map((url) {
        return new Builder(builder: (BuildContext context) {
          return new Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.all(0.0),
            child: MoxieNetworkImage(
              imgUrl: url,
              margin: const EdgeInsets.all(0.0),
            ),
          );
        });
      })?.toList() ??
      <Widget>[];
}

carouselWidgetsFromWorkout(Workout workout) {
  final List<Widget> carouselWidgets = carouselWidgetsFromPost(workout?.post);
  if (carouselWidgets.isEmpty &&
      (workout.workout_exercises?.isNotEmpty ?? false)) {
    final List<String> firstOfEachExercise = workout.workout_exercises
        .map((ExerciseWorkout ew) => ew.exercise?.post?.media?.first)
        .toList();
    final exercisesCarouselWidgets =
        carouselWidgetsFromUrls(firstOfEachExercise);
    carouselWidgets.addAll(exercisesCarouselWidgets);
  }
  return carouselWidgets ?? [];
}
