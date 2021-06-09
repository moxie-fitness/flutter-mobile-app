import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:moxie_fitness/components/components.dart';
import 'package:moxie_fitness/data_layer/actions/all_actions.dart';
import 'package:moxie_fitness/data_layer/app/moxie_app_state.dart';
import 'package:moxie_fitness/models/models.dart';
import 'package:moxie_fitness/utils/utils.dart';

class CreatePostPage extends StatefulWidget {

  final bool postIsComment;

  CreatePostPage({
    this.postIsComment = false
  });

  @override
  _CreatePostPageState createState () => new _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _contentTextEditingController = new TextEditingController();
  final formKey = new GlobalKey<FormState>();
  List<File> _images = <File>[];
  bool _savingForm = false;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).primaryColor,
      appBar: new AppBar(
        elevation: 0.7,
        backgroundColor: Theme.of(context).primaryColor,
        title: new Text('New Post'),
        centerTitle: true,
        leading: new IconButton(
          icon: new Icon(
            Icons.close,
            color: Colors.white,
          ), onPressed: () {
          Utils.forceCloseKeyboard();
          Navigator.of(context).pop();
        }
        ),
      ),
      body: new SafeArea(
        top: false,
        bottom: false,
        child: new SingleChildScrollView(
          child: new Stack(
            children: <Widget>[
              _savingForm
                ? new Container(
                  height: 200.0,
                  child: new CenteredCircularProgress())
                : new Container(),
              new Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  new Form(
                    key: formKey,
                    child: new Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new MoxieInputFieldArea(
                        hint: 'It\'s not official until you post it!',
                        icon: Icons.chat_bubble_outline,
                        textEditingController: _contentTextEditingController,
                        height: 180.0,
                        maxLength: 1000,
                        maxLines: 5,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22.0
                        ),
                        textInputType: TextInputType.multiline,
                        validator: (val) => Utils.simpleTextValidator(val, who: 'Post Content', maxLength: 1000),
                      ),
                    ),
                  ),
                  new Container(
                    margin: const EdgeInsets.only(top: 45.0, bottom: 15.0),
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: new ImageSelectorOpener(
                      withHint: false,
                      images: _images,
                      backgroundColor: Theme.of(context).accentColor,
                      fontAndIconColors: Colors.white,
                    ),
                  ),
                  _images.length > 0
                      ? new MoxieCarouselListItem(
                    height: 150.0,
                    carouselWidgets: carouselWidgetsFromFiles(_images),
                  )
                      : new Container(
                    margin: const EdgeInsets.only(top: 100.0),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: !_savingForm ? new FloatingActionButton(
        child: new Icon(
            Icons.done
        ),
        onPressed: _validatePost,
      ) : new Container(),
    );
  }

  void _validatePost() {
    final form = formKey.currentState;
    if(form.validate() && !_savingForm) {
      form.save();
      Utils.forceCloseKeyboard();
      _submitPost();
    }
  }

  Future _submitPost() async {
    setState(() {
      _savingForm = true;
    });

    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(
        'Saving post...'
      ),
    ));

    final store = StoreProvider.of<MoxieAppState>(context);

    Post post = new Post()
      ..content = _contentTextEditingController.value.text;

    PostJsonSerializer postSerializer = new PostJsonSerializer();
    Map postMap = await post.store(serializer: postSerializer);
    post = postSerializer.fromMap(postMap);

    final StorageReference exercisesRef = FirebaseStorage.instance.ref().child('feeds').child('post-${post.id}');
    post.media = await Utils.UploadImages(reference: exercisesRef, files: _images);
    await post.update(post.id, postSerializer);

    if(!widget.postIsComment) {
      Feed feed = new Feed()
        ..moxieuser_id = store.state.moxieuser.id
        ..post = post;

      store.dispatch(new SaveAction<Feed>(
        item: feed,
        type: EModelTypes.feed,
        onSavedCallback: (feed) {
          if(feed != null) {
            Navigator.of(context).pop();
            _scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text(
                'Success!'
              ),
            ));
          } else {
            _scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text(
                'Unexpected error, try again later.'
              ),
            ));
          }
        }
      ));
    }
  }
}