import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:moxie_fitness/components/components.dart';
import 'package:moxie_fitness/models/models.dart';
import 'package:moxie_fitness/pages/pages.dart';

class WorkoutsPickerOpener extends StatelessWidget {
  final SplayTreeMap<int, List<Workout>> workoutsInWeeklyOrder;
  final Color fontAndIconColors;
  final Color backgroundColor;

  final StreamController<CreateRoutineWorkoutUpdate> workoutsAddController;
  final int maxWeeks;

  const WorkoutsPickerOpener(
      {@required this.workoutsInWeeklyOrder,
      this.fontAndIconColors = Colors.white,
      this.backgroundColor = Colors.white,
      this.maxWeeks,
      this.workoutsAddController});

  @override
  Widget build(BuildContext context) {
    final total = _getTotalWorkoutsAdded();
    return new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new MoxieRoundButton(
              data:
                  "${workoutsInWeeklyOrder.length > 0 ? "Add" : "Select"} Workouts",
              color: Theme.of(context).primaryColor,
              width: 250.0,
              height: 50.0,
              onTap: () {
                Navigator.push(
                  context,
                  new MaterialPageRoute(
                    builder: (context) => new WorkoutsListPage.picker(
                          workoutsInWeeklyOrder: workoutsInWeeklyOrder,
                          createRoutineWorkoutsAddController:
                              workoutsAddController,
                          createRoutineMaxWeeks: maxWeeks,
                        ),
                  ),
                );
              }),
          workoutsInWeeklyOrder?.length != null &&
                  workoutsInWeeklyOrder.length > 0
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
                              builder: (context) => new WorkoutsCustomizeOrder(
                                    workoutsInWeeklyOrder:
                                        workoutsInWeeklyOrder,
                                    backgroundColor: backgroundColor,
                                    workoutsAddController:
                                        workoutsAddController,
                                  )),
                        );
                      }),
                )
              : new Container(),
          total > 0
              ? new Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: new Text(
                    '${total} Workouts',
                    style: new TextStyle(
                      color: Colors.white,
                      fontSize: 15.0,
                    ),
                  ),
                )
              : new Container(),
        ]);
  }

  num _getTotalWorkoutsAdded() {
    if (workoutsInWeeklyOrder == null) return 0;

    num total = 0;
    workoutsInWeeklyOrder.forEach((i, wr) {
      total += wr.length;
    });
    return total;
  }
}
