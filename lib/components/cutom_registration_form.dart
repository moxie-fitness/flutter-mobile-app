import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:meta/meta.dart';
import 'package:moxie_fitness/components/moxie_input_field.dart';
import 'package:moxie_fitness/components/moxie_round_button.dart';
import 'package:moxie_fitness/utils/utils.dart';

class CustomRegistrationForm extends StatefulWidget {
  @override
  _CustomRegistrationFormState createState() =>
      new _CustomRegistrationFormState();
}

class _CustomRegistrationFormState extends State<CustomRegistrationForm> {
  final formKey = new GlobalKey<FormState>();
  final emailTextEditingController = new TextEditingController();
  final userTextEditingController = new TextEditingController();
  final passwordTextEditingController = new TextEditingController();
  final passwordVerificationTextEditingController = new TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _submitForm() {
    if (passwordTextEditingController.text !=
        passwordVerificationTextEditingController.text) {
      Scaffold.of(context).showSnackBar(
          new SnackBar(content: new Text("Passwords do not match")));
      return;
    }

    final form = formKey.currentState;
    if (form.validate()) {
      form.save();

      _performRegistration();
    }
  }

  Future _performRegistration() async {
    // Sets focus on a focusNode which results in hiding the keyboard
    FocusScope.of(context).requestFocus(new FocusNode());

    Scaffold.of(context).showSnackBar(new SnackBar(
      content: new Row(
        children: <Widget>[
          new CircularProgressIndicator(),
          new Text("    Signing in...")
        ],
      ),
    ));

    try {
      FirebaseUser user = await _auth.createUserWithEmailAndPassword(
          email: emailTextEditingController.text,
          password: passwordTextEditingController.text);

      if (user != null) {
        await _updateUsername();
        await _sendVerificationEmail();
      } else {
        throw new Error();
      }
    } catch (err) {
      var providers = await _auth.fetchSignInMethodsForEmail(
          email: emailTextEditingController.text);
      if (providers.length > 0)
        Scaffold.of(context).showSnackBar(new SnackBar(
            content: new Text("Account for this email already exists")));
      else
        Scaffold.of(context).showSnackBar(
            new SnackBar(content: new Text("Unexpected error ocurred.")));
    }
  }

  Future<Null> _updateUsername() async {
    try {
      UserUpdateInfo userUpdateInfo = new UserUpdateInfo()
        ..displayName = userTextEditingController.text;
      await (await _auth.currentUser()).updateProfile(userUpdateInfo);
    } catch (err) {
      Scaffold.of(context).showSnackBar(
          new SnackBar(content: new Text("Unexpected error ocurred")));
    }
  }

  Future<Null> _sendVerificationEmail() async {
    try {
      var user = await _auth.currentUser();
      await user.sendEmailVerification();
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title:
                Center(child: const Text('Success! Email verification sent!')),
            content: Text(
                'Come back & Sign In normally after verifying your email!'),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () =>
                    Navigator.of(context).pushReplacementNamed('/'),
              )
            ],
          );
        },
      );

      // If dialog is dismissed, redirect
      Navigator.of(context).pushReplacementNamed('/');
    } catch (err) {
      Scaffold.of(context).showSnackBar(
          new SnackBar(content: new Text("Unexpected error ocurred")));
    }
  }

  @override
  void dispose() {
    emailTextEditingController.dispose();
    passwordTextEditingController.dispose();
    passwordVerificationTextEditingController.dispose();
    userTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      margin: new EdgeInsets.symmetric(horizontal: 20.0),
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          new Form(
              key: formKey,
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  new MoxieInputFieldArea(
                    hint: "Username",
                    obscure: false,
                    icon: Icons.person,
                    textInputType: TextInputType.text,
                    textEditingController: userTextEditingController,
                    validator: (val) => Utils.usernameValidator(val),
                  ),
                  new MoxieInputFieldArea(
                    hint: "Email",
                    obscure: false,
                    icon: Icons.email,
                    textInputType: TextInputType.emailAddress,
                    textEditingController: emailTextEditingController,
                    validator: (val) => Utils.emailValidator(val),
                  ),
                  new MoxieInputFieldArea(
                    hint: "Password",
                    obscure: true,
                    icon: Icons.lock,
                    textInputType: TextInputType.text,
                    textEditingController: passwordTextEditingController,
                    validator: (val) => Utils.passwordValidator(val),
                  ),
                  new MoxieInputFieldArea(
                    hint: "Password Verification",
                    obscure: true,
                    icon: Icons.lock,
                    textInputType: TextInputType.text,
                    textEditingController:
                        passwordVerificationTextEditingController,
                  ),
                  new Padding(
                      padding: const EdgeInsets.only(top: 50.0),
                      child: new MoxieRoundButton(
                          height: 50.0,
                          width: 250.0,
                          data: "Sign Up",
                          onTap: _submitForm)),
                ],
              )),
        ],
      ),
    );
  }
}
