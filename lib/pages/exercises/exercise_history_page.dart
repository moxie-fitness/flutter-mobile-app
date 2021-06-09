import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:moxie_fitness/components/components.dart';
import 'package:moxie_fitness/data_layer/app/moxie_app_state.dart';
import 'package:moxie_fitness/models/models.dart';
import 'package:redux/redux.dart';
// import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter_sparkline/flutter_sparkline.dart';

class ExerciseHistoryPage extends StatefulWidget {
  final exerciseId;

  ExerciseHistoryPage({this.exerciseId});

  @override
  _ExerciseHistoryPageState createState() => _ExerciseHistoryPageState();
}

class _ExerciseHistoryPageState extends State<ExerciseHistoryPage> {
  // ExerciseLogsChartOptions options = ExerciseLogsChartOptions(
  //     sets: true,
  //     reps: true,
  //     weight: true,
  //     strength: true,
  //     duration: true,
  //     setsColor: charts.MaterialPalette.red.shadeDefault,
  //     repsColor: charts.MaterialPalette.green.shadeDefault,
  //     weightColor: charts.MaterialPalette.blue.shadeDefault,
  //     strengthColor: charts.MaterialPalette.black,
  //     durationColor: charts.MaterialPalette.purple.shadeDefault,
  //     setsTColor: Colors.red,
  //     repsTColor: Colors.green,
  //     weightTColor: Colors.blue,
  //     strengthTColor: Colors.black,
  //     durationTColor: Colors.purple);

