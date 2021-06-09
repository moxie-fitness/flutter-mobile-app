import 'dart:collection';

import 'package:moxie_fitness/data_layer/actions/actions.dart';
import 'package:moxie_fitness/data_layer/actions/all_actions.dart';
import 'package:moxie_fitness/data_layer/app/moxie_app_state.dart';
import 'package:moxie_fitness/data_layer/repository/moxie_repository.dart';
import 'package:moxie_fitness/models/models.dart';
import 'package:redux/redux.dart';

List<Middleware<MoxieAppState>> createStoreMiddleware([repository]) {
  final loadMoxiuser = _createLoadMoxieuser(repository);
  final saveMoxieuserDetails = _createSaveMoxieuserDetails(repository);

  final loadFeeds = _createLoadFeeds(repository);

  final loadCommentsForPost = _createLoadCommentsForPost(repository);

  final loadExercises = _createLoadExercises(repository);
  final loadWorkouts = _createLoadWorkouts(repository);
  final loadRoutines = _createLoadRoutines(repository);
  final loadSearchRoutines = _createLoadSearchRoutines(repository);

  final loadExerciseLogs = _createLoadExerciseLogs(repository);

  final saveItem = _createSaveItem(repository);

  final loadLookupOptions = _createLoadLookupOptions(repository);

  final loadSingleItem = _createLoadSingleItem(repository);

  final loadCompletesForCalendar = _createLoadCompletesForCalendar(repository);

  return <Middleware<MoxieAppState>>[
    new TypedMiddleware<MoxieAppState, LoadMoxieuserAction>(loadMoxiuser),
    new TypedMiddleware<MoxieAppState, SaveMoxieuserDetailsAction>(
        saveMoxieuserDetails),
    new TypedMiddleware<MoxieAppState, LoadFeedsAction>(loadFeeds),
    new TypedMiddleware<MoxieAppState, LoadPostCommentsAction>(
        loadCommentsForPost),
    new TypedMiddleware<MoxieAppState, LoadExercisesAction>(loadExercises),
    new TypedMiddleware<MoxieAppState, LoadWorkoutsAction>(loadWorkouts),
    new TypedMiddleware<MoxieAppState, LoadRoutinesAction>(loadRoutines),
    new TypedMiddleware<MoxieAppState, LoadSearchRoutinesAction>(
        loadSearchRoutines),
    new TypedMiddleware<MoxieAppState, LoadExerciseLogsAction>(
        loadExerciseLogs),
    new TypedMiddleware<MoxieAppState, SaveAction<Exercise>>(saveItem),
    new TypedMiddleware<MoxieAppState, SaveAction<Workout>>(saveItem),
    new TypedMiddleware<MoxieAppState, SaveAction<Routine>>(saveItem),
    new TypedMiddleware<MoxieAppState, SaveAction<ExerciseLog>>(saveItem),
    new TypedMiddleware<MoxieAppState, SaveAction<Feed>>(saveItem),
    new TypedMiddleware<MoxieAppState, SaveAction<Post>>(saveItem),
    new TypedMiddleware<MoxieAppState, SaveAction<Complete>>(saveItem),
    new TypedMiddleware<MoxieAppState, SaveAction<RoutineSubscription>>(
        saveItem),
    new TypedMiddleware<MoxieAppState, SaveAction<Rating>>(saveItem),
    new TypedMiddleware<MoxieAppState, SaveAction<Comment>>(saveItem),
    new TypedMiddleware<MoxieAppState, LoadLookupOptions>(loadLookupOptions),
    new TypedMiddleware<MoxieAppState, LoadSingleItem>(loadSingleItem),
    new TypedMiddleware<MoxieAppState, LoadCompletesForCalendar>(
        loadCompletesForCalendar),
  ];
}

Middleware<MoxieAppState> _createLoadMoxieuser(MoxieRepository repository) {
  return (Store<MoxieAppState> store, action, NextDispatcher next) {
    repository.loadMoxieuser().then((moxieuser) {
      store.dispatch(
        new MoxieuserLoadedAction(moxieuser: moxieuser),
      );
    });
    next(action);
  };
}

Middleware<MoxieAppState> _createSaveMoxieuserDetails(
    MoxieRepository repository) {
  return (Store<MoxieAppState> store, action, NextDispatcher next) {
    repository.saveMoxieuserDetails(action.moxieuser).then((success) {
      action.onSavedCallback(null);
    });
    next(action);
  };
}

