import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:moxie_fitness/components/components.dart';
import 'package:moxie_fitness/components/custom_user_details_form.dart';
import 'package:moxie_fitness/config/routes.dart';
import 'package:moxie_fitness/data_layer/actions/all_actions.dart';
import 'package:moxie_fitness/data_layer/app/moxie_app_state.dart';
import 'package:moxie_fitness/models/models.dart';
import 'package:redux/redux.dart';

class UserProfileEditPage extends StatefulWidget {

  final otherMoxieuserId;

  UserProfileEditPage({this.otherMoxieuserId});

  @override
  UserProfileEditPageState createState () => UserProfileEditPageState();
}

class UserProfileEditPageState extends State<UserProfileEditPage> {

  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
    ],
  );

  ScrollController _scrollController;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<MoxieAppState, _UserProfilePageViewModel>(
      converter: (Store<MoxieAppState> store){
        return _UserProfilePageViewModel.from(widget.otherMoxieuserId, store);
      },
      builder: (context, _UserProfilePageViewModel vm) {
        final bodyWidgets = _buildBodyWidgets(vm);
        return Scaffold(
          backgroundColor: Theme.of(context).primaryColor,
          body: Container(
            margin: const EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
            child: Container(
              margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
              child: CustomScrollView(
                controller: _scrollController,
                slivers: <Widget>[
                  _buildSliverAppbar(vm),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, index) {
                        return bodyWidgets[index];
                      },
                      childCount: bodyWidgets.length
                    ),
                  ),
                ]
              ),
            ),
          ),
        );
      }
    );
  }

  _buildBodyWidgets(_UserProfilePageViewModel vm) {
    vm.moxieuser.media[0] = vm.moxieuser.media[0];

    if(vm.moxieuser.media[0].startsWith('https://graph.facebook.com/')) {
      vm.moxieuser.media[0] += '?height=200&width=200';
    }

    final widgets = <Widget>[
      Card(
        elevation: 1.0,
        child: MoxieCarouselListItem(
          carouselWidgets: carouselWidgetsFromUrls(vm.moxieuser.media),
          height: 300.0,
          dotColor: Colors.white,
        ),
      ),
      CustomUserDetailsForm(
        moxieuser: vm.moxieuser,
        initialRegistration: false,
      ),
      Center(
        child: MoxieRoundButton(data: 'Sign Out', width: 150, height: 50, onTap: () async {
          await _googleSignIn.signOut();
          await FirebaseAuth.instance.signOut();
          Routes.router.navigateTo(context, Routes.root, replace: true);
        }),
      )
    ];
    return widgets;
  }

  SliverAppBar _buildSliverAppbar(_UserProfilePageViewModel vm) {
    var appbar = SliverAppBar(
      floating: true,
      pinned: false,
      snap: true,
      backgroundColor: Theme.of(context).primaryColor,
      leading: IconButton(icon: Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: CustomText.qarmicSans(
          text: 'Profile',
          color: Colors.white,
        ),
      ),
    );
    return appbar;
  }
}

class _UserProfilePageViewModel {
  Moxieuser moxieuser;

  _UserProfilePageViewModel({
    this.moxieuser
  });

  factory _UserProfilePageViewModel.from(String otherMoxieuserId, Store<MoxieAppState> store) {

    if(otherMoxieuserId != null) {
      if(store.state.moxieuser == null)
        store.dispatch(LoadMoxieuserAction());

      return _UserProfilePageViewModel(
        moxieuser: store.state.moxieuser
      );
    } else {
      return _UserProfilePageViewModel(
        moxieuser: null
      );
    }
  }

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
      other is _UserProfilePageViewModel &&
        runtimeType == other.runtimeType &&
        moxieuser == other.moxieuser;

  @override
  int get hashCode =>
    moxieuser.hashCode;
}

