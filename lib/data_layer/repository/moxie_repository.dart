import 'dart:async';
import 'dart:convert';

import 'package:jaguar_serializer/jaguar_serializer.dart';
import 'package:meta/meta.dart';
import 'package:moxie_fitness/models/models.dart';
import 'package:http/http.dart' as http;
import 'package:moxie_fitness/models/utils/filterable.dart';

final moxieRepository =
    MoxieRepository(reposistoryBaseUrl: BaseModel.getApiBaseUrl);

class MoxieRepository
    implements
        MoxieuserRepo,
        ExerciseRepo,
        LookupRepo,
        LookupOptionRepo,
        WorkoutRepo,
        RoutineRepo,
        ExerciseLogRepo,
        FeedRepo,
        PostRepo,
        CompleteRepo,
        RoutineSubscriptionRepo,
        RatingRepo,
        CommentRepo {
  final String reposistoryBaseUrl;
  static final jsonRepo = JsonRepo()
    ..add(MoxieuserJsonSerializer())
    ..add(PostJsonSerializer())
    ..add(ExerciseJsonSerializer())
    ..add(ExerciseEquipmentJsonSerializer())
    ..add(LookupOptionJsonSerializer())
    ..add(WorkoutJsonSerializer())
    ..add(RoutineJsonSerializer())
    ..add(ExerciseWorkoutJsonSerializer())
    ..add(ExerciseLogJsonSerializer())
    ..add(PostJsonSerializer())
    ..add(FeedJsonSerializer())
    ..add(CompleteJsonSerializer())
    ..add(RatingJsonSerializer())
    ..add(RoutineSubscriptionJsonSerializer())
    ..add(CommentJsonSerializer());

  const MoxieRepository({@required this.reposistoryBaseUrl});

  @override
  Future<Lookup> loadLookup(String value) {
    return Future(null);
  }

  @override
  Future<List<LookupOption>> loadLookupOptions(String lookupValue) async {
    var response = await http.get(
        '${BaseModel.getApiBaseUrl}lookup_options/lookup/$lookupValue',
        headers: await BaseModel.getAuthHeader());
    List<LookupOption> list = jsonRepo.decodeList<LookupOption>(response.body);
    return list.cast<LookupOption>();
  }

  @override
  Future<Moxieuser> loadMoxieuser() async {
    var url = '${reposistoryBaseUrl}moxieuser';
    var response =
        await http.get('$url', headers: await BaseModel.getAuthHeader());
    Moxieuser user = jsonRepo.decode<Moxieuser>(response.body);
    return user;
  }

  @override
  Future<bool> saveMoxieuserDetails(Moxieuser moxieusuer) async {
    final headers = await BaseModel.getAuthHeader();
    final serializer = MoxieuserJsonSerializer();
    var body = json.encode(serializer.toMap(moxieusuer));
    var url = '${reposistoryBaseUrl}moxieusers/save-details';
    var response = await http.post('$url', headers: headers, body: body);
    var decodedMap = json.decode(response.body);
    return decodedMap['success'];
  }

  @override
  Future<Exercise> saveExercise(Exercise exercise) async {
    final exerciseSerializer = ExerciseJsonSerializer();
    var exerciseMap = await exercise.store(repo: jsonRepo);
    return exerciseSerializer.fromMap(exerciseMap);
  }

  @override
  Future<List<Exercise>> loadExercises({FilterAndSortable filter}) async {
    var url = '${reposistoryBaseUrl}exercises/list';
    Map body = Map();
    if (filter != null) body.addAll(filter.getFilterMap());
    var response = await http.post('$url',
        headers: await BaseModel.getAuthHeader(ContentType.urlencoded),
        body: body);
    List<dynamic> list = jsonRepo.decodeList<Exercise>(response.body);
    return list.cast<Exercise>();
  }

  @override
  Future<Exercise> loadExercise(int id) async {
    final exerciseSerializer = ExerciseJsonSerializer();
    var exerciseMap = await BaseModel.show(Exercise()..id = id);
    return exerciseSerializer.fromMap(exerciseMap);
  }

  @override
  Future<List<Workout>> loadWorkouts({FilterAndSortable filter}) async {
    var url = '${reposistoryBaseUrl}workouts/list';
    Map body = Map();
    if (filter != null) body.addAll(filter.getFilterMap());
    var response = await http.post('$url',
        headers: await BaseModel.getAuthHeader(ContentType.urlencoded),
        body: body);
    return jsonRepo.decodeList<Workout>(response.body);
  }

  @override
  Future<Workout> saveWorkout(Workout workout) async {
    final workoutSerializer = WorkoutJsonSerializer();
    var workoutMap = await workout.store(repo: jsonRepo);
    return workoutSerializer.fromMap(workoutMap);
  }

  @override
  Future<Workout> loadWorkout(int id) async {
    final workoutSerializer = WorkoutJsonSerializer();
    var workoutMap = await BaseModel.show(Workout()..id = id);
    return workoutSerializer.fromMap(workoutMap);
  }

  @override
  Future<List<Routine>> loadRoutines({FilterAndSortable filter}) async {
    var url = '${reposistoryBaseUrl}routines/list';
    Map body = Map();
    if (filter != null) body.addAll(filter.getFilterMap());
    var response = await http.post('$url',
        headers: await BaseModel.getAuthHeader(ContentType.urlencoded),
        body: body);
    List<dynamic> list = jsonRepo.decodeList<Routine>(response.body);
    return list.cast<Routine>();
  }

  @override
  Future<Routine> saveRoutine(Routine routine) async {
    final routineSerializer = RoutineJsonSerializer();
    var routineMap = await routine.store(repo: jsonRepo);
    return routineSerializer.fromMap(routineMap);
  }

  @override
  Future<List<ExerciseLog>> loadExerciseLogs(
      {FilterAndSortable filter, int exercise_id}) async {
    var url = '${reposistoryBaseUrl}exercise_logs/for-exercise/${exercise_id}';
    Map body = Map();
    if (filter != null) body.addAll(filter.getFilterMap());
    var response = await http.post('$url',
        headers: await BaseModel.getAuthHeader(ContentType.urlencoded),
        body: body);
    List<dynamic> list = jsonRepo.decodeList<ExerciseLog>(response.body);
    return list.cast<ExerciseLog>();
  }

  @override
  Future<ExerciseLog> saveExerciseLog(ExerciseLog exerciseLog) async {
    final exerciseLogSerializer = ExerciseLogJsonSerializer();
    var exerciseLogMap = await exerciseLog.store(repo: jsonRepo);
    return exerciseLogSerializer.fromMap(exerciseLogMap);
  }

  @override
  Future<Routine> loadRoutine(int id) async {
    final routineSerializer = RoutineJsonSerializer();
    var routineMap = await BaseModel.show(Routine()..id = id);
    return routineSerializer.fromMap(routineMap);
  }

  @override
  Future<Post> savePost(Post post) async {
    final postSerializer = PostJsonSerializer();
    var postMap = await post.store(repo: jsonRepo);
    return postSerializer.fromMap(postMap);
  }

  @override
  Future<Rating> saveRating(Rating rating) async {
    final ratingSerializer = RatingJsonSerializer();
    var ratingMap;
    ratingMap = rating.id == null
        ? await rating.store(repo: jsonRepo)
        : await rating.update(rating.id, ratingSerializer);
    return ratingSerializer.fromMap(ratingMap);
  }

  @override
  Future<Feed> saveFeed(Feed feed) async {
    final feedSerializer = FeedJsonSerializer();
    var feedMap = await feed.store(repo: jsonRepo);
    return feedSerializer.fromMap(feedMap);
  }

  @override
  Future<List<Feed>> loadFeeds({FilterAndSortable filter}) async {
    var url = '${reposistoryBaseUrl}feeds/list';
    Map body = Map();
    if (filter != null) body.addAll(filter.getFilterMap());
    var response = await http.post('$url',
        headers: await BaseModel.getAuthHeader(ContentType.urlencoded),
        body: body);
    return jsonRepo.decodeList<Feed>(response.body);
  }

  @override
  Future<Complete> saveComplete(Complete complete) async {
    final completeSerializer = CompleteJsonSerializer();
    var completeMap = await complete.store(repo: jsonRepo);
    return completeSerializer.fromMap(completeMap);
  }

  @override
  Future<Complete> loadComplete(int id) async {
    final completeSerializer = CompleteJsonSerializer();
    var completeMap = await BaseModel.show(Complete()..id = id);
    return completeSerializer.fromMap(completeMap);
  }

  @override
  Future<RoutineSubscription> saveRoutineSubscription(
      RoutineSubscription rs) async {
    final rsSerializer = RoutineSubscriptionJsonSerializer();
    var rsMap = await rs.store(repo: jsonRepo);
    return rsSerializer.fromMap(rsMap);
  }

  @override
  Future<bool> checkIfSubscribed(routineId) async {
    final headers = await BaseModel.getAuthHeader();
    final url =
        '${BaseModel.getApiBaseUrl}routine_subscriptions/check-subscription/$routineId';
    var response = await http.post(url, headers: headers);
    var result = json.decode(response.body);
    return result['subbed'];
  }

  @override
  Future<ResponseWrapper<Complete>> startActiveRoutine(int id,
      {bool endPrevious = false}) async {
    try {
      final completableSerializer = CompleteJsonSerializer();
      final headers = await BaseModel.getAuthHeader();
      final url = '${BaseModel.getApiBaseUrl}routines/start/$id';
      Map body = Map()..putIfAbsent('endPrevious', () => endPrevious);
      var response =
          await http.post(url, headers: headers, body: json.encode(body));
      var result = json.decode(response.body);

      if (result['error'] != null) {
        return ResponseWrapper<Complete>(
            hasError: true, errorMessage: result['message']);
      }

      Complete routineCompletable = completableSerializer.fromMap(result);
      return ResponseWrapper<Complete>(data: routineCompletable);
    } catch (exception) {
      return ResponseWrapper<Complete>(
          hasException: true, exceptionMessage: exception.toString());
    }
  }

  @override
  Future<List<Complete>> loadCompletesWithRoutineWorkoutUsers(
      DateTime from, DateTime to) async {
    var url = '${reposistoryBaseUrl}completes/list-rwus-date';

    Map body = Map()
      ..putIfAbsent('from', () => from.toString())
      ..putIfAbsent('to', () => to.toString());
    var response = await http.post('$url',
        headers: await BaseModel.getAuthHeader(), body: json.encode(body));
    List<dynamic> list = jsonRepo.decodeList<Complete>(response.body);
    return list.cast<Complete>();
  }

  @override
  Future<ResponseWrapper<List<Complete>>>
      loadAllUncompletedCompletesWithRoutineWorkoutUsers() async {
    try {
      var url = '${reposistoryBaseUrl}completes/list-rwus';

      var response =
          await http.post('$url', headers: await BaseModel.getAuthHeader());
      List<dynamic> list = jsonRepo.decodeList<Complete>(response.body);

      return ResponseWrapper<List<Complete>>(data: list.cast<Complete>());
    } catch (exception) {
      return ResponseWrapper<List<Complete>>(
          hasException: true, exceptionMessage: exception.toString());
    }
  }

  @override
  Future<Comment> saveComment(Comment comment) async {
    final commentSerializer = CommentJsonSerializer();
    var commentMap = comment.id == null
        ? await comment.store(repo: jsonRepo)
        : await comment.update(comment.id, commentSerializer);
    return commentSerializer.fromMap(commentMap);
  }

  @override
  Future<List<Comment>> loadCommentsForPost(
      {int postId, FilterAndSortable filter}) async {
    var url = '${reposistoryBaseUrl}comments/$postId/list';
    Map body = Map();
    if (filter != null) body.addAll(filter.getFilterMap());
    var response = await http.post('$url',
        headers: await BaseModel.getAuthHeader(ContentType.urlencoded),
        body: body);
    return jsonRepo.decodeList<Comment>(response.body);
  }
}

class ResponseWrapper<T> {
  final T data;
  final bool hasError;
  final bool hasException;
  final String errorMessage;
  final String exceptionMessage;

  ResponseWrapper(
      {this.data,
      this.hasError = false,
      this.hasException = false,
      this.errorMessage,
      this.exceptionMessage});
}
