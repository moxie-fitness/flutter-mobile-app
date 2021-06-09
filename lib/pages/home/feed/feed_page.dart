import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:moxie_fitness/config/routes.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moxie_fitness/components/avatar.dart';
import 'package:moxie_fitness/components/components.dart';
import 'package:moxie_fitness/data_layer/actions/all_actions.dart';
import 'package:moxie_fitness/data_layer/app/moxie_app_state.dart';
import 'package:moxie_fitness/models/models.dart';
import 'package:moxie_fitness/pages/core/moxie_list_page.dart';
import 'package:redux/redux.dart';

class FeedPage extends StatefulWidget {
  @override
  FeedPageState createState() => FeedPageState();
}

class FeedPageState extends State<FeedPage> {
  FeedsListFilter _filter = FeedsListFilter();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appBar = SliverAppBar(
      floating: true,
      pinned: false,
      snap: true,
      leading: Avatar(
        forCurrentUser: true,
      ),
      centerTitle: true,
      title: CustomText.qarmicSans(text: 'Moxie Fitness'),
    );

    return MoxieListPage<Feed, FilterAndSortable>(
      appBar: appBar,
      fab: FloatingActionButton(
          child: Icon(Icons.fitness_center),
          onPressed: () {
            Routes.router.navigateTo(context, Routes.feedPostCreate);
          }),
      onScrolledToBottom: () {
        final storeProvider = StoreProvider.of<MoxieAppState>(context);
        if (!storeProvider.state.viewLoadersState.feedsListLoading) {
          storeProvider.dispatch(LoadFeedsAction(
            filter: _filter
              ..take = 15
              ..offset = storeProvider.state.exercises.length,
          ));
        }
      },
      onRefreshAction: LoadFeedsAction(
          filter: _filter
            ..take = 15
            ..offset = 0,
          freshValues: true),
      viewModelConverter: (store) => _ViewModel.from(store),
      listItemGenerate: (feed) {
        return generateListItem(feed);
      },
    );
  }

  Widget generateListItem(Feed feed) {
    feed.post.moxieuser = feed.moxieuser;
    return PostListItem(
      post: feed.post,
    );
  }
}

class _ViewModel implements ViewModel<Feed> {
  final List<Feed> feeds;
  final bool loading;
  final bool allLoaded;

  _ViewModel({this.feeds, this.loading = false, this.allLoaded = false});

  static _ViewModel from(Store<MoxieAppState> store) {
    return _ViewModel(
        feeds: store.state?.feedsState?.feeds?.values?.toList() ?? <Feed>[],
        loading: store.state.viewLoadersState.feedsListLoading,
        allLoaded: store.state?.feedsState?.allFeedsLoaded);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ViewModel &&
          runtimeType == other.runtimeType &&
          feeds == other.feeds;

  @override
  int get hashCode => feeds.hashCode;

  @override
  List<Feed> get items => feeds;
}

class FeedsListFilter extends FilterAndSortable {
  FeedsListFilter({sortBy = ExercisesSort.name, take, offset})
      : super(take, offset, sortBy);

  @override
  Map getFilterMap() {
    return super.getFilterMap();
  }
}
