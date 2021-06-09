import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:moxie_fitness/components/components.dart';
import 'package:moxie_fitness/data_layer/actions/all_actions.dart';
import 'package:moxie_fitness/data_layer/app/moxie_app_state.dart';
import 'package:moxie_fitness/data_layer/repository/moxie_repository.dart';
import 'package:moxie_fitness/data_layer/selectors/selectors.dart';
import 'package:moxie_fitness/models/models.dart';
import 'package:moxie_fitness/providers/notifications_provider.dart';
import 'package:provider/provider.dart';
import 'package:redux/redux.dart';

enum SubscribeDialog { subscribe, cancel }

enum StartRoutineDialogOptions { startAndEndPrevious, cancel }

class RoutinePage extends StatefulWidget {
  final id;
  final bool allowSubscription;

  RoutinePage({this.id, this.allowSubscription = false});

  @override
  _RoutinePageState createState() => _RoutinePageState();
}

class _RoutinePageState extends State<RoutinePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController _scrollController;
  bool _saving = false;
  bool _justSubscribed = false;
  bool _isCurrentlySubscribedOnLoadCheck = false;
  bool _isCurrentlySubscribedHasLoadChecked = false;
  bool _savingStartingRoutine = false;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<MoxieAppState, _RoutinePageViewModel>(
        converter: (Store<MoxieAppState> store) {
      return _RoutinePageViewModel.from(store, widget.id);
    }, builder: (context, vm) {
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Theme.of(context).primaryColor,
        body: Stack(
          children: <Widget>[
            vm.routine != null ? _buildRoutinePageBody(vm) : _buildLoading,
            _saving || _savingStartingRoutine
                ? CenteredCircularProgress()
                : Container()
          ],
        ),
        floatingActionButton: _floatingActionButton(vm),
      );
    });
  }

  FloatingActionButton _floatingActionButton(_RoutinePageViewModel vm) {
    if (!_isCurrentlySubscribedHasLoadChecked) {
      moxieRepository.checkIfSubscribed(vm.routine.id).then((isSubbed) {
        setState(() {
          _isCurrentlySubscribedOnLoadCheck = isSubbed;
          _isCurrentlySubscribedHasLoadChecked = true;
        });
      });
    }

    final subscribeFab = FloatingActionButton(
      child: Icon(Icons.get_app),
      onPressed: () {
        _subscriptionDialog(vm);
      },
    );

    final playFab = FloatingActionButton(
      child: Icon(Icons.play_arrow),
      onPressed: () => _handleOnStartRoutineCheck(vm),
    );

    return widget.allowSubscription &&
            !_justSubscribed &&
            !_isCurrentlySubscribedOnLoadCheck
        ? subscribeFab
        : playFab;
  }

  Future<Null> _subscriptionDialog(_RoutinePageViewModel vm) async {
    if (!_isCurrentlySubscribedHasLoadChecked)
      _isCurrentlySubscribedOnLoadCheck =
          await moxieRepository.checkIfSubscribed(vm.routine.id);
    setState(() {});

    if (_isCurrentlySubscribedOnLoadCheck) {
      _scaffoldKey.currentState.showSnackBar(
          SnackBar(content: Text('Already subscribed to this routine!')));
      return;
    }

    switch (await showDialog<SubscribeDialog>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Subscribe '),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                      'After subscribing, this routine will be under your Routines page and you can start it at any time.'),
//                Text('(Todo: payment)'),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Subscribe'),
//              child: Text('${vm.routine?.price != null && vm.routine.price > 0 ? vm.routine.price : ''} Subscribe'),
                onPressed: () {
                  Navigator.pop(context, SubscribeDialog.subscribe);
                },
              ),
              FlatButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context, SubscribeDialog.cancel);
                },
              ),
            ],
          );
        })) {
      case SubscribeDialog.subscribe:
        _handleSubscription(vm.routine.id);
        break;
      case SubscribeDialog.cancel:
        //do nothing
        break;
    }
  }

  get _buildLoading {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  _buildRoutinePageBody(_RoutinePageViewModel vm) {
    final bodyWidgets = <Widget>[
      Card(
        elevation: 1.0,
        child: MoxieCarouselListItem(
          carouselWidgets: carouselWidgetsFromUrls(vm.routine.post.media),
          height: 300.0,
          dotColor: Colors.white,
        ),
      ),
      _buildDescription(vm),
    ];
    bodyWidgets.addAll(_buildWorkouts(vm));

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
                text: '${vm.routine.name}',
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

  _buildDescription(_RoutinePageViewModel vm) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(
                top: 10.0, bottom: 20.0, left: 20.0, right: 20.0),
            child: CustomText.qarmicSans(
              text: vm.routine.post.content,
              maxLines: 8,
              overflow: TextOverflow.fade,
            ),
          ),
        )
      ],
    );
  }

  List<Widget> _buildWorkouts(_RoutinePageViewModel vm) {
    final tiles = vm.routine.routine_workouts.map<Widget>((rw) {
      return WorkoutListItem(
        workout: rw.workout,
        dense: true,
      );
    }).toList();
    return tiles;
  }

  _handleSubscription(int id) {
    if (_saving) return;
    setState(() {
      _saving = true;
    });

    final store = StoreProvider.of<MoxieAppState>(context);

    final rs = RoutineSubscription()
      ..subscriber_moxieuser_id = store.state.moxieuser.id
      ..routine_id = id;

    store.dispatch(SaveAction<RoutineSubscription>(
        item: rs,
        type: EModelTypes.routineSubscription,
        onSavedCallback: (createdRoutineSub) {
          print('Done Saving..');

          if (createdRoutineSub != null) {
            _scaffoldKey.currentState
                .showSnackBar(SnackBar(content: Text('Subscribed!')));
            setState(() {
              _justSubscribed = true;
            });
          }
          setState(() {
            _saving = false;
          });
        }));
  }

  _handleOnStartRoutineCheck(_RoutinePageViewModel vm) async {
    if (_savingStartingRoutine) return;
    setState(() {
      _savingStartingRoutine = true;
    });
    // First check if there is an active routine, done in server-side
    ResponseWrapper<Complete> routineCompletable =
        await moxieRepository.startActiveRoutine(vm.routine.id);

    if (routineCompletable.hasError && routineCompletable.data == null) {
      switch (await showDialog<StartRoutineDialogOptions>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Whoops! End Active Routine?'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(
                        'It looks like you already have an active and unfinished routine! Starting a one will clear any workouts that were not completed.'),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                          'Of course, you\'ll still have a history of any workouts you\'ve finished!'),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('Start New'),
                  onPressed: () => Navigator.pop(
                      context, StartRoutineDialogOptions.startAndEndPrevious),
                ),
                FlatButton(
                  child: Text('Cancel'),
                  onPressed: () =>
                      Navigator.pop(context, StartRoutineDialogOptions.cancel),
                ),
              ],
            );
          })) {
        case StartRoutineDialogOptions.startAndEndPrevious:
          setState(() {
            _savingStartingRoutine = false;
          });
          _handleOnStartRoutineCreation(vm);
          break;
        case StartRoutineDialogOptions.cancel:
          setState(() {
            _savingStartingRoutine = false;
          });
          //do nothing
          break;
      }
    } else {
      _handleOnStartRoutineCreation(vm);
    }
  }

  _handleOnStartRoutineCreation(_RoutinePageViewModel vm) async {
    if (_savingStartingRoutine) return;
    setState(() {
      _savingStartingRoutine = true;
    });

    // Start active routine -> Create all Completes on backend
    ResponseWrapper<Complete> routineCompletable = await moxieRepository
        .startActiveRoutine(vm.routine.id, endPrevious: true);

    if (routineCompletable.hasError || routineCompletable.hasException) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text('Whoops.. Unexpected error, try again later.')));
    } else {
      ResponseWrapper<List<Complete>> newCompletables = await moxieRepository
          .loadAllUncompletedCompletesWithRoutineWorkoutUsers();

      if (!newCompletables.hasError && !newCompletables.hasException) {
        Provider.of<NotificationsProvider>(context)
            .scheduleRoutineCompletableNotifications(newCompletables.data);
      }

      final store = StoreProvider.of<MoxieAppState>(context);
      _scaffoldKey.currentState.showSnackBar(SnackBar(
          content:
              Text('Success! Check your calendar & start your workouts!')));
      store.dispatch(SetActiveRoutineCompletableAction(
          completableRoutine: routineCompletable.data));

      // Update the calendar
      final from = DateTime.now().subtract(Duration(days: 1));
      final to = DateTime.now().add(Duration(days: 45));
      store.dispatch(LoadCompletesForCalendar(from: from, to: to, fresh: true));
    }

    setState(() {
      _savingStartingRoutine = false;
    });
  }
}

class _RoutinePageViewModel {
  Complete activeRoutineCompletable;
  Routine routine;

  _RoutinePageViewModel({
    this.routine,
    this.activeRoutineCompletable,
  });

  factory _RoutinePageViewModel.from(Store<MoxieAppState> store, int id) {
    final routine = store.state.routines[id];
    if ((routine == null ||
            routine.routine_workouts == null ||
            routine.routine_workouts.isEmpty) &&
        !isLoadingSelector(store.state)) {
      store.dispatch(LoadSingleItem(type: EModelTypes.routine, itemId: id));
    }

    return _RoutinePageViewModel(
        routine: routine,
        activeRoutineCompletable: store.state.completesState?.activeRoutine);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _RoutinePageViewModel &&
          runtimeType == other.runtimeType &&
          activeRoutineCompletable == other.activeRoutineCompletable &&
          routine == other.routine;

  @override
  int get hashCode => routine.hashCode ^ activeRoutineCompletable.hashCode;
}
