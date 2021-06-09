import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:moxie_fitness/data_layer/actions/actions.dart';
import 'package:moxie_fitness/data_layer/actions/all_actions.dart';
import 'package:moxie_fitness/data_layer/app/moxie_app_state.dart';
import 'package:moxie_fitness/models/models.dart';
import 'package:moxie_fitness/pages/pages.dart';

class Routes {
  // Defaults
  static Router router;
  static final String root = '/';
  static final String login = '/login';
  static final String home = '/home';

  static final rootHandler = new Handler(
      handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    return new SplashPage();
  });

  static final loginHandler = new Handler(
      handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    return new LoginPage();
  });

  static final homeHandler = new Handler(
      handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    return new StoreBuilder<MoxieAppState>(onInit: (store) {
      /// Load non-essential data here, while in loading screen.
      /// Note: StoreBuilder doesn't block UI, this allows
      /// for loading this data in the background while letting the
      /// user continue using the app.
      store.dispatch(new LoadMoxieuserAction());

      // Query all the LookupOptions in the globalLookupsMap
      globalLookupsMap.keys.forEach((ELookups lo) {
        store.dispatch(new LoadLookupOptions(eLookup: lo));
      });

      store.dispatch(new LoadFeedsAction(
          freshValues: true, filter: new FeedsListFilter(take: 15, offset: 0)));

      if (store.state.exercises?.length == 0) {
        store.dispatch(new LoadExercisesAction(
          filter: new ExerciseListFilter(<int>[])
            ..take = 15
            ..offset = 0,
        ));
      }

      store.dispatch(new LoadWorkoutsAction(
        filter: new WorkoutListFilter(take: 15, offset: 0),
      ));
      store.dispatch(new LoadRoutinesAction(
        filter: new RoutineListFilter(take: 15, offset: 0),
      ));

      final from = DateTime.now().subtract(Duration(days: 35));
      final to = DateTime.now().add(Duration(days: 35));
      store.dispatch(LoadCompletesForCalendar(from: from, to: to));
    }, builder: (context, store) {
      return new HomePage();
    });
  });

  /// Users
  static final String userEdit = '/user';
  static final String users = '/users/:id';

  static final userEditHandler = new Handler(
      handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    return new UserProfileEditPage();
  });

  static final usersHandler = new Handler(
      handlerFunc: (BuildContext context, Map<String, List<String>> params) {
   return new UserProfileEditPage();
  });

  /// Search
  static final String searchPostsAndPeople = '/search/posts-and-people';
  static final String searchRoutines = '/search/routines';

  static final searchPostsAndPeopleHandler = new Handler(
      handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    return new SearchPostsAndPeoplePage();
  });

  static final searchRoutinesHandler = new Handler(
      handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    return new StoreBuilder<MoxieAppState>(onInit: (store) {
      if (store.state.searchRoutines == null ||
          store.state.searchRoutines.isEmpty) {
        store.dispatch(new LoadSearchRoutinesAction(
            filter: new RoutineListFilter()
              ..take = 15
              ..offset = 0,
            freshValues: true));
      }
    }, builder: (context, store) {
      return new SearchRoutinesPage();
    });
  });

  /// Exercises
  static final String exercisesCreate = '/exercises/create';
  static final String exercises = '/exercises/:id';
  static final String exercisesList = '/exercises-list';
  static final String exercisesHistory = '/exercises-history/:id';

  static final exercisesCreateHandler = new Handler(
      handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    return new StoreBuilder<MoxieAppState>(onInit: (store) {
      if (store.state.equipmentLookupOptions == null) {
        store.dispatch(new LoadLookupOptions(eLookup: ELookups.equipment));
      }
      if (store.state.muscleLookupOptions == null) {
        store.dispatch(new LoadLookupOptions(eLookup: ELookups.muscles));
      }
    }, builder: (context, store) {
      return new CreateExercisePage();
    });
  });

  static final exercisesHandler = new Handler(
      handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    final exerciseId = int.parse(params["id"][0]);
    return new StoreBuilder<MoxieAppState>(onInit: (store) {
      store.dispatch(new LoadExerciseLogsAction(
          filter: new FilterAndSortable(15, 0, null), exerciseId: exerciseId));
    }, builder: (context, store) {
      return new ExercisePage(id: exerciseId);
    });
  });

  static final exercisesListHandler = new Handler(
      handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    return new StoreBuilder<MoxieAppState>(onInit: (store) {
      if (store.state.exercises == null || store.state.exercises.isEmpty) {
        store.dispatch(new LoadExercisesAction(
          filter: new ExerciseListFilter(<int>[])
            ..take = 15
            ..offset = 0,
        ));
      }
    }, builder: (context, store) {
      return new ExercisesListPage();
    });
  });

  static final exercisesHistoryHandler = new Handler(
      handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    final exerciseId = int.parse(params["id"][0]);
    return StoreBuilder<MoxieAppState>(onInit: (store) {
      store.dispatch(LoadExerciseLogsAction(
          filter: FilterAndSortable(100, 0, null // TODO: Sort by newest
              ),
          exerciseId: exerciseId));
    }, builder: (context, store) {
      return ExerciseHistoryPage(exerciseId: exerciseId);
    });
  });

  /// Workouts
  static final String workoutsCreate = '/workouts/create';
  static final String workouts = '/workouts/:id';
  static final String workoutsWithCW = '/workouts/:id/:cwId';
  static final String workoutsList = '/workouts-list';

  static final workoutsCreateHandler = new Handler(
      handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    return new CreateWorkoutPage();
  });
  static final workoutsHandler = new Handler(
      handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    final workoutId = int.parse(params["id"][0]);
    final completableWorkoutId =
        params["cwId"] != null ? int.parse(params["cwId"][0]) : null;

    return StoreBuilder<MoxieAppState>(onInit: (store) {
      if (completableWorkoutId != null) {
        store.dispatch(LoadSingleItem(
            itemId: completableWorkoutId,
            type: EModelTypes.completableWorkout));
      }
    }, builder: (context, store) {
      return WorkoutPage(
          id: workoutId, completableWorkoutId: completableWorkoutId);
    });
  });

  static final workoutsListHandler = new Handler(
      handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    return new StoreBuilder<MoxieAppState>(onInit: (store) {
      if (store.state.workouts == null || store.state.workouts.isEmpty) {
        if (store.state.workouts == null ||
            store.state.workouts.isEmpty && !store.state.isLoading) {
          store.dispatch(new LoadWorkoutsAction(
              filter: new WorkoutListFilter(take: 15, offset: 0)));
        }
      }
    }, builder: (context, store) {
      return new WorkoutsListPage();
    });
  });

  /// Routines
  static final String routinesCreate = '/routines/create';
  static final String routines = '/routines/:id';
  static final String subscribeRoutines = '/subscribe-routines/:id/:allowSub';
  static final String routinesList = '/routines-list';

  static final routinesCreateHandler = new Handler(
      handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    return new StoreBuilder<MoxieAppState>(onInit: (store) {
      if (store.state.goalsLookupOptions == null ||
          store.state.goalsLookupOptions.isEmpty) {
        store.dispatch(new LoadLookupOptions(eLookup: ELookups.goals));
      }
      if (store.state.routines == null || store.state.routines.isEmpty) {
        store.dispatch(new LoadRoutinesAction(
            filter: new RoutineListFilter(
                take: 15, offset: store.state.workouts?.length)));
      }
    }, builder: (context, store) {
      return new CreateRoutinePage();
    });
  });

  static final routinesHandler = new Handler(
      handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    final routineId = int.parse(params["id"][0]);
    return new RoutinePage(id: routineId);
  });

  static final subscribeRoutinesHandler = new Handler(
      handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    final routineId = int.parse(params["id"][0]);
    final allowSubscription = int.parse(params["allowSub"][0]) == 1;
    return new RoutinePage(id: routineId, allowSubscription: allowSubscription);
  });

  static final routinesListHandler = new Handler(
      handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    return new RoutinesListPage();
  });

  /// Posts
  static final String feedPostCreate = '/feed-posts/create';
  static final String postCreate = '/posts/create';
  static final String posts = '/posts/:id';
  static final String postsEdit = '/posts/edit/:id';

  static final feedPostsCreateHandler = new Handler(
      handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    return new CreatePostPage();
  });

  static final postsCreateHandler = new Handler(
      handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    return new CreatePostPage();
  });

  static final postsHandler = new Handler(
      handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    return new StoreBuilder<MoxieAppState>(onInit: (store) {
      // Query post with comments
    }, builder: (context, store) {
      return new PostPage(int.tryParse(params["id"][0]));
    });
  });

  static final postsEditHandler = new Handler(
      handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    return new PostPage(int.tryParse(params["id"][0]), edit: true);
  });

  static void configureDefaultRoutes(Router router) {
    router.notFoundHandler = new Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      print("ROUTE WAS NOT FOUND !!!");
    });

    // Defaults
    router.define(root, handler: rootHandler);
    router.define(login, handler: loginHandler);
    router.define(home, handler: homeHandler);

    // Search
    router.define(searchPostsAndPeople, handler: searchPostsAndPeopleHandler);
    router.define(searchRoutines, handler: searchRoutinesHandler);

    // Users
    router.define(userEdit, handler: userEditHandler);
    router.define(users, handler: usersHandler);

    // Exercises
    router.define(exercisesCreate, handler: exercisesCreateHandler);
    router.define(exercises, handler: exercisesHandler);
    router.define(exercisesList, handler: exercisesListHandler);
    router.define(exercisesHistory, handler: exercisesHistoryHandler);

    // Workouts
    router.define(workoutsCreate, handler: workoutsCreateHandler);
    router.define(workouts, handler: workoutsHandler);
    router.define(workoutsWithCW, handler: workoutsHandler);
    router.define(workoutsList, handler: workoutsListHandler);

    // Routines
    router.define(routinesCreate, handler: routinesCreateHandler);
    router.define(routines, handler: routinesHandler);
    router.define(subscribeRoutines, handler: subscribeRoutinesHandler);
    router.define(routinesList, handler: routinesListHandler);

    // Posts
    router.define(feedPostCreate, handler: feedPostsCreateHandler);
    router.define(postCreate, handler: postsCreateHandler);
    router.define(posts, handler: postsHandler);
    router.define(postsEdit, handler: postsEditHandler);
  }
}
