import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:moxie_fitness/components/components.dart';
import 'package:moxie_fitness/data_layer/actions/all_actions.dart';
import 'package:moxie_fitness/data_layer/app/moxie_app_state.dart';
import 'package:moxie_fitness/models/models.dart';
import 'package:moxie_fitness/utils/utils.dart';

class CommentListItem extends StatefulWidget {
  final Comment comment;

  CommentListItem({
    @required this.comment,
  });

  @override
  CommentListItemState createState() {
    return new CommentListItemState();
  }
}

class CommentListItemState extends State<CommentListItem> {
  bool _alreadyLiked = false;

  @override
  Widget build(BuildContext context) {
    final store = StoreProvider.of<MoxieAppState>(context);
    _alreadyLiked = widget.comment.ratings?.any((Rating r) =>
            r.moxieuser_id == store.state.moxieuser?.id && r.value > 0) ??
        false;

    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Card(
        margin: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            buildHeader(),
            buildTextContent(),
            buildMediaContent(context),
            buildFooter(context)
          ],
        ),
      ),
    );
  }

  Row buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Avatar(
            forCurrentUser: false,
            withUsername: true,
            user: widget.comment.moxieuser),
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
                          left: 50.0, right: 20.0, top: 5.0, bottom: 5.0),
                      child: Text(
                        widget.comment?.content ?? '',
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

  Widget buildMediaContent(ctx) {
    final List media = carouselWidgetsFromUrls(widget.comment?.media ?? []);
    if (media == null || media.isEmpty) {
      return Container();
    } else {
      return Container(
        height: 300.0,
        child: Carousel(
          dotSize: 4.0,
          widgets: media,
          autoplay: false,
          dotColor: Theme.of(ctx).primaryColor,
        ),
      );
    }
  }

  Widget buildFooter(context) {
    return Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(
          children: <Widget>[
            Expanded(child: Container()),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                '${widget.comment.getLikes()}',
                style: TextStyle(color: _getRatedColor(context, _alreadyLiked)),
              ),
            ),
            IconButton(
                icon: Icon(
                  Icons.fitness_center,
                  color: _getRatedColor(context, _alreadyLiked),
                ),
                onPressed: _onPressedRating),
          ],
        ));
  }

  _getRatedColor(BuildContext context, bool already) {
    return already ? Theme.of(context).primaryColor : Colors.black87;
  }

  _onPressedRating() {
    final store = StoreProvider.of<MoxieAppState>(context);
    var rating = widget.comment.ratings?.firstWhere(
        (Rating r) => r.moxieuser_id == store.state.moxieuser.id,
        orElse: () => null);
    if (rating == null) {
      rating = new Rating()
        ..moxieuser_id = store.state.moxieuser.id
        ..ratable_id = widget.comment.id
        ..ratable = 'comment'
        ..value = 1;
      setState(() {
        widget.comment.ratings.add(
            rating); // Only needed when rating is null, as it is not in list so not tracked in memory.
      });
    }

    if (_alreadyLiked) {
      rating.value = -1;
    } else if (!_alreadyLiked) {
      rating.value = 1;
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
}
