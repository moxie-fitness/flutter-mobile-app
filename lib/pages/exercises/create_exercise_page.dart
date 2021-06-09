import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:moxie_fitness/components/components.dart';
import 'package:moxie_fitness/data_layer/actions/all_actions.dart';
import 'package:moxie_fitness/data_layer/app/moxie_app_state.dart';
import 'package:moxie_fitness/models/models.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:moxie_fitness/utils/utils.dart';
import 'package:redux/redux.dart';

class CreateExercisePage extends StatefulWidget {
  @override
  _CreateExercisePageState createState() => new _CreateExercisePageState();
}

class _CreateExercisePageState extends State<CreateExercisePage> {
  final formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  TextEditingController _nameController = new TextEditingController();
  TextEditingController _instructionsController = new TextEditingController();
  TextEditingController _youtubeUrlController = new TextEditingController();
  StreamController<ItemSelectUpdate<LookupOption>> _multiEquipmentController;
  List<File> _selectedImages = <File>[];
  List<LookupOption> _selectedEquipment = <LookupOption>[];
  LookupOption _selectedMuscle;
  bool _savingForm = false;

  _CreateExercisePageState() {
    _multiEquipmentController =
        new StreamController<ItemSelectUpdate<LookupOption>>();
    _multiEquipmentController.stream
        .listen((ItemSelectUpdate<LookupOption> update) {
      setState(() {
        if (update.selected) {
          _selectedEquipment.add(update.item);
        } else {
          _selectedEquipment.remove(update.item);
        }
      });
    });
  }

  List<FormWizardPageViewModel> _getPages(CreateExercisesRequiredData data) {
    return [
      new FormWizardPageViewModel(
        heading: 'What do you want to call your exercise?',
        input: new MoxieInputFieldArea(
          hint: 'Enter name',
          textEditingController: _nameController,
          validator: (val) => Utils.simpleTextValidator(val,
              who: 'Name', minLength: 5, maxLength: 100),
        ),
        assetPath: 'assets/logo.png',
        color: Colors.green,
      ),
      new FormWizardPageViewModel(
        heading: 'Tell people how it\'s done.',
        input: new MoxieInputFieldArea(
          hint: 'Enter instructions',
          textEditingController: _instructionsController,
          maxLines: 5,
          maxLength: 1000,
          textInputType: TextInputType.multiline,
          validator: (val) => Utils.simpleTextValidator(val,
              who: 'Instructions', minLength: 5, maxLength: 1000),
        ),
        color: Colors.blue,
      ),
      new FormWizardPageViewModel(
        heading: 'Do you have a YouTube video URL for this exercise?',
        input: new MoxieInputFieldArea(
          hint: 'Enter YouTube URL (opt)',
          textEditingController: _youtubeUrlController,
//          validator: (val) => Utils.simpleTextvalidator(val, who: 'YouTube Url', minLength:  5, maxLength: 1024),
        ),
        assetPath: 'assets/logo.png',
        color: Colors.purple,
      ),
      new FormWizardPageViewModel(
          heading: 'What muscle group does this exercise target?',
          input: data.muscleTypeOptions.isEmpty
              ? new CenteredCircularProgress()
              : new MoxieDropdown<LookupOption>(
                  preSelected: _selectedMuscle,
                  options: data.muscleTypeOptions,
                  onChanged: (option) {
                    setState(() {
                      _selectedMuscle = option;
                    });
                  },
                  menuItemsGenerator: (LookupOption option) {
                    return new DropdownMenuItem<LookupOption>(
                      child: new Text('${option.value}'),
                      value: option,
                    );
                  },
                  color: Colors.white,
                ),
          color: Colors.amber),
      new FormWizardPageViewModel(
        heading: 'What sort of equipment or machines are required for this?',
        input: data.equipmentOrMachineOptions.isEmpty
            ? new CenteredCircularProgress()
            : new MoxieMultiSelect<LookupOption>(
                title: 'Select Equipment',
                descriptionBuilder: (LookupOption option) {
                  return option.value;
                },
                options: data.equipmentOrMachineOptions,
                preSelected: _selectedEquipment,
                color: Colors.white,
                generator: (LookupOption input) {
                  return new MoxieMultiSelectOption<LookupOption>(
                      item: input,
                      display: input.value,
                      streamController: this._multiEquipmentController);
                },
              ),
        assetPath: 'assets/logo.png',
        color: Colors.teal,
      ),
      new FormWizardPageViewModel(
        heading: 'Upload some images for your exercise!',
        input: new ImageSelectorOpener(
          images: _selectedImages,
          backgroundColor: Colors.purple,
          onImagesUpdated: (images) {
            setState(() {
              if (images != null) _selectedImages = images;
            });
          },
          maxImages: 6,
        ),
        color: Colors.purple,
      ),
    ];
  }

