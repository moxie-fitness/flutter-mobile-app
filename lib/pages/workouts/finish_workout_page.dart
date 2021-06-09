import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:moxie_fitness/components/components.dart';
import 'package:moxie_fitness/data_layer/actions/all_actions.dart';
import 'package:moxie_fitness/data_layer/app/moxie_app_state.dart';
import 'package:moxie_fitness/models/models.dart';
import 'package:moxie_fitness/utils/utils.dart';
import 'package:redux/redux.dart';

class FinishWorkoutPage extends StatefulWidget {
  @override
  _FinishWorkoutPageState createState() => new _FinishWorkoutPageState();
}

class _FinishWorkoutPageState extends State<FinishWorkoutPage> {
  TextEditingController _commentsController = new TextEditingController();
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  var _saving = false;

  @override
  dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new StoreConnector<MoxieAppState, _FinishWorkoutPageViewModel>(
      converter: (store) => _FinishWorkoutPageViewModel.from(store),
      builder: (context, vm) {
        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            elevation: 0.0,
            leading: new Container(),
            centerTitle: true,
            title: new CustomText.qarmicSans(
              text: 'Finish Workout',
            ),
          ),
          body: Stack(
            children: <Widget>[
              Container(
                  color: Theme.of(context).primaryColor,
                  child: _bodyContainer(vm)
              ),
              _saving ? CircularProgressIndicator() : Container()
            ],
          ),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.save),
            onPressed: _finishWorkout,
          ),
        );
      }
    );
  }

  _bodyContainer(_FinishWorkoutPageViewModel vm) {
    var bodyWidgets = <Widget>[];
    final comments = Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 16.0, bottom: 25.0),
      child: new MoxieInputFieldArea(
        hint: 'Enter comments',
        icon: Icons.note_add,
        textInputType: TextInputType.multiline,
        textEditingController: _commentsController,
        validator: (val) => Utils.simpleTextValidator(val, who: 'Comments', minLength:  0, maxLength: 1000),
      ),
    );

    final exerciseLogs = vm.logs.map((ExerciseLog log) {
      return RecentExerciseLogHistory.buildLog(log);
    }).toList();

    bodyWidgets.add(comments);
    bodyWidgets.addAll(exerciseLogs);

    return ListView(
      children: bodyWidgets,
    );
  }

  void _finishWorkout() {
    if(_saving) return;
    final store = StoreProvider.of<MoxieAppState>(context);

    final Complete complete = store.state.completesState.activeWorkout;
    complete.completed = true;
    complete.comment = _commentsController.value.text ?? '';
    store.dispatch(
      SaveAction<Complete>(
        item: complete,
        type: EModelTypes.completableWorkout,
        onSavedCallback: (updatedComplete) {
          if(updatedComplete != null) {
            final from = DateTime.now().subtract(Duration(days: 30));
            final to = DateTime.now().add(Duration(days: 90));

            store.dispatch(ClearActiveWorkoutAction());
            store.dispatch(LoadCompletesForCalendar(from: from, to: to));

            _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Workout finished!')));
            Navigator.of(context).pop();
          } else {
            _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Oops... something went wrong.')));
          }
        }
      )
    );
  }
}

class _FinishWorkoutPageViewModel {
  final Complete completedWorkout;
  final List<ExerciseLog> logs;

  _FinishWorkoutPageViewModel({this.logs, this.completedWorkout});

  static _FinishWorkoutPageViewModel from(Store<MoxieAppState> store) {
    return new _FinishWorkoutPageViewModel(
      completedWorkout: store.state.completesState.activeWorkout,
      logs: store.state.completesState.activeWorkoutLogs ?? <ExerciseLog>[]
    );
  }
}
