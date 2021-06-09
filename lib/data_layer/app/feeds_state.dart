import 'dart:collection';

import 'package:moxie_fitness/models/models.dart';

class FeedsState {
  final bool allFeedsLoaded;
  final LinkedHashMap<num, Feed> feeds;

  FeedsState({
    this.allFeedsLoaded,
    this.feeds
  });

  @override
  int get hashCode =>
    allFeedsLoaded.hashCode ^
    feeds.hashCode;

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
      other is FeedsState &&
        runtimeType == other.runtimeType &&
        allFeedsLoaded == other.allFeedsLoaded &&
        feeds == other.feeds;
}