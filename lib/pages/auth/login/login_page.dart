import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:moxie_fitness/components/custom_user_details_form.dart';
import 'package:moxie_fitness/components/cutom_login_form.dart';
import 'package:moxie_fitness/components/cutom_registration_form.dart';
import 'package:moxie_fitness/components/moxie_flat_button.dart';
import 'package:moxie_fitness/components/moxie_round_button.dart';
import 'package:moxie_fitness/config/routes.dart';
import 'package:moxie_fitness/data_layer/repository/moxie_repository.dart';
import 'package:moxie_fitness/models/models.dart';

enum FormType { REGISTRATION, LOGIN, USER_DETAILS }

class LoginPage extends StatefulWidget {
  final String title;

  LoginPage({
    Key key,
    this.title,
  }) : super(key: key);

  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final facebookLogin = new FacebookLogin();
  final GoogleSignIn _googleSignIn = new GoogleSignIn(
    scopes: [
      'email',
    ],
  );

  FormType _customFormType = FormType.LOGIN;
  FirebaseUser user;
  Moxieuser _moxieuser;
  bool _submitting = false;

  Future<FirebaseUser> _handleFacebookSignIn() async {
     setState(() {
      _submitting = true;
    });
    var result = await facebookLogin.logInWithReadPermissions(['email']);
    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        var accessToken = result.accessToken;
        final AuthCredential credential = FacebookAuthProvider.getCredential(
          accessToken: accessToken.token,
        );

        user = await FirebaseAuth.instance.signInWithCredential(credential);
        break;
      case FacebookLoginStatus.cancelledByUser:
        break;
      case FacebookLoginStatus.error:
        break;
    }

    updateSignIn();
    return user;
  }

  Future<FirebaseUser> _handleGoogleSignIn() async {
    setState(() {
      _submitting = true;
    });
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    user = await _auth.signInWithCredential(credential);
    updateSignIn();
    return user;
  }

  void updateSignIn([user = null]) async {
     setState(() {
      _submitting = false;
    });
    if (user != null) {
      // callback from CustomLoginForm
      this.user = user;
    }

    final moxieuser = await moxieRepository.loadMoxieuser();
    if (moxieuser != null) {
      // Check that [Moxieuser] has at least ONE recorded [Height] & [Weight]
      if (moxieuser.needsRegistrationDetails()) {
        setState(() {
          this._customFormType = FormType.USER_DETAILS;
          this._moxieuser = moxieuser;
        });
      } else {
        // User has already entered details before
        Routes.router
            .navigateTo(context, Routes.home, replace: true, clearStack: true);
      }
    } else {
      // Error?
      // TODO
    }
  }

  Widget _getHeader() {
    return new Image(
      image: new AssetImage("assets/logo.png"),
      height: 100.0,
    );
  }

  Widget _getBody() {
    if (_customFormType == FormType.LOGIN) {
      return new CustomLoginForm(postLogin: (user) => updateSignIn(user));
    } else if (_customFormType == FormType.REGISTRATION) {
      return new CustomRegistrationForm();
    } else {
      return new CustomUserDetailsForm(
          moxieuser: this._moxieuser,
          defaultUsername: user.displayName.replaceAll(' ', ''),
          email: user.email,
          defaultImage: user.photoUrl);
    }
  }

  Widget getFooter() {
    if (_customFormType == FormType.LOGIN) {
      return new Column(
        children: <Widget>[
          new MoxieFlatButton(
            data: "Don't have an account? Sign Up",
            onPressed: () {
              setState(() {
                _customFormType = FormType.REGISTRATION;
              });
            },
          ),
          new Padding(
            padding: const EdgeInsetsDirectional.only(top: 10.0, bottom: 10.0),
            child: new Text("or connect with"),
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              new MoxieRoundButton(
                data: "Facebook",
                onTap: _handleFacebookSignIn,
                height: 40.0,
                width: 140.0,
                image: new Image(
                  image: new AssetImage("assets/facebook.png"),
                  height: 20.0,
                  color: Colors.white,
                ),
                color: new Color.fromRGBO(66, 103, 178, 1.0),
                textColor: Colors.grey,
              ),
              new MoxieRoundButton(
                data: "Google",
                onTap: _handleGoogleSignIn,
                height: 40.0,
                width: 140.0,
                image: new Image(
                  image: new AssetImage("assets/google.png"),
                  height: 20.0,
                ),
                color: Colors.white,
                textColor: Colors.grey,
              ),
            ],
          ),
        ],
      );
    } else if (_customFormType == FormType.REGISTRATION) {
      return new MoxieFlatButton(
          data: "Already have an account? Sign In",
          onPressed: () {
            setState(() {
              _customFormType = FormType.LOGIN;
            });
          });
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8),
        body: new SafeArea(
            child: new SingleChildScrollView(
          child: Stack(
            children: <Widget>[
              new Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[_getHeader(), _getBody(), getFooter()],
              ),
              _submitting ? Center(child: CircularProgressIndicator()) : Container()
            ],
          ),
        )));
  }
}
