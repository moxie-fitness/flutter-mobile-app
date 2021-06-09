// import 'package:flutter/widgets.dart';
// import 'package:charts_flutter/flutter.dart' as charts;
// import 'package:moxie_fitness/models/models.dart';
// import 'package:moxie_fitness/pages/exercises/exercise_history_page.dart';

// class ExercisesChart extends StatelessWidget {
//   final List<charts.Series> seriesList;
//   final bool animate;

//   ExercisesChart(this.seriesList, {this.animate});

//   /// Creates a [TimeSeriesChart] with the ExerciseLogs data list
//   factory ExercisesChart.withExerciseLogs(
//       List<ExerciseLog> logs, ExerciseLogsChartOptions options) {
//     final List<charts.Series<TimeSeriesExerciseLogs, DateTime>> seriesList = [];
//     if (options.sets) {
//       seriesList.add(
//         charts.Series<TimeSeriesExerciseLogs, DateTime>(
//           id: 'sets',
//           colorFn: (_, __) => options.setsColor,
//           domainFn: (TimeSeriesExerciseLogs logs, _) => logs.time,
//           measureFn: (TimeSeriesExerciseLogs logs, _) => logs.value,
//           data: logs
//               .map((ExerciseLog log) =>
//                   TimeSeriesExerciseLogs(log.created_at, log.sets))
//               .toList(),
//         ),
//       );
//     }
//     if (options.reps) {
//       seriesList.add(
//         charts.Series<TimeSeriesExerciseLogs, DateTime>(
//           id: 'reps',
//           colorFn: (_, __) => options.repsColor,
//           domainFn: (TimeSeriesExerciseLogs logs, _) => logs.time,
//           measureFn: (TimeSeriesExerciseLogs logs, _) => logs.value,
//           data: logs
//               .map((ExerciseLog log) =>
//                   TimeSeriesExerciseLogs(log.created_at, log.reps))
//               .toList(),
//         ),
//       );
//     }
//     if (options.weight) {
//       seriesList.add(
//         charts.Series<TimeSeriesExerciseLogs, DateTime>(
//           id: 'weight',
//           colorFn: (_, __) => options.weightColor,
//           domainFn: (TimeSeriesExerciseLogs logs, _) => logs.time,
//           measureFn: (TimeSeriesExerciseLogs logs, _) => logs.value,
//           data: logs
//               .map((ExerciseLog log) =>
//                   TimeSeriesExerciseLogs(log.created_at, log.weight))
//               .toList(),
//         ),
//       );
//     }
//     if (options.strength) {
//       seriesList.add(
//         charts.Series<TimeSeriesExerciseLogs, DateTime>(
//           id: 'strength',
//           colorFn: (_, __) => options.strengthColor,
//           domainFn: (TimeSeriesExerciseLogs logs, _) => logs.time,
//           measureFn: (TimeSeriesExerciseLogs logs, _) => logs.value,
//           data: logs
//               .map((ExerciseLog log) => TimeSeriesExerciseLogs(
//                   log.created_at, log.reps ?? 0 * log.weight ?? 0))
//               .toList(),
//         ),
//       );
//     }
//     if (options.duration) {
//       seriesList.add(
//         charts.Series<TimeSeriesExerciseLogs, DateTime>(
//           id: 'duration',
//           colorFn: (_, __) => options.durationColor,
//           domainFn: (TimeSeriesExerciseLogs logs, _) => logs.time,
//           measureFn: (TimeSeriesExerciseLogs logs, _) => logs.value,
//           data: logs
//               .map((ExerciseLog log) =>
//                   TimeSeriesExerciseLogs(log.created_at, log.duration_secs))
//               .toList(),
//         ),
//       );
//     }
//     return ExercisesChart(
//       seriesList,
//       animate: true,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return charts.TimeSeriesChart(
//       seriesList,
//       animate: animate,
//       // Configure the default renderer as a line renderer. This will be used
//       // for any series that does not define a rendererIdKey.
//       //
//       // This is the default configuration, but is shown here for  illustration.
//       defaultRenderer: charts.LineRendererConfig(),
//       // Custom renderer configuration for the point series.
//       customSeriesRenderers: [
//         charts.PointRendererConfig(
//             // ID used to link series to this renderer.
//             customRendererId: 'customPoint')
//       ],
//       // Optionally pass in a [DateTimeFactory] used by the chart. The factory
//       // should create the same type of [DateTime] as the data provided. If none
//       // specified, the default creates local date time.
//       dateTimeFactory: const charts.LocalDateTimeFactory(),
//     );
//   }
// }

// class TimeSeriesExerciseLogs {
//   final DateTime time;
//   final int value;

//   TimeSeriesExerciseLogs(this.time, this.value);
// }
