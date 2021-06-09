import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_list_drag_and_drop/drag_and_drop_list.dart';
import 'package:moxie_fitness/components/components.dart';
import 'package:moxie_fitness/models/models.dart';

class WorkoutsCustomizeOrder extends StatefulWidget {
  final StreamController<CreateRoutineWorkoutUpdate> workoutsAddController;
  final SplayTreeMap<int, List<Workout>> workoutsInWeeklyOrder;
  final Color backgroundColor;

  WorkoutsCustomizeOrder({
    this.workoutsInWeeklyOrder,
    this.backgroundColor,
    this.workoutsAddController,
  });

  @override
  _WorkoutsCustomizeOrderState createState() =>
      new _WorkoutsCustomizeOrderState();
}

class _WorkoutsCustomizeOrderState extends State<WorkoutsCustomizeOrder> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: widget.backgroundColor,
        elevation: 0.4,
        title: new Text('Customize Order'),
        actions: <Widget>[
          new IconButton(
              icon: new Icon(
                Icons.info_outline,
                color: Colors.grey,
              ),
              onPressed: _showInfoDialog)
        ],
      ),
      body: new Container(
        color: widget.backgroundColor,
        child: new CustomScrollView(
          primary: true,
          slivers: <Widget>[
            new SliverPadding(
              padding: const EdgeInsets.only(
                  top: 8.0, left: 8.0, bottom: 8.0, right: 25.0),
              sliver: _getWeeks(),
            )
          ],
        ),
      ),
    );
  }

  SliverList _getWeeks() {
    List<Widget> weeks = <Widget>[];
    widget.workoutsInWeeklyOrder?.forEach((week, workouts) {
      List<WorkoutRoutine> wrs = <WorkoutRoutine>[];
      for (num i = 0; i < workouts?.length; i++) {
        wrs.add(new WorkoutRoutine()
          ..workout = workouts[i]
          ..pos = i
          ..week = week);
      }

      if (workouts != null && workouts.length > 0) {
        weeks.add(new _WeekWithWorkouts(
          workoutsAddController: widget.workoutsAddController,
          week: week,
          weekWorkouts: wrs,
        ));
      }
    });

    return new SliverList(delegate: new SliverChildListDelegate(weeks));
  }

  _showInfoDialog() {
    showDialog<Null>(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
            content: new Text(
                'Hold & press to drag workouts and change order. You can also remove any workouts from this routine by tapping the red minus sign.'),
            actions: <Widget>[
              new MoxieFlatButton(
                data: 'Ok',
                onPressed: () => Navigator.pop(context),
                textColor: widget.backgroundColor,
              )
            ],
          );
        });
  }
}

class _WeekWithWorkouts extends StatefulWidget {
  final num week;
  final List<WorkoutRoutine> weekWorkouts;
  final StreamController<CreateRoutineWorkoutUpdate> workoutsAddController;

  _WeekWithWorkouts({
    @required this.week,
    @required this.weekWorkouts,
    @required this.workoutsAddController,
  });

  @override
  _WeekWithWorkoutsState createState() {
    return new _WeekWithWorkoutsState();
  }
}

class _WeekWithWorkoutsState extends State<_WeekWithWorkouts> {
  final double _listItemHeight = 60.0;

  @override
  Widget build(BuildContext context) {
    return widget.weekWorkouts == null
        ? new Container()
        : _getWeekWithWorkouts();
  }

  _getWeekWithWorkouts() {
    return new Container(
      margin: const EdgeInsets.only(bottom: 35.0),
      child: new Column(
        children: <Widget>[_getWeekTitle(), _getWeekListItems()],
      ),
    );
  }

  Widget _getWeekTitle() {
    return new Text(
      'Week ${widget.week}',
      style: new TextStyle(
          color: Colors.white,
          decorationStyle: TextDecorationStyle.wavy,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w500,
          fontSize: 16.0),
    );
  }

  Container _getWeekListItems() {
    return new Container(
      height: _listItemHeight * widget.weekWorkouts.length,
      child: new Card(
        child: new DragAndDropList<WorkoutRoutine>(
          widget.weekWorkouts,
          itemBuilder: (BuildContext context, item) {
            // item type => WorkoutRoutine
            return new SizedBox(
              height: _listItemHeight,
              child: new ListTile(
                leading: new Text(
                  '${widget.weekWorkouts.indexOf(item) + 1}. ',
                  overflow: TextOverflow.ellipsis,
                  style: new TextStyle(
                      fontWeight: FontWeight.w300, fontSize: 12.0),
                ),
                trailing: new IconButton(
                    icon: new Icon(
                      Icons.remove,
                      color: Colors.redAccent,
                    ),
                    onPressed: () => _showRemoveDialog(item)),
                title: new Text(
                  item.workout.name,
                  overflow: TextOverflow.ellipsis,
                  style: new TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14.0,
                  ),
                ),
              ),
            );
          },
          canBeDraggedTo: (int oldIndex, int newIndex) => true,
          onDragFinish: (oldIndex, newIndex) {
            print('$oldIndex, $newIndex');
            // Change order locally too, to update Day of week
            setState(() {
              var temp = widget.weekWorkouts.removeAt(oldIndex);
              widget.weekWorkouts.insert(newIndex, temp);
            });

            widget.workoutsAddController.add(new CreateRoutineWorkoutUpdate(
                onDragFinishNewIndex: newIndex,
                onDragFinishOldIndex: oldIndex,
                week: widget.week,
                type: CreateRoutineWorkoutUpdateType.order));
          },
        ),
      ),
    );
  }

  _showRemoveDialog(item) {
    final removeButton = new MoxieFlatButton(
      data: 'Yes',
      textColor: Colors.orangeAccent,
      onPressed: () {
        final num removeIndex = widget.weekWorkouts.indexOf(item);

        // Remove locally
        setState(() {
          widget.weekWorkouts.removeAt(removeIndex);
        });

        // Dispatch remove stream
        widget.workoutsAddController.add(new CreateRoutineWorkoutUpdate(
          type: CreateRoutineWorkoutUpdateType.remove,
          week: widget.week,
          removeIndex: removeIndex,
        ));

        Navigator.of(context).pop();
      },
    );

    final cancelButton = new MoxieFlatButton(
      data: 'Cancel',
      textColor: Colors.orangeAccent,
      onPressed: () => Navigator.of(context).pop(),
    );

    showDialog<Null>(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text(
                'Do you want to remove this workout from this routine?'),
            actions: <Widget>[
              cancelButton,
              removeButton,
            ],
          );
        });
  }
}