Middleware<MoxieAppState> _createLoadFeeds(MoxieRepository repository) {
  return (Store<MoxieAppState> store, action, NextDispatcher next) {
    repository.loadFeeds(filter: action.filter).then((feeds) {
      action?.completer?.complete();
      store.dispatch(FeedsLoadedAction(
          filter: action.filter,
          freshValues: action.freshValues,
          feeds: LinkedHashMap<num, Feed>()
            ..addEntries(feeds.map((f) {
              return MapEntry(f.id, f);
            }))));
    });
    next(action);
  };
}

Middleware<MoxieAppState> _createLoadCommentsForPost(
    MoxieRepository repository) {
  return (Store<MoxieAppState> store, action, NextDispatcher next) {
    repository
        .loadCommentsForPost(postId: action.postId, filter: action.filter)
        .then((comments) {
      action?.completer?.complete();
      store.dispatch(new PostCommentsLoadedAction(
          postId: action.postId,
          filter: action.filter,
          freshValues: action.freshValues,
          comments: new LinkedHashMap<num, Comment>()
            ..addEntries(comments.map((c) {
              return MapEntry(c.id, c);
            }))));
    });
    next(action);
  };
}

Middleware<MoxieAppState> _createLoadExercises(MoxieRepository repository) {
  return (Store<MoxieAppState> store, action, NextDispatcher next) {
    repository.loadExercises(filter: action.filter).then((exercises) {
      action?.completer?.complete();
      store.dispatch(
        new ExercisesLoadedAction(
            filter: action.filter,
            freshValues: action.freshValues,
            exercises: new LinkedHashMap<num, Exercise>()
              ..addEntries(exercises.map((ex) {
                return MapEntry(ex.id, ex);
              }))),
      );
    });
    next(action);
  };
}

Middleware<MoxieAppState> _createLoadWorkouts(MoxieRepository repository) {
  return (Store<MoxieAppState> store, action, NextDispatcher next) {
    repository.loadWorkouts(filter: action.filter).then((workouts) {
      store.dispatch(
        new WorkoutsLoadedAction(
            filter: action.filter,
            freshValues: action.freshValues,
            workouts: new LinkedHashMap<num, Workout>()
              ..addEntries(workouts.map((w) {
                return MapEntry(w.id, w);
              }))),
      );
      action?.completer?.complete();
    });
    next(action);
  };
}

Middleware<MoxieAppState> _createLoadRoutines(MoxieRepository repository) {
  return (Store<MoxieAppState> store, action, NextDispatcher next) {
    repository.loadRoutines(filter: action.filter).then((routines) {
      action?.completer?.complete();
      store.dispatch(
        new RoutinesLoadedAction(
            filter: action.filter,
            freshValues: action.freshValues,
            routines: new LinkedHashMap<num, Routine>()
              ..addEntries(routines.map((r) {
                return MapEntry(r.id, r);
              }))),
      );
    });
    next(action);
  };
}

Middleware<MoxieAppState> _createLoadSearchRoutines(
    MoxieRepository repository) {
  return (Store<MoxieAppState> store, action, NextDispatcher next) {
    repository.loadRoutines(filter: action.filter).then((routines) {
      action?.completer?.complete();
      store.dispatch(
        new SearchRoutinesLoadedAction(
            freshValues: action.freshValues,
            filter: action.filter,
            searchRoutines: new LinkedHashMap<num, Routine>()
              ..addEntries(routines.map((r) {
                return MapEntry(r.id, r);
              }))),
      );
    });
    next(action);
  };
}

