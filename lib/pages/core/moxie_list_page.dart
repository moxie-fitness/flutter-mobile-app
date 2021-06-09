import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:moxie_fitness/components/components.dart';
import 'package:moxie_fitness/components/moxie_no_results.dart';
import 'package:moxie_fitness/data_layer/app/moxie_app_state.dart';

typedef Widget GenerateListItem<E>(E item);

class MoxieListPage<E, F> extends StatefulWidget {
  final String appBarTitle;
  final SliverAppBar appBar;
  final FloatingActionButton fab;
  final GenerateListItem listItemGenerate;
  final onRefreshAction;
  final onScrolledToBottom;
  final StatefulBuilder bottomSheetFilter;
  final viewModelConverter;

  final StreamController<F> filterUpdateController;

  MoxieListPage(
      {this.appBarTitle,
      this.appBar,
      this.fab,
      this.listItemGenerate,
      this.onRefreshAction,
      this.onScrolledToBottom,
      this.bottomSheetFilter,
      this.viewModelConverter,
      this.filterUpdateController})
      : assert(appBarTitle != null || appBar != null,
            "Must include [appBarTitle] or [appBar], both can't be null!");

  @override
  MoxieListPageState createState() => MoxieListPageState<E, F>();
}

class MoxieListPageState<E, F> extends State<MoxieListPage> {
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  Completer _refreshCompleter;
  ScrollController _scrollController;
  num _scrollPos = 0;
  bool _showFab = true;
  PersistentBottomSheetController bottomSheetController;
  bool listItemsAllLoaded = false;
  bool listItemsLoading = false;
  num _minDistanceToBottom = 1500;

  MoxieListPageState();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(scrollListener);

    if (widget.filterUpdateController != null) {
      widget.filterUpdateController.stream.listen((updatedFilter) {
        onRefresh();
        hideBottomSheet();
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(scrollListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _showFab = widget.fab != null;
    return Scaffold(
      key: _key,
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(child: getWidgetTree()),
      floatingActionButton:
          _showFab && widget.fab != null ? widget.fab : Container(),
    );
  }

  Widget getWidgetTree() {
    return StoreConnector<MoxieAppState, ViewModel>(
      converter: widget.viewModelConverter,
      builder: (context, vm) {
        this.listItemsAllLoaded = vm.allLoaded;
        this.listItemsLoading = vm.loading;
        return RefreshIndicator(
            child: CustomScrollView(
              controller: _scrollController,
              physics: AlwaysScrollableScrollPhysics(),
              slivers: <Widget>[
                widget.appBar == null ? getDefaultAppBar() : widget.appBar,
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, index) {
                      return (vm.items == null ||
                              vm.items.length == 0 ||
                              index + 1 == vm.items.length)
                          ? getBottomLoadingCircle(vm, index)
                          : widget.listItemGenerate(vm.items[index]);
                    },
                    childCount:
                        vm.items?.length == null || vm.items?.length == 0
                            ? 1
                            : vm.items?.length,
                  ),
                ),
              ],
            ),
            onRefresh: onRefresh);
      },
    );
  }

  Widget getBottomLoadingCircle(ViewModel vm, index) {
    final nullOrEmpty = (vm.items == null || vm.items.isEmpty);
    final loadingMore = (vm.loading && (index + 1 != vm.items.length));

    final loadingWidget = Center(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: CircularProgressIndicator(),
    ));

    // Loading More initially

    // Loading More with already some

    // There are no results
    if (nullOrEmpty && !loadingMore) {
      return NoResultsFound();
    }

    return nullOrEmpty && loadingMore && vm.items.isNotEmpty
        ? loadingWidget
        : Column(
            children: <Widget>[
              vm.items.isNotEmpty ? widget.listItemGenerate(vm.items[index]) : Container(),
              vm.loading ? loadingWidget : Container()
            ],
          );
  }

  Future<Null> onRefresh() {
    _refreshIndicatorKey?.currentState?.show();
    // Only allow refresh, if not currently refreshing
    if (_refreshCompleter == null || _refreshCompleter.isCompleted) {
      _refreshCompleter = Completer<Null>();
      widget.onRefreshAction?.completer = _refreshCompleter;
      StoreProvider.of<MoxieAppState>(context).dispatch(widget.onRefreshAction);
    }
    return _refreshCompleter?.future;
  }

  Future scrollListener() async {
    // App Bar
    num updated = _scrollController.position.extentBefore;
    setState(() {
      _showFab = updated < _scrollPos;
      _scrollPos = updated;
    });

    // When only X amount of pixels left to scroll, load more data
    if (_scrollController.position.extentAfter < _minDistanceToBottom &&
        !listItemsAllLoaded &&
        !listItemsLoading) {
      _minDistanceToBottom += 1500;
      widget.onScrolledToBottom();
    } else {
      _minDistanceToBottom = 1500;
    }
  }

  void _showBottomSheetFilter() {
    bottomSheetController =
        _key.currentState.showBottomSheet((BuildContext context) {
      return widget.bottomSheetFilter;
    });
  }

  void hideBottomSheet() {
    if (bottomSheetController != null) {
      print("closing bottom sheet");
      bottomSheetController.close();
    }
  }

  SliverAppBar getDefaultAppBar() {
    return SliverAppBar(
      floating: true,
      pinned: false,
      snap: true,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: CustomText.qarmicSans(
          text: '${widget.appBarTitle}',
          fontSize: 16.0,
        ),
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.filter_list),
          onPressed: _showBottomSheetFilter,
        )
      ],
    );
  }
}

abstract class ViewModel<E> {
  final List<E> items;
  final bool loading;
  final bool allLoaded;

  ViewModel({this.items, this.loading, this.allLoaded});

//  @override
//  bool operator ==(Object other) =>
//      identical(this, other) ||
//          other is ViewModel<E> &&
//              runtimeType == other.runtimeType &&
//              items == other.items;
//
//  @override
//  int get hashCode => items.hashCode;
}
