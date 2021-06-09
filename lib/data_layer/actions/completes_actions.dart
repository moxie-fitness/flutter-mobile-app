import 'dart:collection';

import 'package:moxie_fitness/models/models.dart';

class LoadCompletesForCalendar {
  final DateTime from;
  final DateTime to;
  final fresh;
  LoadCompletesForCalendar({this.from, this.to, this.fresh = false});
}

class OnLoadedCompletesForCalendar {
  final LinkedHashMap<num, Complete> calendarCompletes;
  final fresh;

  OnLoadedCompletesForCalendar({this.calendarCompletes, this.fresh});
}
