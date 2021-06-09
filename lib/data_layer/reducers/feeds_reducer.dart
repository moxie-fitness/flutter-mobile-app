import 'dart:collection';

import 'package:moxie_fitness/data_layer/actions/all_actions.dart';
import 'package:moxie_fitness/models/models.dart';
import 'package:redux/redux.dart';

final feedsReducer = combineReducers<LinkedHashMap<num, Feed>>([
  new TypedReducer<LinkedHashMap<num, Feed>, FeedsLoadedAction>(_setLoadedFeeds),
  new TypedReducer<LinkedHashMap<num, Feed>, PostCommentsLoadedAction>(_setLoadedComments),

  new TypedReducer<LinkedHashMap<num, Feed>, SingleItemLoaded>(_setLoadedFeed),
  new TypedReducer<LinkedHashMap<num, Feed>, SaveAction<Comment>>(_setSavedComment),

]);

LinkedHashMap<num, Feed> _setLoadedFeeds(LinkedHashMap<num, Feed> feeds, FeedsLoadedAction action) {
  if(feeds != null && !action.freshValues) {
    return new LinkedHashMap<num, Feed>.from(feeds)
      ..addAll(action.feeds);
  }
  return action.feeds;
}

LinkedHashMap<num, Feed> _setLoadedComments(LinkedHashMap<num, Feed> feeds, PostCommentsLoadedAction action) {
  if(feeds == null) return feeds;

  var feed = feeds.values.firstWhere((Feed f) => f.post_id == action.postId);
  if(feed == null) return feeds;

  if(feed.post.comments == null) {
    feed.post.comments = action.comments.values;
  } else {
    feed.post.comments.addAll(action.comments.values);
  }

  return feeds..update(feed.id, (v) => feed, ifAbsent: () => feed);
}

LinkedHashMap<num, Feed> _setLoadedFeed(LinkedHashMap<num, Feed> feeds, SingleItemLoaded action) {
  if(action.type == EModelTypes.feed) {
    if(feeds == null) {
      return new LinkedHashMap<num, Feed>()..putIfAbsent(action.item.moxieuserId,() => action.item);
    }
    // Remove, if already existed, to update with new entry;
    feeds.remove(action.item.moxieuserId);
    return feeds..putIfAbsent(action.item.moxieuserId,() => action.item);
  }
  return feeds;
}

LinkedHashMap<num, Feed> _setSavedComment(LinkedHashMap<num, Feed> feeds, SaveAction<Comment> action) {
  if(action.item != null) {
    Feed feedToUpdate = feeds.values.where((Feed f) => f.post_id == action.item.postId).first;
    if(feedToUpdate != null) {
      feedToUpdate.post.comments.insert(0, action.item);
      feeds..update(feedToUpdate.id, (v) => feedToUpdate, ifAbsent: () => feedToUpdate);
      return feeds;
    }
  }
  return feeds;
}
