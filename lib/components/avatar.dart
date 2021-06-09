import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:moxie_fitness/config/routes.dart';
import 'package:moxie_fitness/models/models.dart';

class Avatar extends StatefulWidget {
  Avatar({
    Key key,
    this.onPressed,
    this.user,
    this.forCurrentUser = true,
    this.withUsername = false,
  });

  final VoidCallback onPressed;
  final Moxieuser user;
  final bool forCurrentUser;
  final bool withUsername;

  @override
  _AvatarState createState() => _AvatarState();
}

class _AvatarState extends State<Avatar> {
  String imageUrl =
      'https://cdn.pixabay.com/photo/2016/03/31/19/58/avatar-1295429_960_720.png';
  String username = 'Username';

  @override
  void initState() {
    super.initState();

    if (widget.forCurrentUser) {
      FirebaseAuth.instance.currentUser().then((FirebaseUser user) {
        setState(() {
          this.imageUrl = user?.photoUrl ?? this.imageUrl;
          this.username = user?.displayName ?? this.username;
        });
      }, onError: (error) {});
    } else {
      this.imageUrl = ((widget.user?.media?.length ?? 0) > 0)
          ? widget.user.media[0]
          : this.imageUrl;
      this.username = widget.user?.username ?? this.username;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[buildAvatar(), buildUsername()],
    );
  }

  Widget buildUsername() {
    return widget.withUsername
        ? Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Text(
              '${this.username ?? ''}',
              textAlign: TextAlign.start,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        : Container();
  }

  Widget buildAvatar() {
    return Container(
        height: 50.0,
        width: 50.0,
        padding: EdgeInsets.all(5.0),
        child: Center(
          child: RawMaterialButton(
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                placeholder: (context, url) => Center(
                  child: Container(
                    height: 75.0,
                    width: 75.0,
                    child: CircularProgressIndicator(),
                  ),
                ),
                fit: BoxFit.cover,
              ),
            ),
            onPressed: widget.onPressed ??
                () {
                  if (widget.forCurrentUser) {
                    Routes.router.navigateTo(context, '/user');
                  } else {
                    Routes.router.navigateTo(context, '/users/${widget.user.id}');
                  }
                },
          ),
        ));
  }
}
