import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:moxie_fitness/components/components.dart';
import 'package:moxie_fitness/config/routes.dart';
import 'package:moxie_fitness/models/models.dart';

class RoutineListItem extends StatelessWidget {
  final Routine routine;
  final Color outerBgColor;
  final bool allowSubscription;
  final String currentUserId;

  RoutineListItem(
      {@required this.routine,
      this.outerBgColor = Colors.white,
      this.allowSubscription = false,
      this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return new Container(
      color: outerBgColor,
      child: new Card(
        child: new Column(
          children: <Widget>[
            _MediaBody(routine: routine, allowSubscription: allowSubscription),
            new Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: new Opacity(
                opacity: .5,
                child: new Divider(
                  color: Colors.black,
                ),
              ),
            ),
            new Padding(
              padding: const EdgeInsets.all(8.0),
              child: _WorkoutsFooter(routine: routine),
            ),
          ],
        ),
      ),
    );
  }
}

class _MediaBody extends StatelessWidget {
  final Routine routine;
  final bool allowSubscription;
  final String currentUserId;

  _MediaBody(
      {@required this.routine,
      this.allowSubscription = false,
      this.currentUserId});

  @override
  Widget build(BuildContext context) {
    var route = '/routines/${routine.id}';
    if (allowSubscription) {
      route =
          '/subscribe-routines/${routine.id}/${(routine?.moxieuser_id != currentUserId && routine?.moxieuser_id != Moxieuser.MOXIE) ? 1 : 0}';
    }

    final List<Widget> carouselWidgets = carouselWidgetsFromPost(routine?.post);
    return new MoxieCarouselListItem(
      title: routine.name,
      onTap: () => Routes.router.navigateTo(context, route),
      carouselWidgets: carouselWidgets,
      textColor: Theme.of(context).textTheme.button.color,
    );
  }
}

class _WorkoutsFooter extends StatelessWidget {
  final Routine routine;

  _WorkoutsFooter({@required this.routine});

  @override
  Widget build(BuildContext context) {
    return new Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        new Align(
            alignment: Alignment.centerLeft,
            child: new Text(
                '${routine.routine_workouts.length ?? 0} Workout${(routine.routine_workouts.length > 1) ? 's' : ''}')),
        new Container(
          height: 83.0,
          child: new ListView(
            scrollDirection: Axis.horizontal,
            children: _buildBubbles(context),
          ),
        ),
      ],
    );
  }

  _buildBubbles(ctx) {
    List<Widget> bubbles = <Widget>[];
    routine?.routine_workouts?.forEach((WorkoutRoutine wr) {
      if (bubbles.length < 5) {
        bubbles.add(_buildWorkoutBubble(wr, ctx));
      }
    });

    return bubbles;
  }

  _buildWorkoutBubble(WorkoutRoutine wr, ctx) {
    try {
      final image = wr.workout?.post?.media?.first;
      return new MoxieCircularHero.withUrl(
        diameter: 75.0,
        imgUrl: image,
        onTap: () =>
            Routes.router.navigateTo(ctx, '/workouts/${wr.workout_id}'),
      );
    } catch (err) {
      // For when media is empty
      return new Container();
    }
  }
}
