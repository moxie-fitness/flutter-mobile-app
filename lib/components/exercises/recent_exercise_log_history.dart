import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:moxie_fitness/components/components.dart';
import 'package:moxie_fitness/data_layer/app/moxie_app_state.dart';
import 'package:moxie_fitness/models/models.dart';
import 'package:moxie_fitness/utils/utils.dart';
import 'package:redux/redux.dart';

class RecentExerciseLogHistory extends StatelessWidget {

  final exerciseId;
  final howMany;

  RecentExerciseLogHistory({
    @required this.exerciseId,
    this.howMany = 5
  }) : assert(howMany < 10, 'howMany must be less than 10!');

  @override
  Widget build(BuildContext context) {
    return new StoreConnector<MoxieAppState, _RecentExerciseLogHistoryViewModel>(
      converter: (Store<MoxieAppState> store){
        return _RecentExerciseLogHistoryViewModel.from(store, this.exerciseId);
      },
      builder: (context, vm) {

        // [ key: dateTimeString, value: List<ExerciseLog> ]
        var logsDayMap = Map<String, List<ExerciseLog>>();

        if(vm.logs != null) {
          vm.logs.forEach((exerciseLog) {
            var list = logsDayMap[Utils.convertDateToDisplay(exerciseLog.created_at)];
            if(list == null) {
              list = <ExerciseLog>[]..add(exerciseLog);
            } else {
              list.add(exerciseLog);
            }
            logsDayMap.putIfAbsent(Utils.convertDateToDisplay(exerciseLog.created_at), () => list);
          });
        }

        var componentsLogs = <Widget>[];
        logsDayMap.forEach((dateKey, exerciseLogs) {
          bool first = true;
          exerciseLogs.forEach((exerciseLog) {
            componentsLogs.add(buildLog(exerciseLog, first));
            first = false;
          });
        });

        return new Column(
          children: componentsLogs
        );

//        return new Column(
//          children: vm.logs != null ?
//            vm.logs.map((exerciseLog) {
//              return buildLog(exerciseLog);
//            }).toList()
//            : <Widget>[]
//        );
      }
    );
  }

  static Widget buildLog(ExerciseLog exerciseLog, [bool withDateHeader = false]) {
    return Column(
      children: <Widget>[
        withDateHeader ? CustomText.qarmicSans(
          text: Utils.convertDateToDisplay(exerciseLog.created_at),
          fontSize: 17.8,
        ) : Container(),
        new Container(
          padding: const EdgeInsets.only(top: 5.0, left: 32.0, right: 32.0, bottom: 15.0),
          child: new Row(
            children: <Widget>[
              buildLogPiece("Time", Utils.convertDateToDisplayOnlyTime(exerciseLog.created_at), withLeftMargin: false),
              buildLogPiece("Sets", exerciseLog.sets),
              buildLogPiece("Reps", exerciseLog.reps),
              buildLogPiece("Weight", exerciseLog.weight),
              buildLogPiece("Duration", exerciseLog.duration_secs),
            ],
          ),
        ),
      ],
    );
  }

  static Widget buildLogPiece(String title, value, { bool withLeftMargin = true }) {
    return value != null ?
      Container(
        margin: withLeftMargin ? const EdgeInsets.symmetric(horizontal: 10.0) : const EdgeInsets.only(right: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: CustomText.qarmicSans(
                text: title,
                fontWeight: FontWeight.bold,
                fontSize: 11.0,
              ),
            ),
            CustomText.qarmicSans(
              text: value,
              fontSize: 10.0,
            )
          ],
        ),
      ) : Container();
  }
}


class _RecentExerciseLogHistoryViewModel {
  List<ExerciseLog> logs;

  _RecentExerciseLogHistoryViewModel({
    this.logs,
  });

  static _RecentExerciseLogHistoryViewModel from(Store<MoxieAppState> store, exerciseId) {
    return new _RecentExerciseLogHistoryViewModel(
      logs: store.state.exercises[exerciseId]?.exerciseLogs ?? <ExerciseLog>[],
    );
  }

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
      other is _RecentExerciseLogHistoryViewModel &&
        runtimeType == other.runtimeType &&
        logs == other.logs;

  @override
  int get hashCode => logs.hashCode;
}
