import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:moxie_fitness/components/components.dart';
import 'package:moxie_fitness/components/form_wizard/form_wizard_pager.dart';
import 'package:moxie_fitness/data_layer/actions/all_actions.dart';
import 'package:moxie_fitness/data_layer/app/moxie_app_state.dart';
import 'package:moxie_fitness/models/models.dart';
import 'package:moxie_fitness/utils/utils.dart';
import 'package:redux/redux.dart';

class CreateRoutinePage extends StatefulWidget {
  @override
  CreateRoutinePageState createState() => CreateRoutinePageState();
}

class CreateRoutinePageState extends State<CreateRoutinePage> {
  final formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final int maxNumWeeks = 12;

  ///
  /// Map of the workouts in the correct order & positions that will be added.
  /// Key: Week in the routine, starting from 0
  /// Value: List of workouts for that week, in the order they should be in, starting from 0.
  ///
  SplayTreeMap<int, List<Workout>> _workoutsInWeeklyOrder =
      SplayTreeMap<int, List<Workout>>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  StreamController<CreateRoutineWorkoutUpdate> _workoutsAddController;

  Routine newRoutine = Routine();
  List<File> _selectedImages = <File>[];
  LookupOption _selectedGoal;
  bool _isPublic = true;
  bool _savingForm = false;
  double _price = 0.0;

