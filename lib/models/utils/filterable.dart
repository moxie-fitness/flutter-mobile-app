
import 'dart:async';

import 'package:flutter/widgets.dart';

abstract class FilterAndSortList<T> {
  Widget generateListItem(T item);
  Widget bottomSheetFilter();
  getFilterController();
}

class FilterAndSortable {
  int take = 15;
  int offset = 0;
  var sortBy;
  Map filterMap = new Map();

  FilterAndSortable(take, offset, sortBy);

  Map getFilterMap(){
    filterMap['take'] = '$take';
    filterMap['offset'] = '$offset';
    filterMap['sortBy'] = '${sortBy != null ? sortBy.toString() : ''}';
    return filterMap;
  }
}

enum Order {
  asc,
  desc
}

enum ExercisesSort {
  name,
  nameReverse,
}

enum WorkoutsSort {
  name,
  exercise_count
}

enum RoutinesSort {
  name,
  workout_count,
  price,
  rating
}