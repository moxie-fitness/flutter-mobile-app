class MoxieViewLoadersState {
  bool exercisesListLoading;
  bool workoutsListLoading;
  bool routinesListLoading;
  bool feedsListLoading;
  bool searchRoutinesListLoading;

  MoxieViewLoadersState({
    this.exercisesListLoading = false,
    this.workoutsListLoading = false,
    this.routinesListLoading = false,
    this.feedsListLoading = false,
    this.searchRoutinesListLoading = false
  });

  @override
  int get hashCode =>
      exercisesListLoading.hashCode ^
      workoutsListLoading.hashCode ^
      routinesListLoading.hashCode ^
      feedsListLoading.hashCode ^
      searchRoutinesListLoading.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is MoxieViewLoadersState &&
              runtimeType == other.runtimeType &&
              exercisesListLoading == other.exercisesListLoading &&
              workoutsListLoading == other.workoutsListLoading &&
              routinesListLoading == other.routinesListLoading &&
              feedsListLoading == other.feedsListLoading &&
              searchRoutinesListLoading == other.searchRoutinesListLoading;
}