  CreateRoutinePageState() {
    _workoutsAddController = StreamController<CreateRoutineWorkoutUpdate>();
    _workoutsAddController.stream.listen((CreateRoutineWorkoutUpdate update) {
      setState(() {
        if (update.type == CreateRoutineWorkoutUpdateType.add) {
          _workoutsInWeeklyOrder.update(update.week, (list) {
            list.add(update.workout);
            return list;
          }, ifAbsent: () => <Workout>[update.workout]);
        } else if (update.type == CreateRoutineWorkoutUpdateType.order) {
          _workoutsInWeeklyOrder.update(
            update.week,
            (list) {
              final temp = list.removeAt(update.onDragFinishOldIndex);
              list.insert(update.onDragFinishNewIndex, temp);
              return list;
            },
          );
        } else if (update.type == CreateRoutineWorkoutUpdateType.remove) {
          _workoutsInWeeklyOrder.update(
            update.week,
            (list) {
              list.removeAt(update.removeIndex);
              return list;
            },
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _workoutsAddController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: SafeArea(
          bottom: false,
          top: false,
          child: StoreConnector<MoxieAppState, CreateRoutineRequiredData>(
              converter: CreateRoutineRequiredData.from,
              builder: (context, vm) {
                return renderWithData(vm);
              }),
        ));
  }

  Widget renderWithData(CreateRoutineRequiredData data) {
    // Set default selected goal
    if (_selectedGoal == null &&
        data.goalOptions != null &&
        data.goalOptions.length > 0) _selectedGoal = data.goalOptions[0];

    final pages = _getPages(data);
    return SingleChildScrollView(
      child: FormWizardPager(
        formKey: formKey,
        pages: pages,
        onAttemptFinish: _validateForm,
        saving: _savingForm,
      ),
    );
  }

  List<FormWizardPageViewModel> _getPages(CreateRoutineRequiredData data) {
    final pricePageVm = FormWizardPageViewModel(
        heading:
            'We recommend keeping it free and building up followers first :)',
        input: MoxieNumberPicker(
          title: 'Price',
          hint: '${_price == 0 ? 'FREE!' : 'Charge \$$_price'}',
          min: 0,
          max: 20,
          current: _price,
          icon: Icons.attach_money,
          decimalPlaces: 2,
          onUpdated: (value) {
            if (value != null) {
              setState(() {
                _price = value;
              });
            }
          },
        ),
        color: Colors.cyan);

    final pages = [
      FormWizardPageViewModel(
        heading: 'What do you want to call your Routine?',
        input: MoxieInputFieldArea(
          hint: 'Enter name',
          textEditingController: _nameController,
          validator: (val) => Utils.simpleTextValidator(val,
              who: 'Name', minLength: 5, maxLength: 100),
        ),
        assetPath: 'assets/logo.png',
        color: Colors.redAccent,
      ),
      FormWizardPageViewModel(
        heading: 'Describe your routine',
        input: MoxieInputFieldArea(
          hint: 'Description',
          textEditingController: _descriptionController,
          maxLines: 5,
          maxLength: 1000,
          textInputType: TextInputType.multiline,
          validator: (val) => Utils.simpleTextValidator(val,
              who: 'Name', minLength: 5, maxLength: 1000),
        ),
        color: Colors.teal,
      ),
      FormWizardPageViewModel(
          heading: 'What is the goal for this routine?',
          input: data.goalOptions.isEmpty
              ? CenteredCircularProgress()
              : MoxieDropdown<LookupOption>(
                  preSelected: _selectedGoal,
                  options: data.goalOptions,
                  onChanged: (option) {
                    setState(() {
                      _selectedGoal = option;
                    });
                  },
                  menuItemsGenerator: (LookupOption option) {
                    return DropdownMenuItem<LookupOption>(
                      child: Text('${option.value}'),
                      value: option,
                    );
                  },
                  color: Colors.white,
                ),
          color: Colors.lime),
      FormWizardPageViewModel(
          heading: 'Want to share with the world? Make it public!',
          input: MoxieSwitchInput(
            value: _isPublic,
            title: Text(
              _isPublic ? 'I want to share!' : 'It\'s for me only.',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              'Currently set to ${_isPublic ? 'public' : 'private'}.',
              style: TextStyle(color: Colors.white, fontSize: 10.0),
            ),
            onChanged: (val) {
              setState(() {
                _isPublic = val;
              });
            },
          ),
          color: Colors.pink),
//      pricePageVm,
      FormWizardPageViewModel(
        heading: 'Choose workouts for your routine',
        input: WorkoutsPickerOpener(
          workoutsInWeeklyOrder: _workoutsInWeeklyOrder,
          backgroundColor: Colors.indigo,
          workoutsAddController: _workoutsAddController,
          maxWeeks: maxNumWeeks,
        ),
        color: Colors.indigo,
      ),
      FormWizardPageViewModel(
        heading: 'Upload some images for your routine!',
        input: ImageSelectorOpener(
          images: _selectedImages,
          backgroundColor: Colors.teal[400],
          onImagesUpdated: (images) {
            setState(() {
              if (images != null) _selectedImages = images;
            });
          },
          maxImages: 6,
        ),
        color: Colors.teal[400],
      ),
    ];

//    if(!_isPublic && pages.contains(pricePageVm)) {
//      pages.remove(pricePageVm);
//    } else if(!pages.contains(pricePageVm)){
//      pages.insert(4, pricePageVm);
//    }

    return pages;
  }

  void _validateForm() {
    String err;
    if ((err = Utils.simpleTextValidator(_nameController.value.text,
            who: 'Name', minLength: 5, maxLength: 100)) !=
        null) {
      _showSnackBar(err);
      return;
    }

    if ((err = Utils.simpleTextValidator(_descriptionController.value.text,
            who: 'Description', minLength: 5, maxLength: 1000)) !=
        null) {
      _showSnackBar(err);
      return;
    }

    // Check there are workouts selected
    if (_workoutsInWeeklyOrder.length == 0) {
      _showSnackBar('Select at least 1 workout for your routine.');
      return;
    }

    // Check there is an image uploaded
    if (_selectedImages.length == 0) {
      _showSnackBar('Upload an image for your workout.');
      return;
    }

    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      setState(() {
        _savingForm = true;
      });
      _createRoutine();
    }
  }

  void _showSnackBar(String content) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(content),
    ));
  }

  void _createRoutine() async {
    final store = StoreProvider.of<MoxieAppState>(context);
    final currentUser = await FirebaseAuth.instance.currentUser();

    PostJsonSerializer postSerializer = PostJsonSerializer();
    Post post = Post()..content = _descriptionController.value.text;
    Map postMap = await post.store(serializer: postSerializer);
    post = postSerializer.fromMap(postMap);

    final StorageReference routinesRef = FirebaseStorage.instance
        .ref()
        .child('routines')
        .child('post-${post.id}');
    post.media = await Utils.UploadImages(
        reference: routinesRef, files: _selectedImages);
    await post.update(post.id, postSerializer);

    // Set routine_id in backend
    List<WorkoutRoutine> wrs = <WorkoutRoutine>[];
    _workoutsInWeeklyOrder.forEach((week, weekWorkouts) {
      final weekWrs = <WorkoutRoutine>[];
      for (num i = 0; i < weekWorkouts.length; i++) {
        weekWrs.add(WorkoutRoutine.createRoutinePage(
            workout_id: weekWorkouts[i].id,
            week: week - 1, // Offset 1, to start at index 0
            pos: i));
      }
      wrs.addAll(weekWrs);
    });

    newRoutine
      ..name = _nameController.value.text
      ..moxieuser_id = currentUser.uid
      ..goal_id = _selectedGoal.id
      ..post_id = post.id
      ..price = _price ?? 0.0
      ..is_public = _isPublic
      ..routine_workouts = wrs;

    store.dispatch(SaveAction<Routine>(
        item: newRoutine,
        type: EModelTypes.routine,
        onSavedCallback: (routineAdded) {
          if (routineAdded != null) {
            setState(() {
              _savingForm = false;
            });

            Navigator.of(context).pop();
          }
        }));
  }
}

class CreateRoutineRequiredData {
  final List<LookupOption> goalOptions;

  CreateRoutineRequiredData({this.goalOptions});

  static CreateRoutineRequiredData from(Store<MoxieAppState> store) {
    return CreateRoutineRequiredData(
        goalOptions: store.state.goalsLookupOptions ?? <LookupOption>[]);
  }
}