  @override
  void dispose() {
    _multiEquipmentController.close();
    _nameController.dispose();
    _instructionsController.dispose();
    _youtubeUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _scaffoldKey,
        body: new StoreConnector<MoxieAppState, CreateExercisesRequiredData>(
            converter: CreateExercisesRequiredData.from,
            builder: (context, vm) {
              return renderWithData(vm);
            }));
  }

  Widget renderWithData(CreateExercisesRequiredData data) {
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

    if ((err = Utils.simpleTextValidator(_instructionsController.value.text,
            who: 'Instrucions', minLength: 5, maxLength: 100)) !=
        null) {
      _showSnackBar(err);
      return;
    }

    // Check Images
    if (_selectedImages.length == 0) {
      err = 'You need at least 1 image for your exercise!';
      _showSnackBar(err);
      return;
    }

    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      setState(() {
        _savingForm = true;
      });
      _createExercise();
    }
  }

  void _createExercise() async {
    final store = StoreProvider.of<MoxieAppState>(context);
    final currentUser = await FirebaseAuth.instance.currentUser();

    PostJsonSerializer postSerializer = new PostJsonSerializer();
    Post post = new Post()..content = _instructionsController.value.text;
    Map postMap = await post.store(serializer: postSerializer);
    post = postSerializer.fromMap(postMap);

    final StorageReference exercisesRef = FirebaseStorage.instance
        .ref()
        .child('exercises')
        .child('post-${post.id}');
    post.media = await Utils.UploadImages(
        reference: exercisesRef, files: _selectedImages);
    await post.update(post.id, postSerializer);

    Exercise exercise = new Exercise()
      ..name = _nameController.value.text
      ..youtube_url = _youtubeUrlController.value.text
      ..moxieuser_id = currentUser.uid
      ..post_id = post.id
      ..equipment = _selectedEquipment
          .map((LookupOption lo) => new ExerciseEquipment()..equipment = lo)
          .toList()
      ..muscle_id = _selectedMuscle != null
          ? _selectedMuscle.id
          : store.state.muscleLookupOptions[0].id;

    store.dispatch(new SaveAction<Exercise>(
        item: exercise,
        type: EModelTypes.exercise,
        onSavedCallback: (exercise) {
          if (exercise != null) {
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

class CreateExercisesRequiredData {
  List<LookupOption> equipmentOrMachineOptions;
  List<LookupOption> muscleTypeOptions;

  CreateExercisesRequiredData(
      {this.equipmentOrMachineOptions, this.muscleTypeOptions});

  static CreateExercisesRequiredData from(Store<MoxieAppState> store) {
    return new CreateExercisesRequiredData(
      equipmentOrMachineOptions:
          store.state.equipmentLookupOptions ?? <LookupOption>[],
      muscleTypeOptions: store.state.muscleLookupOptions ?? <LookupOption>[],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateExercisesRequiredData &&
          runtimeType == other.runtimeType &&
          equipmentOrMachineOptions == other.equipmentOrMachineOptions &&
          muscleTypeOptions == other.muscleTypeOptions;

  @override
  int get hashCode =>
      equipmentOrMachineOptions.hashCode ^ muscleTypeOptions.hashCode;
}
