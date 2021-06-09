import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:moxie_fitness/components/components.dart';
import 'package:moxie_fitness/config/routes.dart';
import 'package:moxie_fitness/data_layer/actions/actions.dart';
import 'package:moxie_fitness/data_layer/app/moxie_app_state.dart';
import 'package:moxie_fitness/models/models.dart';
import 'package:moxie_fitness/utils/utils.dart';

class CustomUserDetailsForm extends StatefulWidget {
  final Moxieuser moxieuser;
  final defaultUsername;
  final email;
  final defaultImage;
  final initialRegistration;

  CustomUserDetailsForm(
      {@required this.moxieuser,
      this.defaultUsername,
      this.email,
      this.defaultImage,
      this.initialRegistration = true});

  @override
  _CustomUserDetailsFormState createState() =>
      new _CustomUserDetailsFormState();
}

class _CustomUserDetailsFormState extends State<CustomUserDetailsForm> {
  final formKey = new GlobalKey<FormState>();
  final _usernameTextEditingController = new TextEditingController();
  final _emailTextEditingController = new TextEditingController();

  double _weight = 100.0;
  int _heightInteger = 5;
  int _heightFractional = 0;
  double _height = 5.0;
  bool _gender = false; // true => male
  bool _measurement = false; // true => metric
  bool _saving = false;

