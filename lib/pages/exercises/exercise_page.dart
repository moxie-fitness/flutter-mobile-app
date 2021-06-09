import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:moxie_fitness/components/components.dart';
import 'package:moxie_fitness/config/routes.dart';
import 'package:moxie_fitness/data_layer/actions/all_actions.dart';
import 'package:moxie_fitness/data_layer/app/moxie_app_state.dart';
import 'package:moxie_fitness/data_layer/selectors/selectors.dart';
import 'package:moxie_fitness/models/models.dart';
import 'package:moxie_fitness/utils/utils.dart';
import 'package:redux/redux.dart';
import 'package:youtube_player/youtube_player.dart';

enum LoggerUpdateType { attemptSave, saveSuccessful }

class ExercisePage extends StatefulWidget {
  final id;
  final int completableId;

  ExercisePage({this.id, this.completableId});

  @override
  ExercisePageState createState() => ExercisePageState();
}

class ExercisePageState extends State<ExercisePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _showingBottomSheet = false;
  ScrollController _scrollController;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<MoxieAppState, _ExercisePageViewModel>(
        converter: (Store<MoxieAppState> store) {
      return _ExercisePageViewModel.from(store, widget.id);
    }, builder: (context, vm) {
      return vm.exercise != null ? _buildBody(vm) : _buildLoading;
    });
  }

  Scaffold get _buildLoading {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  _buildBody(_ExercisePageViewModel vm) {
    final logger = _ExerciseLogger(
      exercise: vm.exercise,
      completableId: widget.completableId,
    );

    final List carouselWidgets =
        carouselWidgetsFromUrls(vm.exercise.post?.media);
    if (vm.exercise.youtube_url != null && vm.exercise.youtube_url.isNotEmpty) {
      carouselWidgets.add(Builder(builder: (BuildContext context) {
        return Container(
          color: Colors.black,
          child: Center(
            child: YoutubePlayer(
              context: context,
              source: vm.exercise.youtube_url,
              quality: YoutubeQuality.HD,
            ),
          ),
        );
      }));
    }

    final bodyWidgets = <Widget>[
      Card(
        elevation: 1.0,
        child: MoxieCarouselListItem(
          carouselWidgets: carouselWidgets,
          height: 300.0,
          dotColor: Colors.black,
        ),
      ),
      _buildInstructions(vm),
      RecentExerciseLogHistory(
        exerciseId: widget.id,
      )
    ];

    final bodyContainer = Container(
      margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
      child: CustomScrollView(controller: _scrollController, slivers: <Widget>[
        _buildSliverAppbar(vm),
        SliverList(
          delegate: SliverChildBuilderDelegate((BuildContext context, index) {
            return bodyWidgets[index];
          }, childCount: bodyWidgets.length),
        ),
      ]),
    );

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).primaryColor,
      body: Container(
        margin: const EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
        child: bodyContainer,
      ),
      floatingActionButton: !_showingBottomSheet
          ? FloatingActionButton(
              child: Icon(Icons.playlist_add),
              onPressed: () => _showBottomSheet(logger),
            )
          : Container(),
    );
  }

  SliverAppBar _buildSliverAppbar(_ExercisePageViewModel vm) {
    var appbar = SliverAppBar(
      floating: true,
      pinned: false,
      snap: true,
      leading: widget.completableId == null
          ? IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context))
          : Container(),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: CustomText.qarmicSans(
          text: '${vm.exercise.name}',
        ),
      ),
      actions: <Widget>[
        widget.completableId == null
            ? IconButton(
                icon: Icon(
                  Icons.insert_chart,
                  color: Colors.white,
                ),
                onPressed: () => Routes.router
                    .navigateTo(context, '/exercises-history/${widget.id}'),
              )
            : Container()
      ],
    );
    return appbar;
  }

  _buildInstructions(vm) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              '${vm?.exercise?.post?.content ?? ''}',
