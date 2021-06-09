
import 'dart:async';
import 'dart:collection';

import 'package:meta/meta.dart';
import 'package:moxie_fitness/data_layer/actions/actions.dart';
import 'package:moxie_fitness/models/models.dart';

class LoadFeedsAction {
  Completer completer;
  final FilterAndSortable filter;
  final bool freshValues;
  LoadFeedsAction({
    this.filter,
    this.completer,
    this.freshValues = false
  });
}
class FeedsLoadedAction extends BaseLoadAction {
  final LinkedHashMap<num, Feed> feeds;
  final bool freshValues;
  final FilterAndSortable filter;
  FeedsLoadedAction({
    this.filter,
    this.freshValues = false,
    this.feeds});
}

class LoadPostCommentsAction {
  final postId;
  Completer completer;
  final FilterAndSortable filter;
  final bool freshValues;
  LoadPostCommentsAction({
    @required this.postId,
    this.filter,
    this.completer,
    this.freshValues = false
  });
}
class PostCommentsLoadedAction extends BaseLoadAction {
  final postId;
  final LinkedHashMap<num, Comment> comments;
  final bool freshValues;
  final FilterAndSortable filter;
  PostCommentsLoadedAction({
    @required this.postId,
    this.filter,
    this.freshValues = false,
    this.comments});
}