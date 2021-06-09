import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:moxie_fitness/components/components.dart';
import 'package:moxie_fitness/config/routes.dart';
import 'package:moxie_fitness/data_layer/actions/all_actions.dart';
import 'package:moxie_fitness/data_layer/app/moxie_app_state.dart';
import 'package:moxie_fitness/models/models.dart';
import 'package:moxie_fitness/utils/utils.dart';

class PostListItem extends StatefulWidget {
  final Post post;

  PostListItem({
    @required this.post,
  });

  @override
  PostListItemState createState() {
    return PostListItemState();
  }
}

class PostListItemState extends State<PostListItem> {
  bool _alreadyLiked = false;
  bool _alreadyCommented = false;

  PostListItemState();

  @override
  Widget build(BuildContext context) {
    final store = StoreProvider.of<MoxieAppState>(context);
    _alreadyLiked = widget.post.ratings.any((Rating r) =>
        r.moxieuser_id == store.state.moxieuser?.id && r.value > 0);
    _alreadyCommented = widget.post.comments
        .any((Comment c) => c.moxieuserId == store.state.moxieuser?.id);

    final ratingIcon = IconButton(
        icon: Icon(
          Icons.fitness_center,
          color: _getRatedColor(context, _alreadyLiked),
        ),
        onPressed: _onPressedRating);
    final ratingCounter = Text(
      '${widget.post.getLikes()}',
      style: TextStyle(
        color: _getRatedColor(context, _alreadyLiked),
      ),
    );

    final commentsIcon = IconButton(
        icon: Icon(
          Icons.insert_comment,
          color: _getRatedColor(context, _alreadyCommented),
        ),
        onPressed: () =>
            Routes.router.navigateTo(context, '/posts/${widget.post.id}'));

    final commentsText = Text(
      '${widget.post?.comments?.length ?? 0}',
      style: TextStyle(
        color: _getRatedColor(context, _alreadyCommented),
      ),
    );

    final showSideFooter = (widget.post?.media?.length ?? -1) > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      child: Card(
        elevation: 4.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            buildHeader(),
            buildTextContent(),
            showSideFooter
                ? buildMediaContent(context, ratingIcon, ratingCounter,
                    commentsIcon, commentsText)
                : Container(),
            !showSideFooter
                ? _buildFooter(context, ratingIcon, ratingCounter, commentsIcon)
                : Container()
          ],
        ),
      ),
    );
  }

  Row buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Column(children: <Widget>[
          Avatar(
            forCurrentUser: false,
            withUsername: true,
            user: widget.post.moxieuser,
          )
        ]),
        Expanded(child: Container()),
        // IconButton(icon: Icon(Icons.more_vert), onPressed: null)
      ],
    );
  }

  Widget buildTextContent() {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                      margin: const EdgeInsets.only(
                          left: 20.0, right: 20.0, top: 5.0, bottom: 5.0),
                      child: Text(
                        widget.post.content,
                        softWrap: true,
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                      ))
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildMediaContent(ctx, IconButton ratingIcon, Text ratingCounter,
      IconButton commentsIcon, Text commentsText) {
    final List media = carouselWidgetsFromUrls(widget.post?.media ?? []);
    if (media == null || media.isEmpty) {
      return Container();
    } else {
      return Stack(
        children: <Widget>[
          MoxieCarouselListItem(
            carouselWidgets: media,
            height: 300.0,
            dotColor: Colors.white,
          ),
          _buildSideFooter(
              context, ratingIcon, ratingCounter, commentsIcon, commentsText)
        ],
      );
    }
  }

  Widget _buildSideFooter(context, IconButton ratingIcon, Text ratingCounter,
      IconButton commentsIcon, Text commentsText) {
    return Container(
      height: 300.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Utils.addClick(
              widget:
                  buildPostLikeOrComment(context, ratingIcon, ratingCounter),
              param: _onPressedRating),
          Expanded(child: Container()),
          Utils.addClick(
              widget:
                  buildPostLikeOrComment(context, commentsIcon, commentsText),
              param: () =>
                  Routes.router.navigateTo(context, '/posts/${widget.post.id}'))
        ],
      ),
    );
  }

  _onPressedRating() {
    final store = StoreProvider.of<MoxieAppState>(context);
    var rating = widget.post.ratings?.firstWhere(
        (Rating r) => r.moxieuser_id == store.state.moxieuser.id,
        orElse: () => null);
    if (_alreadyLiked && rating != null) {
      rating.value = -1;
      rating.ratable = 'post';
    } else if (!_alreadyLiked && rating != null) {
      rating
        ..value = 1
        ..moxieuser_id = store.state.moxieuser.id
        ..ratable = 'post'
        ..ratable_id = widget.post.id;
    } else if (!_alreadyLiked && rating == null) {
      rating = Rating()
        ..value = 1
        ..moxieuser_id = store.state.moxieuser.id
        ..ratable = 'post'
        ..ratable_id = widget.post.id;
      setState(() {
        widget.post.ratings.add(
            rating); // Only needed when rating is null, as it is not in list so not tracked in memory.
      });
    } else {
      Utils.showBasicErrorSnackBar(context);
    }

    setState(() {
      _alreadyLiked = rating.value > 0;
    });

    store.dispatch(SaveAction<Rating>(
        item: rating,
        type: EModelTypes.rating,
        onSavedCallback: (rating) {
          if (rating != null) {
          } else {
            Utils.showBasicErrorSnackBar(context);
          }
        }));
  }

  static buildPostLikeOrComment(context, icon, text) {
    return Container(
      height: 75.0,
      width: 50.0,
      margin: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(
          color: Theme.of(context).hintColor.withOpacity(0.5),
          borderRadius: BorderRadius.all(Radius.circular(5.0))),
      child: Column(
        children: <Widget>[
          icon,
          text,
        ],
      ),
    );
  }

  Widget _buildFooter(context, IconButton ratingIcon, Text ratingCounter,
      IconButton commentsIcon) {
    return new Padding(
        padding: const EdgeInsets.all(5.0),
        child: new Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: ratingCounter,
            ),
            ratingIcon,
            Expanded(child: new Container()),
            commentsIcon,
            MoxieFlatButton(
                data: '${widget.post?.comments?.length ?? 0} comments',
                textColor: Theme.of(context).textTheme.title.color,
                onPressed: () => Routes.router
                    .navigateTo(context, '/posts/${widget.post.id}'))
          ],
        ));
  }

  _getRatedColor(BuildContext context, bool already) {
    return already ? Theme.of(context).primaryColor : Colors.black87;
  }
}