//            overflow: TextOverflow.fade,
              maxLines: 7,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'FlamanteRoma',
              ),
            ),
          ),
        )
      ],
    );
  }

  _showBottomSheet(logger) {
    setState(() {
      _showingBottomSheet = true;
    });

    _scaffoldKey.currentState
        .showBottomSheet((context) {
          return Container(
            height: 350.0,
            color: Theme.of(context).primaryColor,
            child: Padding(
              padding: const EdgeInsets.only(top: 50.0),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(25.0),
                        topRight: const Radius.circular(25.0))),
                child: logger,
              ),
            ),
          );
        })
        .closed
        .whenComplete(() {
          setState(() {
            _showingBottomSheet = false;
          });
        });
  }
}

class _ExerciseLogger extends StatefulWidget {
  final Exercise exercise;
//  final ExerciseWorkout exerciseWorkout;
  final int completableId;
  final scaffoldKey;

  _ExerciseLogger(
      {this.scaffoldKey, @required this.exercise, this.completableId});

  @override
  _ExerciseLoggerState createState() {
    return _ExerciseLoggerState();
  }
}

class _ExerciseLoggerState extends State<_ExerciseLogger> {
  final _setsController = TextEditingController();
  final _repsController = TextEditingController();
  final _weightController = TextEditingController();
  final _durationSecsController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool _measurement = false; // Default to imperial
  bool _saving = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    _durationSecsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreProvider.of<MoxieAppState>(context);
    _measurement = store.state.moxieuser.gender;