  ScrollController _scrollController;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<MoxieAppState, _ExerciseHistoryPageViewModel>(
        converter: (Store<MoxieAppState> store) {
      return _ExerciseHistoryPageViewModel.from(store, widget.exerciseId);
    }, builder: (context, _ExerciseHistoryPageViewModel vm) {
      final List<double> sets = <double>[];
      final List<double> weights = <double>[];
      final List<double> reps = <double>[];
      final List<double> durations = <double>[];

      vm.logs.forEach((log) {
        if (log.sets != null) sets.add(log.sets.toDouble());
        if (log.weight != null) weights.add(log.weight.toDouble());
        if (log.reps != null) reps.add(log.reps.toDouble());
        if (log.duration_secs != null)
          durations.add(log.duration_secs.toDouble());
      });

      final bodyWidgets = <Widget>[
        weights.isNotEmpty
            ? _buildCard('Weight', weights, Theme.of(context).primaryColor)
            : Container(),
        reps.isNotEmpty ? _buildCard('Reps', reps, Colors.amber) : Container(),
        sets.isNotEmpty ? _buildCard('Sets', sets, Colors.green) : Container(),
        durations.isNotEmpty
            ? _buildCard('Duration (s)', durations, Colors.pink)
            : Container(),
        // Container(
        //   child: _buildSwitches(vm),
        // )
      ];

      if ((vm.logs?.length ?? 0) < 2) {
        bodyWidgets.clear();
        bodyWidgets.add(Container(
          margin: const EdgeInsets.all(16.0),
          child: Center(
              child:
                  Text('Oops! There are not enough logs for this exercise!')),
        ));
      }

      return Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          margin: const EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
          child: Container(
            margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
            child: CustomScrollView(
                controller: _scrollController,
                slivers: <Widget>[
                  _buildSliverAppbar(vm),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                        (BuildContext context, index) {
                      return bodyWidgets[index];
                    }, childCount: bodyWidgets.length),
                  ),
                ]),
          ),
        ),
      );
    });
  }

  SliverAppBar _buildSliverAppbar(_ExerciseHistoryPageViewModel vm) {
    var appbar = SliverAppBar(
      floating: true,
      pinned: false,
      snap: true,
      backgroundColor: Colors.white,
      leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context)),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: CustomText.qarmicSans(
          text: '${vm.exercise.name} Logs',
          color: Colors.black,
        ),
      ),
    );
    return appbar;
  }

  // _buildSwitches(_ExerciseHistoryPageViewModel vm) {
  //   bool showSetsOption =
  //       vm.logs.any((ExerciseLog log) => log.sets != null && log.sets != 0);
  //   bool showRepsOption =
  //       vm.logs.any((ExerciseLog log) => log.reps != null && log.reps != 0);
  //   bool showWeightsOption =
  //       vm.logs.any((ExerciseLog log) => log.weight != null && log.weight != 0);
  //   bool showDurationOption = vm.logs.any((ExerciseLog log) =>
  //       log.duration_secs != null && log.duration_secs != 0);
  //   bool showStrengthOption = showRepsOption && showWeightsOption;

  //   if (!showSetsOption) options.sets = false;
  //   if (!showRepsOption) options.reps = false;
  //   if (!showWeightsOption) options.weight = false;
  //   if (!showDurationOption) options.duration = false;
  //   if (!showStrengthOption) options.strength = false;

  //   return Column(
  //     children: <Widget>[
  //       showSetsOption
  //           ? _buildSwitch(
  //               options.sets,
  //               (val) => setState(() => options.sets = val),
  //               'Sets',
  //               options.setsTColor)
  //           : Container(),
  //       showRepsOption
  //           ? _buildSwitch(
  //               options.reps,
  //               (val) => setState(() => options.reps = val),
  //               'Reps',
  //               options.repsTColor)
  //           : Container(),
  //       showWeightsOption
  //           ? _buildSwitch(
  //               options.weight,
  //               (val) => setState(() => options.weight = val),
  //               'Weight',
  //               options.weightTColor)
  //           : Container(),
  //       showStrengthOption
  //           ? _buildSwitch(
  //               options.strength,
  //               (val) => setState(() => options.strength = val),
  //               'Strength (Reps x Weight)',
  //               options.strengthTColor)
  //           : Container(),
  //       showDurationOption
  //           ? _buildSwitch(
  //               options.duration,
  //               (val) => setState(() => options.duration = val),
  //               'Duration',
  //               options.durationTColor)
  //           : Container(),
  //     ],
  //   );
  // }

  _buildSwitch(bool value, Function onChange, String text, Color color) {
    return Row(
      children: <Widget>[
        Expanded(
          child: MoxieSwitchInput(
              value: value,
              title: InputDecorator(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintStyle:
                      const TextStyle(color: Colors.white, fontSize: 15.0),
                  contentPadding: const EdgeInsets.only(
                      top: 5.0, right: 5.0, bottom: 5.0, left: 5.0),
                ),
                child: Text(text, style: TextStyle(color: color)),
              ),
              onChanged: onChange),
        )
      ],
    );
  }

  _buildCard(String title, List<double> data, Color color) {
    return Card(
      elevation: 12.0,
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Container(
              child: CustomText.qarmicSans(
                text: title,
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
                color: color,
              ),
            ),
            Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                constraints: BoxConstraints(
                    maxHeight: 85,
                    minHeight: 75,
                    maxWidth: MediaQuery.of(context).size.width),
                // child: ExercisesChart.withExerciseLogs(vm.logs, options),
                child: Sparkline(
                  data: data,
                  lineColor: color,
                  pointsMode: PointsMode.all,
                  pointSize: 8.0,
                  pointColor: Colors.blue,
                )),
          ],
        ),
      ),
    );
  }
}

class _ExerciseHistoryPageViewModel {
  final List<ExerciseLog> logs;
  final Exercise exercise;

  _ExerciseHistoryPageViewModel({this.logs, this.exercise});

  static _ExerciseHistoryPageViewModel from(
      Store<MoxieAppState> store, exerciseId) {
    final exercise = store.state.exercises[exerciseId];
    return _ExerciseHistoryPageViewModel(
      exercise: exercise,
      logs: exercise?.exerciseLogs ?? <ExerciseLog>[],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ExerciseHistoryPageViewModel &&
          runtimeType == other.runtimeType &&
          exercise == other.exercise &&
          logs == other.logs;

  @override
  int get hashCode => logs.hashCode;
}

class ExerciseLogsChartOptions {
  bool sets;
  bool reps;
  bool weight;
  bool duration;
  bool strength;

  final setsColor;
  final repsColor;
  final weightColor;
  final durationColor;
  final strengthColor;

  final setsTColor;
  final repsTColor;
  final weightTColor;
  final durationTColor;
  final strengthTColor;

  ExerciseLogsChartOptions(
      {this.sets,
      this.reps,
      this.weight,
      this.duration,
      this.strength,
      this.setsColor,
      this.weightColor,
      this.durationColor,
      this.strengthColor,
      this.repsColor,
      this.setsTColor,
      this.weightTColor,
      this.durationTColor,
      this.strengthTColor,
      this.repsTColor});
}
