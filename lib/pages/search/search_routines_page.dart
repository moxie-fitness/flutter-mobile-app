import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:moxie_fitness/components/app_bar_search_field.dart';
import 'package:moxie_fitness/components/components.dart';
import 'package:moxie_fitness/data_layer/actions/actions.dart';
import 'package:moxie_fitness/data_layer/app/moxie_app_state.dart';
import 'package:moxie_fitness/models/models.dart';
import 'package:moxie_fitness/pages/pages.dart';
import 'package:redux/redux.dart';

class SearchRoutinesPage extends StatefulWidget {

  @override
  _SearchRoutinesPageState createState () => new _SearchRoutinesPageState();
}

class _SearchRoutinesPageState extends State<SearchRoutinesPage> implements FilterAndSortList<Routine> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String currentUserId = null;
  RoutineListFilter _filter = new RoutineListFilter(showMineOnly: false);
  StreamController<RoutineListFilter> filterUpdateController;
  TextEditingController _searchRoutinesEditingController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    filterUpdateController = new StreamController<RoutineListFilter>();
    _searchRoutinesEditingController.addListener(onSearchTextChange);
    _auth.currentUser().then((FirebaseUser user) {
      this.setState(() {
        currentUserId = user?.uid;
      });
    });
  }

  @override
  void dispose() {
    _searchRoutinesEditingController.removeListener(onSearchTextChange);
    _searchRoutinesEditingController.dispose();
    filterUpdateController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new MoxieListPage<Routine, RoutineListFilter>(
      appBar: new SliverAppBar(
        leading: new Icon(Icons.search),
        title: new AppBarSearchField(
          hint: "Search Routines",
          textEditingController: _searchRoutinesEditingController,
        ),
      ),
      onScrolledToBottom: () {
        final storeProvider = StoreProvider.of<MoxieAppState>(context);
        storeProvider.dispatch(new LoadSearchRoutinesAction(
          filter: _filter
            ..offset = storeProvider.state.searchRoutines.length,
        ));
      },
      onRefreshAction: new LoadSearchRoutinesAction(
        filter: _filter
          ..offset = 0,
        freshValues: true
      ),
      bottomSheetFilter: bottomSheetFilter(),
      viewModelConverter: (store) => SearchRoutinesListViewModel.from(store),
      listItemGenerate: (routine) {
        return generateListItem(routine);
      },
      filterUpdateController: getFilterController()
    );
  }

  @override
  Widget generateListItem(Routine item) {
    return new RoutineListItem(
      routine: item,
      outerBgColor: Theme.of(context).primaryColor,
      allowSubscription: true,
      currentUserId: currentUserId
    );
  }

  @override
  Widget bottomSheetFilter() {
    return new StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return new Container(
          color: Theme.of(context).accentColor.withOpacity(0.8),
          height: 300.0,
          child: new Column(
            children: <Widget>[
              new Container(
                padding: const EdgeInsets.only(top: 8.0),
                child: new CustomText.qarmicSans(
                  text: 'Sort By',
                  fontSize: 18.0,
                ),
              ),
              new MoxieDropdown<RoutinesSort>(
                leadingIcon: Icons.sort,
                options: RoutinesSort.values,
                preSelected: _filter.sortBy,
                onChanged: (RoutinesSort item) {
                  print('SELECTED: $item');
                  setState(() {
                    _filter.sortBy = item;
                  });
                },
                menuItemsGenerator: (RoutinesSort option) {
                  String display; // default
                  switch (option) {
                    case RoutinesSort.name:
                      display = 'By name (a-z)';
                      break;
                    case RoutinesSort.workout_count:
                      display = 'By workouts count';
                      break;
                    case RoutinesSort.price:
                      display = 'Price';
                      break;
                    case RoutinesSort.price:
                      display = 'Rating';
                      break;
                    default:
                      display = 'Error';
                      break;
                  }
                  return new DropdownMenuItem<RoutinesSort>(
                    child: new Text('$display'),
                    value: option,
                  );
                },
              ),
              new Container(
                padding: const EdgeInsets.only(top: 8.0),
                child: new CustomText.qarmicSans(
                  text: 'Filter',
                  fontSize: 18.0,
                ),
              ),
              new MoxieFlatButton(
                data: 'Ok',
                onPressed: () {
                  filterUpdateController.add(_filter);
                }
              )
            ],
          ),
        );
      }
    );
  }

  @override
  getFilterController() {
    if(filterUpdateController == null) {
      filterUpdateController = new StreamController<RoutineListFilter>();
    }
    return filterUpdateController;
  }

  onSearchTextChange() {
   // if(_searchRoutinesEditingController.text.length > 2) {
      final storeProvider = StoreProvider.of<MoxieAppState>(context);
      _filter.filterMap.update("searchText", (v) => _searchRoutinesEditingController.text, ifAbsent: () => _searchRoutinesEditingController.text);

      if(!storeProvider.state.viewLoadersState.searchRoutinesListLoading) {
        storeProvider.dispatch(new LoadSearchRoutinesAction(
          filter: _filter
            ..offset = 0,
          freshValues: true)
        );
      }
    //}
  }
}

class SearchRoutinesListViewModel implements ViewModel<Routine>{
  final List<Routine> routines;
  final bool loading;
  final bool allLoaded;

  SearchRoutinesListViewModel({
    this.routines,
    this.loading,
    this.allLoaded,
  });

  static SearchRoutinesListViewModel from(Store<MoxieAppState> store) {
    return new SearchRoutinesListViewModel(
      routines: store.state.searchRoutines?.values?.toList() ?? <Routine>[],
      loading: store.state.viewLoadersState.searchRoutinesListLoading,
      allLoaded: store.state.allSearchRoutinesLoaded
    );
  }

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
      other is SearchRoutinesListViewModel &&
        runtimeType == other.runtimeType &&
        routines == other.routines &&
        allLoaded == other.allLoaded &&
        loading == other.loading;

  @override
  int get hashCode => routines.hashCode ^
    loading.hashCode ^
    allLoaded.hashCode;

  @override
  List<Routine> get items => routines;
}

