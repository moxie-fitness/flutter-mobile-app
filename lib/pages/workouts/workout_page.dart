import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:moxie_fitness/components/components.dart';
import 'package:moxie_fitness/data_layer/actions/all_actions.dart';
import 'package:moxie_fitness/data_layer/app/moxie_app_state.dart';
import 'package:moxie_fitness/data_layer/repository/moxie_repository.dart';
import 'package:moxie_fitness/models/models.dart';
import 'package:moxie_fitness/pages/pages.dart';
import 'package:redux/redux.dart';
import 'package:moxie_fitness/data_layer/selectors/selectors.dart';

class WorkoutPage extends StatefulWidget {
  final id;
  final int
      completableWorkoutId; // Optional: When re-directing with incoming completable to do

  WorkoutPage({this.id, this.completableWorkoutId});

  @override
  WorkoutPageState createState() => WorkoutPageState();
}

class WorkoutPageState extends State<WorkoutPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController _scrollController;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<MoxieAppState, _WorkoutPageViewModel>(
        converter: (Store<MoxieAppState> store) {
      return _WorkoutPageViewModel.from(
          store, widget.id, widget.completableWorkoutId);
    }, builder: (context, vm) {
      return Scaffold(
          key: _scaffoldKey,
          backgroundColor: Theme.of(context).primaryColor,
          body: Stack(
            children: <Widget>[
              vm.workout != null ? _buildWorkoutPageBody(vm) : _buildLoading,
              _saving ? CenteredCircularProgress() : Container(),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.play_arrow),
            onPressed: () => _checkIfActiveWorkoutExists(vm),
          ));
    });
  }

  SafeArea _buildWorkoutPageBody(_WorkoutPageViewModel vm) {
    final bodyWidgets = <Widget>[
      Card(
        elevation: 1.0,
        child: MoxieCarouselListItem(
          carouselWidgets: carouselWidgetsFromWorkout(vm.workout),
          height: 300.0,
          dotColor: Colors.white,
        ),
      ),
      _buildInstructions(vm),
    ];

    bodyWidgets.addAll(_buildExercises(vm));

    return SafeArea(
      top: false,
      bottom: false,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
        child:
            CustomScrollView(controller: _scrollController, slivers: <Widget>[
          SliverAppBar(
            floating: true,
            pinned: false,
            snap: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: CustomText.qarmicSans(
                text: '${vm.workout.name}',
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((BuildContext context, index) {
              return bodyWidgets[index];
            }, childCount: bodyWidgets.length),
          ),
        ]),
      ),
    );
  }

  _buildInstructions(vm) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              child: CustomText.qarmicSans(
                text: vm.workout.post.content,
                maxLines: 8,
                overflow: TextOverflow.fade,
              ),
            ),
          ),
        )
      ],
    );
  }

  _buildExercises(vm) {
    final tiles = vm.workout.workout_exercises.map<Widget>((ew) {
      return ExerciseListItem(
        exercise: ew.exercise,
        dense: true,
      );
    }).toList();
    return tiles;
  }

  Center get _buildLoading {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  void _checkIfActiveWorkoutExists(_WorkoutPageViewModel vm) {
    if (vm.isAWorkoutActive) {
      final store = StoreProvider.of<MoxieAppState>(context);

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Active Workout'),
              content: Text(
                  'End currently active workout, ${store.state.completesState.activeWorkout.workout.name}?'),
              actions: <Widget>[
                MoxieFlatButton(
                  data: 'Cancel',
                  textColor: Theme.of(context).primaryColor,
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                MoxieFlatButton(
                  data: 'Yes',
                  textColor: Theme.of(context).primaryColor,
                  onPressed: () {
                    Navigator.of(context).pop(false);
                    _createCompletableWorkout(vm);
                  },
                )
              ],
            );
          });
    } else {
      _createCompletableWorkout(vm);
    }
  }

  Future _createCompletableWorkout(_WorkoutPageViewModel vm) async {
    if (_saving) return;

    setState(() {
      _saving = true;
    });

    final store = StoreProvider.of<MoxieAppState>(context);

    if (widget.completableWorkoutId == null) {
      if (vm.workout?.workout_exercises?.length == 0) {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text('Oops... This workout has no exercises!'),
        ));
        return;
      }

      Complete completableWorkout = Complete()
        ..completable_id = widget.id
        ..completable = 'workout'
        ..moxieuser_id = store.state.moxieuser.id;

      store.dispatch(SaveAction<Complete>(
          item: completableWorkout,
          type: EModelTypes.completableWorkout,
          onSavedCallback: (completable) {
            setState(() {
              _saving = false;
            });

            if (completable != null) {
              store.dispatch(SetActiveWorkoutCompletableAction(
                  completableWorkout: completable));

              // Navigate to ActiveWorkoutPage
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ActiveWorkoutPager(completableWorkout: completable)));
            }
          }));
    } else {
      final completable =
          await moxieRepository.loadComplete(widget.completableWorkoutId);

      completable.workout = completable.routine_workout_user.workout;
      store.dispatch(
          SetActiveWorkoutCompletableAction(completableWorkout: completable));

      Future.delayed(const Duration(milliseconds: 200), () {
        setState(() {
          _saving = false;
        });

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ActiveWorkoutPager(completableWorkout: completable)));
      });
    }
  }
}

class _WorkoutPageViewModel {
  final id;
  Workout workout;
  bool isAWorkoutActive;

  _WorkoutPageViewModel({this.id, this.workout, this.isAWorkoutActive});

  factory _WorkoutPageViewModel.from(
      Store<MoxieAppState> store, int id, int completableWorkoutId) {
    final workout = store.state.workouts[id];

    if ((workout == null || workout.workout_exercises == null) &&
        !isLoadingSelector(store.state)) {
      store.dispatch(LoadSingleItem(type: EModelTypes.workout, itemId: id));
    }

    return _WorkoutPageViewModel(
        workout: workout,
        isAWorkoutActive: store.state.completesState != null &&
            store.state.completesState.activeWorkout != null);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _WorkoutPageViewModel &&
          runtimeType == other.runtimeType &&
          workout == other.workout;

  @override
  int get hashCode => workout.hashCode;
}
