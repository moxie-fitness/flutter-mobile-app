import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moxie_fitness/config/routes.dart';
import 'package:moxie_fitness/data_layer/repository/moxie_repository.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SplashPage extends StatefulWidget {
  SplashPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  SplashPageState createState() => new SplashPageState();
}

class SplashPageState extends State<SplashPage> {
  BuildContext _context;
  var user;

  @override
  void initState() {
    super.initState();

    // Check if user is already signed on Init
    FirebaseAuth.instance.currentUser().then((FirebaseUser user) async {
      var moxieuser;
      try {
        moxieuser = await moxieRepository.loadMoxieuser();
      } catch (e) {
        moxieuser = null;
      }

      // User is already authenticated
      if (user != null && moxieuser != null) {
        if (moxieuser.needsRegistrationDetails()) {
          goToLoginPage(_context);
        } else {
          Routes.router.navigateTo(context, Routes.home, replace: true);
        }
      } else {
        goToLoginPage(_context);
      }
    }, onError: (error) {
      goToLoginPage(_context);
    }).catchError((error) {
      print(error.toString());
    }); // Not signed in
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return new Scaffold(
      body: new Container(
        color: Colors.red,
        padding: new EdgeInsets.all(40.0),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SpinKitThreeBounce(color: Colors.white),
          ],
        ),
      ),
    );
  }

  void goToLoginPage(BuildContext ctx) {
    Routes.router.navigateTo(ctx, Routes.login, replace: true);
  }
}