  @override
  void dispose() {
    _usernameTextEditingController.dispose();
    _emailTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Initially set FirebaseUser Default username
    if (_usernameTextEditingController.text.isEmpty &&
        widget.initialRegistration) {
      _usernameTextEditingController.text = widget.defaultUsername;
    } else if (_usernameTextEditingController.text.isEmpty &&
        !widget.initialRegistration) {
      _usernameTextEditingController.text = widget.moxieuser.username;
      _emailTextEditingController.text = widget.moxieuser.email;
      _height = widget.moxieuser.heights.last.value.toDouble();
      _weight = widget.moxieuser.weights.last.value.toDouble();
      _gender = widget.moxieuser.gender;
      _measurement = widget.moxieuser.unit;
    }

    return new Container(
      margin: new EdgeInsets.symmetric(horizontal: 20.0),
      child: new Form(
          key: formKey,
          child: new Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              new Container(
                margin: new EdgeInsets.symmetric(vertical: 5.0),
                child: new MoxieInputFieldArea(
                    hint: "Username",
                    icon: Icons.person,
                    textInputType: TextInputType.text,
                    textEditingController: _usernameTextEditingController,
                    validator: (val) => Utils.usernameValidator(val)),
              ),
              new Container(
                margin: new EdgeInsets.symmetric(vertical: 5.0),
                child: new MoxieInputFieldArea(
                    hint: "Email",
                    icon: Icons.person,
                    textInputType: TextInputType.text,
                    textEditingController: _emailTextEditingController,
                    validator: (val) => Utils.emailValidator(val)),
              ),
              new Container(
                margin: new EdgeInsets.symmetric(vertical: 5.0),
                child: new MoxieNumberPicker(
                  hint: 'I weigh $_weight ${_measurement ? 'kg' : 'lbs'}',
                  title: 'Weight in ${_measurement ? 'kg' : 'lbs'}',
                  onUpdated: (val) {
                    if (val != null)
                      setState(() {
                        _weight = val;
                      });
                  },
                  current: _weight,
                  min: 25,
                  max: 1000,
                  icon: Icons.line_weight,
                  decimalPlaces: 1,
                ),
              ),
              new Container(
                margin: new EdgeInsets.symmetric(vertical: 5.0),
                child: new MoxieNumberPicker(
                  hint:
                      'I\'m $_heightInteger ${_measurement ? 'm' : 'ft'} and $_heightFractional ${_measurement ? 'cm' : 'in'}',
                  title:
                      'Height in ${_measurement ? 'meters, cm' : 'feet, in'}',
                  onUpdated: (double val) {
                    if (val != null)
                      setState(() {
                        _height = val;
                        _heightInteger = val.toInt();
                        num decimal = (val - _heightInteger);
                        _heightFractional = (decimal * 11).toInt();
                      });
                  },
                  current: _height,
                  min: 0,
                  decimalPlaces: 1,
                  max: _measurement ? 2 : 8,
                  icon: Icons.format_line_spacing,
                ),
              ),
              new MoxieSwitchInput(
                  value: _gender,
                  title: new InputDecorator(
                    decoration: new InputDecoration(
                      icon: new Icon(
                        Icons.perm_identity,
                        color: Colors.white,
                      ),
                      border: InputBorder.none,
                      hintStyle:
                          const TextStyle(color: Colors.white, fontSize: 15.0),
                      contentPadding: const EdgeInsets.only(
                          top: 5.0, right: 5.0, bottom: 5.0, left: 5.0),
                    ),
                    child: new Text(
                      'I\'m a ${_gender ? 'male' : 'female'}',
                      style:
                          const TextStyle(color: Colors.white, fontSize: 15.0),
                    ),
                  ),
                  onChanged: (gender) {
                    if (gender != null)
                      setState(() {
                        _gender = gender;
                      });
                  }),
              new MoxieSwitchInput(
                  value: _measurement,
                  title: new InputDecorator(
                    decoration: new InputDecoration(
                      icon: new Icon(
                        Icons.mode_edit,
                        color: Colors.white,
                      ),
                      border: InputBorder.none,
                      hintStyle:
                          const TextStyle(color: Colors.white, fontSize: 15.0),
                      contentPadding: const EdgeInsets.only(
                          top: 5.0, right: 5.0, bottom: 5.0, left: 5.0),
                    ),
                    child: new Text(
                      'I use ${_measurement ? 'cm, meters (metric)' : 'inches, feett (imperial)'}',
                      style:
                          const TextStyle(color: Colors.white, fontSize: 15.0),
                    ),
                  ),
                  onChanged: (metric) {
                    if (metric != null)
                      setState(() {
                        if (!metric) {
                          _height = 5.0;
                          _heightInteger = 5;
                          _heightFractional = 0;
                        } else {
                          _height = 1.0;
                          _heightInteger = 1;
                          _heightFractional = 0;
                        }
                        _measurement = metric;
                      });
                  }),
              new Container(
                margin: const EdgeInsets.symmetric(vertical: 20.0),
                child: new MoxieRoundButton(
                  data:
                      "${widget.initialRegistration ? "I'm Done!" : "Update Profile"}",
                  onTap: _submitForm,
                  height: 60.0,
                  color: const Color.fromRGBO(1, 211, 246, 1.0),
                ),
              ),
            ],
          )),
    );
  }

  void _submitForm() {
    if (!_saving) {
      Weight weight = new Weight()..value = _weight;
      Height height = new Height()..value = _height;

      widget.moxieuser.unit = _measurement;
      widget.moxieuser.gender = _gender;

      if (widget.moxieuser.heights == null)
        widget.moxieuser.heights = <Height>[];
      if (widget.moxieuser.weights == null)
        widget.moxieuser.weights = <Weight>[];

      widget.moxieuser.weights.add(weight);
      widget.moxieuser.heights.add(height);
      widget.moxieuser.username = _usernameTextEditingController.text;

      if (widget.initialRegistration) {
        widget.moxieuser.email = widget.email;

        if (widget.defaultImage != null && widget.defaultImage.length > 0)
          widget.moxieuser.media = [widget.defaultImage];
        else
          widget.moxieuser.media = [
            'https://cdn.pixabay.com/photo/2016/03/31/19/58/avatar-1295429_960_720.png'
          ]; // default penguin image
      } else {
        // TODO: Add/remove images.

      }

      StoreProvider.of<MoxieAppState>(context)
          .dispatch(new SaveMoxieuserDetailsAction(
              moxieuser: widget.moxieuser,
              onSavedCallback: (Null) {
                setState(() {
                  _saving = false;
                });
                StoreProvider.of<MoxieAppState>(context)
                    .dispatch(LoadMoxieuserAction());

                Routes.router.navigateTo(context, Routes.home,
                    replace: true, clearStack: true);
              }));
    } else {
      setState(() {
        _saving = true;
      });
    }
  }
}
