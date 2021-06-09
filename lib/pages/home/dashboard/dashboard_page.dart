import 'package:flutter/material.dart';
import 'package:moxie_fitness/components/components.dart';
import 'package:moxie_fitness/config/routes.dart';

class DashboardPage extends StatefulWidget {
  @override
  DashboardPageState createState() => new DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> {
  bool showWeekdayIndication = true;
  bool showTicks = true;
  DateTime initialDate;
  String displayedMonthText = "____";
  Widget smallCalendar;

  void handleNewDate(date) {
    print(date);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        elevation: 0.4,
        title: new AppBarSearchButton(
          hint: 'Looking for a different Routine?',
          onTap: () => Routes.router.navigateTo(context, Routes.searchRoutines),
        ),
      ),
      backgroundColor: Theme.of(context).primaryColor,
      body: new Container(
//        color: Theme.of(context).primaryColor,
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            new MoxieRoundImageCard(
              title: 'Exericses',
              desc: 'See all of myexercises',
              tag: 'exercises',
              imageProvider: new MoxieNetworkImage(
                imgUrl:
                    'https://cdn3.iconfinder.com/data/icons/round-icons-vol-1-2/120/strength-512.png',
              ),
              route: Routes.exercisesList,
            ),
            new MoxieRoundImageCard(
              title: 'Workouts',
              desc: 'See all of my workouts',
              tag: 'workouts',
              imageProvider: new MoxieNetworkImage(
                  imgUrl:
                      'https://cdn1.iconfinder.com/data/icons/cool-kiddo-1/512/barbells-fitness-round-512.png'),
              route: Routes.workoutsList,
            ),
            new MoxieRoundImageCard(
              title: 'Routines',
              desc: 'See all of my routines',
              tag: 'routines',
              imageProvider: new MoxieNetworkImage(
                  imgUrl:
                      'http://webiconspng.com/wp-content/uploads/2017/01/Calendar-Graphic-Icon.png'),
              route: Routes.routinesList,
            ),
          ],
        ),
      ),
    );
  }
}