Middleware<MoxieAppState> _createSaveItem(MoxieRepository repository) {
  return (Store<MoxieAppState> store, action, NextDispatcher next) async {
    var itemSaved;
    var dispatchAction;
    switch (action.type) {
      case EModelTypes.exercise:
        itemSaved = await repository.saveExercise(action.item);
        dispatchAction = new ExerciseSavedAction(exercise: itemSaved);
        break;
      case EModelTypes.workout:
        itemSaved = await repository.saveWorkout(action.item);
        dispatchAction = new WorkoutSavedAction(workout: itemSaved);
        break;
      case EModelTypes.routine:
        itemSaved = await repository.saveRoutine(action.item);
        dispatchAction = new LoadSingleItem(
            type: EModelTypes.routine, itemId: itemSaved.moxieuserId);
        break;
      case EModelTypes.exerciseLog:
        itemSaved = await repository.saveExerciseLog(action.item);
        var exerciseToUpdate = store.state.exercises[action.item.exerciseId];
        if (exerciseToUpdate != null) {
          var updatedLogs = exerciseToUpdate.exerciseLogs ?? <ExerciseLog>[];
          updatedLogs..add(itemSaved);
          updatedLogs.sort((ExerciseLog log1, ExerciseLog log2) {
            return log1.created_at.compareTo(log2.created_at);
          });
          exerciseToUpdate.exerciseLogs = updatedLogs;
          store.dispatch(
            new SingleItemLoaded(
                type: EModelTypes.exercise, item: exerciseToUpdate),
          );
        }
        break;
      case EModelTypes.feed:
        itemSaved = await repository.saveFeed(action.item);
        break;
      case EModelTypes.post:
        itemSaved = await repository.savePost(action.item);
        break;
      case EModelTypes.completableWorkout:
        itemSaved = await repository.saveComplete(action.item);
//        dispatchAction = SetActiveWorkoutCompletableAction(completableWorkout: itemSaved);
//        dispatchAction = new OnSavedAction<Complete>(item: itemSaved, type: EModelTypes.completableWorkout);
        break;
      case EModelTypes.routineSubscription:
        itemSaved = await repository.saveRoutineSubscription(action.item);
        break;
      case EModelTypes.rating:
        itemSaved = await repository.saveRating(action.item);
        break;
      case EModelTypes.comment:
        itemSaved = await repository.saveComment(action.item);
        break;
    }

    if (dispatchAction != null) store.dispatch(dispatchAction);

    // Callback, even if itemSaved is null > deferred handling
    action?.onSavedCallback(itemSaved);

    next(action);
  };
}

Middleware<MoxieAppState> _createLoadLookupOptions(MoxieRepository repository) {
  return (Store<MoxieAppState> store, action, NextDispatcher next) {
    repository
        .loadLookupOptions(globalLookupsMap[action.eLookup])
        .then((loOptions) {
      var dispatchAction;
      switch (action.eLookup) {
        case ELookups.goals:
          dispatchAction = new GoalsLookupOptionsLoadedAction(
            lookupOptions: loOptions,
          );
          break;
        case ELookups.muscles:
          dispatchAction =
              new MuscleLookupOptionsLoadedAction(lookupOptions: loOptions);
          break;
        case ELookups.equipment:
          dispatchAction =
              new EquipmentLookupOptionsLoadedAction(lookupOptions: loOptions);
          break;
      }
      store.dispatch(dispatchAction);
    });
    next(action);
  };
}

Middleware<MoxieAppState> _createLoadSingleItem(MoxieRepository repository) {
  return (Store<MoxieAppState> store, action, NextDispatcher next) {
    switch (action.type) {
      case EModelTypes.exercise:
        repository.loadExercise(action.itemId).then((ex) {
          store.dispatch(
              new SingleItemLoaded(type: EModelTypes.exercise, item: ex));
        });
        break;
      case EModelTypes.workout:
        repository.loadWorkout(action.itemId).then((workout) {
          store.dispatch(
              new SingleItemLoaded(type: EModelTypes.workout, item: workout));
        });
        break;
      case EModelTypes.routine:
        repository.loadRoutine(action.itemId).then((routine) {
          if (routine != null)
            store.dispatch(
                new SingleItemLoaded(type: EModelTypes.routine, item: routine));
        });
        break;
    }
    next(action);
  };
}

Middleware<MoxieAppState> _createLoadExerciseLogs(MoxieRepository repository) {
  return (Store<MoxieAppState> store, action, NextDispatcher next) {
    repository
        .loadExerciseLogs(filter: action.filter, exercise_id: action.exerciseId)
        .then((exercise_logs) {
      action?.completer?.complete();
      // Get the exercise from redux to update with the logs
      var exerciseToUpdate = store.state.exercises[action.exerciseId];
      if (exerciseToUpdate != null) {
        exerciseToUpdate.exerciseLogs = exercise_logs;
        store.dispatch(
          new SingleItemLoaded(
              type: EModelTypes.exercise, item: exerciseToUpdate),
        );
      }
    });
    next(action);
  };
}

Middleware<MoxieAppState> _createLoadCompletesForCalendar(
    MoxieRepository repository) {
  return (Store<MoxieAppState> store, action, NextDispatcher next) {
    repository
        .loadCompletesWithRoutineWorkoutUsers(action.from, action.to)
        .then((calendarCompletes) {
      store.dispatch(new OnLoadedCompletesForCalendar(
        fresh: action.fresh,
        calendarCompletes: new LinkedHashMap<num, Complete>()
          ..addEntries(calendarCompletes.map((c) {
            return MapEntry(c.id, c);
          })),
      ));
    });
    next(action);
  };
}
