import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moxie_fitness/components/moxie_input_field.dart';
import 'package:moxie_fitness/components/moxie_round_button.dart';
import 'package:moxie_fitness/components/moxie_flat_button.dart';
import 'package:moxie_fitness/utils/utils.dart';

class CustomLoginForm extends StatefulWidget {

  final Function postLogin;

  CustomLoginForm({
    this.postLogin
  });

  @override
  _CustomLoginFormState createState() => new _CustomLoginFormState();
}

class _CustomLoginFormState extends State<CustomLoginForm> {
  final formKey = new GlobalKey<FormState>();
  final emailTextEditingController = new TextEditingController();
  final passwordTextEditingController = new TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _submitForm() {
    final form = formKey.currentState;
    if(form.validate()) {
      form.save();

      _performLogin();
    }
  }

  Future _performLogin() async {
    // Sets focus on a focusNode which results in hiding the keyboard
    FocusScope.of(context).requestFocus(new FocusNode());

    Scaffold.of(context).showSnackBar(
        new SnackBar(
          content: new Row(
            children: <Widget>[
              new CircularProgressIndicator(),
              new Text("    Signing in...")
            ],
          ),
        )
    );

    try {
      FirebaseUser user = await _auth.signInWithEmailAndPassword(
          email: emailTextEditingController.text,
          password: passwordTextEditingController.text
      );

      if(user != null) {
        bool verified = user.isEmailVerified;

        if(!verified) {
          _verificationDialog();
        } else {
          widget.postLogin(user);
//          Navigator.of(context).pushReplacementNamed("/home");
        }
      } else {
        Scaffold.of(context).showSnackBar(new SnackBar(content: new Text("Unexpected error occured")));
      }
    } catch(err) {
      Scaffold.of(context).showSnackBar(new SnackBar(content: new Text("Invalid email or password")));
      print("(err) @_performLogin: " + err);
    }
  }

  Future<Null> _verificationDialog() async {
    return showDialog<Null>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text('Oops   :('),
          content: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[
                new Text('You still need to verify your Email. Please check your Email for verification or Re-send a verification email.'),
              ],
            ),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text('Re-send'),
              onPressed: () {
                _sendVerificationEmail();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _sendVerificationEmail() async {
    try {
      var user = await _auth.currentUser();
      await user.sendEmailVerification();
      Scaffold.of(context).showSnackBar(new SnackBar(content: new Text("Email verification sent")));
    } catch (err) {
      Scaffold.of(context).showSnackBar(new SnackBar(content: new Text("Unexpected error ocurred")));
    }
  }

  void _handleForgotPassword() async {
    var email = emailTextEditingController.text;
    print(email);
    if(Utils.isEmail(email)) {
      await _auth.sendPasswordResetEmail(email: email);
      Scaffold.of(context).showSnackBar(new SnackBar(content: new Text("Check your Email for Password Reset instructions")));
    } else {
      Scaffold.of(context).showSnackBar(new SnackBar(content: new Text("Please enter a valid Email first")));
    }
  }

  @override
  void dispose() {
    emailTextEditingController.dispose();
    passwordTextEditingController.dispose();
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
                  hint: "Email",
                  icon: Icons.email,
                  textInputType: TextInputType.emailAddress,
                  textEditingController: emailTextEditingController,
                  validator: (val) => Utils.emailValidator(val)
                ),
                new MoxieInputFieldArea(
                  hint: "Password",
                  obscure: true,
                  icon: Icons.lock,
                  textEditingController: passwordTextEditingController,
                  validator: (val) => Utils.passwordValidator(val)
                ),
                new Padding(
                  padding: const EdgeInsets.only(top: 50.0),
                  child: new MoxieRoundButton(
                    data: "Sign In",
                    onTap: _submitForm,
                    height: 60.0,
                    color: const Color.fromRGBO(1, 211, 246, 1.0),
                  ),
                ),
                new Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: new MoxieFlatButton(
                    data: "Forgot Password",
                    onPressed: _handleForgotPassword
                  ),
                ),
              ],
            )
          ),
        ],
      ),
    );
  }
}
