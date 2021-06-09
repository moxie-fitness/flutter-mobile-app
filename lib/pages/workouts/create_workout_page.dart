import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:moxie_fitness/components/components.dart';
import 'package:moxie_fitness/components/form_wizard/form_wizard_page.dart';
import 'package:moxie_fitness/data_layer/actions/all_actions.dart';
import 'package:moxie_fitness/data_layer/app/moxie_app_state.dart';
import 'package:moxie_fitness/models/models.dart';
import 'package:moxie_fitness/utils/utils.dart';
import 'package:redux/redux.dart';

class CreateWorkoutPage extends StatefulWidget {
  @override
  _CreateWorkoutPageState createState() => new _CreateWorkoutPageState();
}

class _CreateWorkoutPageState extends State<CreateWorkoutPage> {
  final formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final num maxNumExercises = 12;

  Workout newWorkout = new Workout();
  TextEditingController _nameController = new TextEditingController();
  TextEditingController _descriptionController = new TextEditingController();
  StreamController<CreateWorkoutExerciseUpdate> _exercisesAddController;
  List<ExerciseWorkout> _workoutExercises = new List<ExerciseWorkout>();
  List<File> _selectedImage = <File>[];
  bool _savingForm = false;

  _CreateWorkoutPageState() {
    _exercisesAddController =
        new StreamController<CreateWorkoutExerciseUpdate>();
    _exercisesAddController.stream.listen((CreateWorkoutExerciseUpdate update) {
      setState(() {
        if (update != null) {
          if (update.type == CreateWorkoutExerciseUpdateType.add) {
            if (_workoutExercises.length > maxNumExercises) {
              _showSnackBar(
                  'You can only choose up to $maxNumExercises exercises');
            } else {
              _workoutExercises.add(update.exercise);
            }
          } else if (update.type == CreateWorkoutExerciseUpdateType.order) {
            var temp = _workoutExercises.removeAt(update.onDragFinishOldIndex);
            _workoutExercises.insert(update.onDragFinishNewIndex, temp);
            print(
                'Updated exercises order via stream : ${update.onDragFinishOldIndex} > ${update.onDragFinishNewIndex}');
          } else if (update.type == CreateWorkoutExerciseUpdateType.update) {
            var index = _workoutExercises
                .indexWhere((ew) => ew.id == update.exercise.id);
            if (index >= 0) {
              _workoutExercises[index] = update.exercise;
            }
          }
        }
      });
    });
  }

  List<FormWizardPageViewModel> _getPages(CreateWorkoutRequiredData data) {
    return [
      new FormWizardPageViewModel(
        heading: 'What do you want to call your workout?',
        input: new MoxieInputFieldArea(
          hint: 'Enter name',
          textEditingController: _nameController,
          maxLines: 1,
          validator: (val) => Utils.simpleTextValidator(val,
              who: 'Name', minLength: 5, maxLength: 100),
        ),
        assetPath: 'assets/logo.png',
        color: Colors.green,
      ),
      new FormWizardPageViewModel(
        heading: 'Tell people a little bit about this workout.',
        input: new MoxieInputFieldArea(
          hint: 'Enter description',
          textEditingController: _descriptionController,
          maxLines: 5,
          maxLength: 1000,
          textInputType: TextInputType.multiline,
          validator: (val) => Utils.simpleTextValidator(val,
              who: 'Description', minLength: 5, maxLength: 1000),
        ),
        color: Colors.blue,
      ),
      new FormWizardPageViewModel(
        heading: 'Choose exercises for your workout',
        input: new ExercisesPickerOpener(
          exercises: _workoutExercises,
          backgroundColor: Colors.amber,
          exercisesAddController: _exercisesAddController,
          maxExercises: maxNumExercises,
        ),
        color: Colors.amber,
      ),
      new FormWizardPageViewModel(
        heading: 'Upload an image for your workout',
        input: new ImageSelectorOpener(
          images: _selectedImage,
          backgroundColor: Colors.purple,
          onImagesUpdated: (images) {
            setState(() {
              if (images != null) _selectedImage = images;
            });
          },
          maxImages: 1,
        ),
        color: Colors.purple,
      ),
    ];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _exercisesAddController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _scaffoldKey,
        body: new SafeArea(
          bottom: false,
          top: false,
          child: new StoreConnector<MoxieAppState, CreateWorkoutRequiredData>(
              converter: CreateWorkoutRequiredData.from,
              builder: (context, vm) {
                return renderWithData(vm);
              }),
        ));
  }

  Widget renderWithData(CreateWorkoutRequiredData data) {
    final pages = _getPages(data);
    return new SingleChildScrollView(
      child: new FormWizardPager(
        formKey: formKey,
        pages: pages,
        onAttemptFinish: _validateForm,
        saving: _savingForm,
      ),
    );
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

    // Check there is an image uploaded
    if (_selectedImage.length == 0) {
      _showSnackBar('Upload an image for your workout.');
      return;
    }

    // Check there are exercises uploaded
    if (_workoutExercises.length == 0) {
      _showSnackBar('Select at least 1 exercise for your workout.');
      return;
    }

    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      setState(() {
        _savingForm = true;
      });
      _createWorkout();
    }
  }

  Future _createWorkout() async {
    final store = StoreProvider.of<MoxieAppState>(context);
    final currentUser = await FirebaseAuth.instance.currentUser();

    final PostJsonSerializer postSerializer = new PostJsonSerializer();
    Post post = new Post()..content = _descriptionController.value.text;
    Map postMap = await post.store(serializer: postSerializer);
    post = postSerializer.fromMap(postMap);

    final StorageReference workoutsRef = FirebaseStorage.instance
        .ref()
        .child('workouts')
        .child('post-${post.id}');
    post.media =
        await Utils.UploadImages(reference: workoutsRef, files: _selectedImage);
    await post.update(post.id, postSerializer);

    newWorkout
      ..name = _nameController.value.text
      ..moxieuser_id = currentUser.uid
      ..post_id = post.id
      ..workout_exercises = _workoutExercises;

    store.dispatch(new SaveAction<Workout>(
        item: newWorkout,
        type: EModelTypes.workout,
        onSavedCallback: (workoutAdded) {
          if (workoutAdded != null) {
            setState(() {
              _savingForm = false;
            });

            Navigator.of(context).pop();
          }
        }));
  }

  void _showSnackBar(String content) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(content),
    ));
  }
}

class CreateWorkoutRequiredData {
  static CreateWorkoutRequiredData from(Store<MoxieAppState> store) {
    return new CreateWorkoutRequiredData();
  }
}
