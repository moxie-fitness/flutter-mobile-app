import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:intl/intl.dart';
import 'package:moxie_fitness/components/components.dart';
import 'package:moxie_fitness/config/routes.dart';
import 'package:moxie_fitness/data_layer/app/moxie_app_state.dart';
import 'package:moxie_fitness/data_layer/repository/moxie_repository.dart';
import 'package:moxie_fitness/models/models.dart';
import 'package:moxie_fitness/utils/utils.dart';
import 'package:redux/redux.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'
    show CalendarCarousel;

class MoxiePage extends StatefulWidget {
  @override
  MoxiePageState createState() => new MoxiePageState();
}

class MoxiePageState extends State<MoxiePage> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  DateTime _currentDate = DateTime.now();
  DateTime _selectedDate = DateTime.now();

//  DateTime _currentDate2 = DateTime(2018, 12, 3);
  String _currentMonth = '';

  MoxiePageState();

  static Widget _pastUncompletedIcon = new Container(
    decoration: new BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(1000.0)),
        border: Border.all(color: Colors.yellow, width: 2.0)),
    child: new Icon(
      Icons.fitness_center,
      color: Colors.black,
    ),
  );

  static Widget _upcomingUncompletedIcon = new Container(
    decoration: new BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(1000.0)),
        border: Border.all(color: Colors.indigoAccent, width: 2.0)),
    child: new Icon(
      Icons.fitness_center,
      color: Colors.black,
    ),
  );

  static Widget _completedIcon = new Container(
    decoration: new BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(1000.0)),
        border: Border.all(color: Colors.green, width: 2.5)),
    child: new Icon(
      Icons.fitness_center,
      color: Colors.black,
    ),
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new StoreConnector<MoxieAppState, _CalendarPageViewModel>(
        converter: (Store<MoxieAppState> store) {
      return new _CalendarPageViewModel.from(store);
    }, builder: (context, _CalendarPageViewModel vm) {
      return Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
          centerTitle: true,
          elevation: 0.4,
          title: CustomText.qarmicSans(
            text: 'Personal Calendar',
            fontSize: 16.0,
          ),
        ),
        body: Container(
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Container(
                      margin:
                          EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
                      child: _generateHeader(vm)),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16.0),
                    child: _generateCalendar(vm),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  _generateCalendar(_CalendarPageViewModel vm) {
    final calendar = CalendarCarousel<Event>(
      onDayPressed: (DateTime date, List<Event> events) {
        this.setState(() => _selectedDate = date);
        if (events?.length != 0) _generateDialog(vm, events);
      },
      weekendTextStyle: TextStyle(
        color: Colors.red,
      ),
      thisMonthDayBorderColor: Colors.grey,
      weekFormat: false,
      markedDatesMap: vm.eventList,
      height: 420.0,
      selectedDateTime: _selectedDate,
      customGridViewPhysics: NeverScrollableScrollPhysics(),
      markedDateShowIcon: true,
      markedDateIconMaxShown: 2,
      markedDateMoreShowTotal:
          false, // null for not showing hidden events indicator
      showHeader: false,
      markedDateIconBuilder: (event) {
        return event.icon;
      },
      minSelectedDate: _currentDate.add(Duration(days: -30)),
      maxSelectedDate: _currentDate.add(Duration(days: 90)),
      onCalendarChanged: (DateTime date) {
        this.setState(() => _currentMonth = DateFormat.yMMM().format(date));
      },
    );

    return calendar;
  }

  _generateHeader(_CalendarPageViewModel vm) {
    final prev = _selectedDate.subtract(Duration(days: 30));
    final next = _selectedDate.add(Duration(days: 30));
    return Container(
      margin: EdgeInsets.only(
        top: 30.0,
        bottom: 16.0,
        left: 16.0,
        right: 16.0,
      ),
      child: new Row(
        children: <Widget>[
          Expanded(
              child: Text(
            _currentMonth,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24.0,
            ),
          )),
          FlatButton(
            child: Text(DateFormat.MMM().format(prev)),
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.subtract(Duration(days: 30));
                _currentMonth = DateFormat.yMMM().format(_selectedDate);
              });
            },
          ),
          FlatButton(
            child: Text(DateFormat.MMM().format(next)),
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.add(Duration(days: 30));
                _currentMonth = DateFormat.yMMM().format(_selectedDate);
              });
            },
          )
        ],
      ),
    );
  }

  _generateDialog(_CalendarPageViewModel vm, List<Event> events) async {
    final options = <SimpleDialogOption>[];
    for (num i = 0; events != null && i < events.length; i++) {
      final event = events[i];
      var completable = vm.completableWorkouts?.firstWhere((Complete c) =>
          c.routine_workout_user?.day == event.date &&
          c.routine_workout_user?.workout?.name == event.title);
      var workoutExercises =
          completable.routine_workout_user.workout.workout_exercises;

      if (workoutExercises == null) {
        completable.routine_workout_user.workout = await moxieRepository
            .loadWorkout(completable.routine_workout_user.workout_id);
        completable.workout = completable.routine_workout_user.workout;
        workoutExercises =
            completable.routine_workout_user.workout.workout_exercises;
      }

      if (completable != null) {
        if (completable.completed) {
          options.add(SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
              },
              child: ListTile(
                enabled: false,
                title: Text('${completable.routine_workout_user.workout.name}'),
                subtitle: Text(
                    'Completed on ${Utils.convertDateToDisplayWithTime(completable.updated_at)}'),
              )));
        } else {
          options.add(SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);

                Routes.router.navigateTo(context,
                    '/workouts/${completable.routine_workout_user.workout.id}/${completable.id}');
              },
              child: ListTile(
                title: Text('${completable.routine_workout_user.workout.name}'),
                subtitle: Text(
                    '${workoutExercises.length} ${workoutExercises.length == 1 ? 'exercise' : 'exercises'}'),
              )));
        }
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
            title: Center(
              child: const Text('Select Workout'),
            ),
            children: options);
      },
    );
  }
}

class _CalendarPageViewModel {
  final Complete activeRoutine;
  final EventList<Event> eventList;
  final List<Complete> completableWorkouts;

  _CalendarPageViewModel(
      {this.activeRoutine, this.eventList, this.completableWorkouts});

  factory _CalendarPageViewModel.from(Store<MoxieAppState> store) {
    final _completableWorkouts = (store
            .state.completesState?.calendarCompletesWorkouts?.values
            ?.toList()) ??
        <Complete>[];
    final _eventList = EventList<Event>();

    _completableWorkouts.forEach((Complete cw) {
      DateTime key = cw.routine_workout_user?.day;

      var icon;
      if (cw.completed) {
        icon = MoxiePageState._completedIcon;
      } else {
        if (key.compareTo(DateTime.now()) > 0) {
          icon = MoxiePageState._upcomingUncompletedIcon;
        } else {
          icon = MoxiePageState._pastUncompletedIcon;
        }
      }

      _eventList.add(
          new DateTime(key.year, key.month, key.day),
          Event(
            date: cw.routine_workout_user?.day,
            icon: icon,
            title: cw.routine_workout_user?.workout?.name,
          ));
    });

    return new _CalendarPageViewModel(
        activeRoutine: store.state.completesState?.activeRoutine,
        eventList: _eventList,
        completableWorkouts: _completableWorkouts);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _CalendarPageViewModel &&
          runtimeType == other.runtimeType &&
          activeRoutine == other.activeRoutine &&
          eventList == other.eventList;

  @override
  int get hashCode => activeRoutine.hashCode ^ eventList.hashCode;
}