    final inputs = _buildInputs();
    return Form(
      key: formKey,
      child: Stack(children: <Widget>[
        _buildAddButton(),
        Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Stack(children: <Widget>[
            Container(
              margin: const EdgeInsets.only(top: 15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: inputs,
              ),
            ),
          ]),
        )
      ]),
    );
  }

  _buildAddButton() {
    final btn = _saving
        ? CircularProgressIndicator(
            backgroundColor: Colors.lightBlue,
          )
        : FloatingActionButton(
            child: Icon(
              Icons.check,
              color: Colors.white,
            ),
            onPressed: validateLog,
          );

    return Align(
      alignment: Alignment.topRight,
      child: Transform(
        transform: Matrix4.translationValues(-15.0, -30.0, 0.0),
        child: btn,
      ),
    );
  }

  _buildInputs() {
    const styleColor = Colors.white70;

    final hintStyle = const TextStyle(color: styleColor, fontSize: 15.0);

    final setsInput = Expanded(
      flex: 1,
      child: Center(
        child: MoxieInputFieldArea(
          hint: 'Sets',
          icon: Icons.format_list_numbered,
          iconColor: styleColor,
          hintStyle: hintStyle,
          textInputType: TextInputType.number,
          textEditingController: _setsController,
          maxLength: 2,
          validator: (val) => Utils.simpleNumberValidator(val,
              who: 'Sets', minVal: 0, maxVal: 99, canBeEmpty: true),
        ),
      ),
    );
    final repsInput = Expanded(
      flex: 1,
      child: Center(
        child: MoxieInputFieldArea(
          hint: 'Reps',
          icon: Icons.format_list_numbered,
          iconColor: styleColor,
          hintStyle: hintStyle,
          textInputType: TextInputType.number,
          textEditingController: _repsController,
          maxLength: 2,
          validator: (val) => Utils.simpleNumberValidator(val,
              who: 'Reps', minVal: 1, maxVal: 99, canBeEmpty: true),
        ),
      ),
    );
    final weightInput = Expanded(
      flex: 1,
      child: Center(
        child: MoxieInputFieldArea(
          hint: 'Weight in ${_measurement ? 'kg' : 'lbs'}',
          icon: Icons.line_weight,
          iconColor: styleColor,
          hintStyle: hintStyle,
          textInputType: TextInputType.number,
          textEditingController: _weightController,
          maxLength: 6,
          validator: (val) => Utils.simpleNumberValidator(val,
              who: 'Weight', minVal: 0, maxVal: 1000, canBeEmpty: true),
        ),
      ),
    );
    final durationSecsInput = Expanded(
      flex: 1,
      child: Center(
        child: MoxieInputFieldArea(
          hint: 'Duration (s)',
          icon: Icons.timer,
          iconColor: styleColor,
          hintStyle: hintStyle,
          textInputType: TextInputType.number,
          textEditingController: _durationSecsController,
          maxLength: 3,
          validator: (val) => Utils.simpleNumberValidator(val,
              who: 'Duration', minVal: 0, maxVal: 1000, canBeEmpty: true),
        ),
      ),
    );

    // Default, when exercise is shown not coming from a Workout (aka NOT ExerciseWorkout)
    return _buildInputsForExercise(
        setsInput, repsInput, weightInput, durationSecsInput);
  }

  _buildInputsForExercise(Expanded setsInput, Expanded repsInput,
      Expanded weightInput, Expanded durationSecsInput) {
    return <Widget>[setsInput, repsInput, weightInput, durationSecsInput];
  }

  void _clearInputs() {
    _setsController.clear();
    _weightController.clear();
    _repsController.clear();
    _durationSecsController.clear();
  }

  void validateLog() {
    // Force dismiss Keyboard
    SystemChannels.textInput.invokeMethod('TextInput.hide');

    final form = formKey.currentState;
    if (form.validate()) {
      form.save();

      if (_durationSecsController.text.isEmpty &&
          _setsController.text.isEmpty &&
          _repsController.text.isEmpty &&
          _weightController.text.isEmpty) {
        _showError('At least one entry must be logged.');
        return;
      } else {
        _submitLog();
      }
    }
  }

  void _submitLog() {
    setState(() {
      _saving = true;
    });

    final store = StoreProvider.of<MoxieAppState>(context);
    final moxieuser = store.state.moxieuser;

    ExerciseLog exerciseLog = ExerciseLog()
      ..sets = int.tryParse(_setsController.text)
      ..reps = int.tryParse(_repsController.text)
      ..weight = double.tryParse(_weightController.text)
      ..duration_secs = int.tryParse(_durationSecsController.text)
      ..moxieuser_id = moxieuser.id;

    if (widget.completableId != null) {
      exerciseLog
        ..exercise_id = widget.exercise.id
        ..completed_workout_id = widget.completableId;
    } else {
      exerciseLog.exercise_id = widget.exercise.id;
    }

    Navigator.pop(context);

    store.dispatch(SaveAction<ExerciseLog>(
        item: exerciseLog,
        type: EModelTypes.exerciseLog,
        onSavedCallback: (exerciseLog) {
          if (exerciseLog != null) {
            // If currently in an active workout, dispatch it to exercise log.
            if (widget.completableId != null) {
              store.dispatch(AddExerciseLogToActiveWorkoutAction(exerciseLog));
            }

            setState(() {
              _clearInputs();
              _saving = false;
            });
          }
        }));
  }

  void _showError(String err) {
    showDialog<Null>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text(err),
            actions: <Widget>[
              MoxieFlatButton(
                  data: 'Ok',
                  textColor: Theme.of(context).primaryColor,
                  onPressed: () => Navigator.of(context).pop())
            ],
          );
        });
  }
}

enum ExerciseLogType { Sets, Reps, Weight, Duration }

class _ExercisePageViewModel {
  final id;
  Exercise exercise;

  _ExercisePageViewModel({this.id, this.exercise});

  factory _ExercisePageViewModel.from(Store<MoxieAppState> store, int id) {
    final exercise =
        store.state.exercises != null ? store.state.exercises[id] : null;

    if (exercise == null && !isLoadingSelector(store.state)) {
      store.dispatch(LoadSingleItem(type: EModelTypes.exercise, itemId: id));
    }

    return _ExercisePageViewModel(id: id, exercise: exercise);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ExercisePageViewModel &&
          runtimeType == other.runtimeType &&
          exercise == other.exercise &&
          id == other.id;

  @override
  int get hashCode => exercise.hashCode ^ id.hashCode;
}
