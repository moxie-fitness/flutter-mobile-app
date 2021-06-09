import 'package:jaguar_serializer/jaguar_serializer.dart';
import 'package:moxie_fitness/models/models.dart';

class MoxieJsonUtils {

  static ExerciseJsonSerializer exerciseJsonSerializer = new ExerciseJsonSerializer();
  static MoxieuserJsonSerializer moxieuserJsonSerializer = new MoxieuserJsonSerializer();
  static PostJsonSerializer postJsonSerializer = new PostJsonSerializer();
  static ExerciseEquipmentJsonSerializer exerciseEquipmentJsonSerializer = new ExerciseEquipmentJsonSerializer();
  static LookupOptionJsonSerializer lookupOptionJsonSerializer = new LookupOptionJsonSerializer();
  static LookupJsonSerializer lookupJsonSerializer = new LookupJsonSerializer();
  static RoutineJsonSerializer routineJsonSerializer = new RoutineJsonSerializer();
  static RoutineSubscriptionJsonSerializer routineSubscriptionJsonSerializer = new RoutineSubscriptionJsonSerializer();
  static WorkoutRoutineJsonSerializer workoutRoutineJsonSerializer = new WorkoutRoutineJsonSerializer();
  static WorkoutJsonSerializer workoutJsonSerializer = new WorkoutJsonSerializer();
  static CommentJsonSerializer commentJsonSerializer = new CommentJsonSerializer();
  static CompleteJsonSerializer completableJsonSerializer = new CompleteJsonSerializer();
  static RatingJsonSerializer ratableJsonSerializer = new RatingJsonSerializer();
  static HeightJsonSerializer heightJsonSerializer = new HeightJsonSerializer();
  static WeightJsonSerializer weightJsonSerializer = new WeightJsonSerializer();
  static ExerciseWorkoutJsonSerializer exerciseWorkoutJsonSerializer = new ExerciseWorkoutJsonSerializer();

}