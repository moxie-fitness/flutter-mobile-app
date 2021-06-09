import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:moxie_fitness/components/components.dart';
import 'package:moxie_fitness/data_layer/actions/all_actions.dart';
import 'package:moxie_fitness/data_layer/app/moxie_app_state.dart';
import 'package:moxie_fitness/models/models.dart';
import 'package:moxie_fitness/utils/utils.dart';
import 'package:redux/redux.dart';

class PostPage extends StatefulWidget {
  final num id;
  final bool edit;

  PostPage(
    this.id,
    {
      this.edit = false
    }
  );

  @override
  PostPageState createState () => new PostPageState();
}

class PostPageState extends State<PostPage> {
  ScrollController _scrollController;
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  static const double _bottomInputSize = 70.0;
  TextEditingController _commentController = TextEditingController();
  bool _commentHasValue = false;

  PostPageState(){
    _commentController.addListener(() {
      setState(() {
        _commentHasValue = (_commentController.value?.text?.length ?? 0) > 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new StoreConnector<MoxieAppState, _PostPageViewModel>(
      converter: (Store<MoxieAppState> store){
        return new _PostPageViewModel.from(store, widget.id);
      },
      builder: (context, vm) {
        return Scaffold(
          key: _scaffoldKey,
          body:
          SafeArea(
            top: false,
            bottom: false,
            child: Stack(
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(bottom: _bottomInputSize),
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: <Widget>[
                      SliverAppBar(
                        backgroundColor: Colors.white,
                        floating: true,
                        pinned: false,
                        snap: true,
                        leading: IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.black),
                          onPressed: () => Navigator.pop(context)),
                        flexibleSpace: FlexibleSpaceBar(
                          centerTitle: true,
                          title: CustomText.qarmicSans(
                            text: '${vm.feed?.moxieuser?.username}\'s post',
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, index) {
                            if(index == 0) {
                              if(vm.feed.post.comments.length == 0) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Center(child: CustomText.qarmicSans(text: 'Be the first to comment!', color: Colors.black87,))
                                );
                              } else {
                                return Container();
                              }
                            } else {
                              return CommentListItem(
                                comment: vm.feed.post?.comments[index-1],
                              );
                            }
                          },
                          childCount: (vm.feed.post.comments?.length ?? 0) + 1,
                        )
                      ),
                    ]
                  ),
                ),
                _buildPostInput(vm)
              ],
            )
          )
        );
      }
    );
  }

  _buildPostInput(_PostPageViewModel vm) {
    return Positioned(
      bottom: 0.0,
      right: 0.0,
      left: 0.0,
      child: Container(
        height: _bottomInputSize,
        child: Container(
          color: Colors.white70,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: TextFormField(
                    maxLength: 1000,
                    controller: _commentController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Send a comment..',
                      hintStyle: TextStyle(
                        color: Theme.of(context).disabledColor,
                        fontStyle: FontStyle.italic,
                      )
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                color: _commentHasValue
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).disabledColor,
                onPressed: () => _commentHasValue ? _insertComment(vm) : (){},
              )
            ]
          ),
        ),
      ),
    );
  }

  void _insertComment(_PostPageViewModel vm) {
    if(!(_commentController.value.text.length > 0)) return;

    final store = StoreProvider.of<MoxieAppState>(context);

    Comment comment = Comment()
      ..content = _commentController.value.text
      ..media = <String>[] // todo
      .. postId = vm.feed.post_id
      ..post = vm.feed.post
      ..moxieuser = store.state.moxieuser
      ..moxieuserId = store.state.moxieuser.id;

    _commentController.clear();

    store.dispatch(
      SaveAction<Comment>(
        item: comment,
        type: EModelTypes.comment,
        onSavedCallback: (comment) {
          if(comment != null) {
          } else {
            Utils.showBasicErrorSnackBar(context);
          }
        }
      )
    );

  }
}


class _PostPageViewModel {
  Feed feed;

  _PostPageViewModel({
    this.feed,
  });

  factory _PostPageViewModel.from(Store<MoxieAppState> store, int id) {
    final feeds = store.state?.feedsState?.feeds?.values?.toList();
    final feed = feeds?.firstWhere((Feed feed) => feed.post.id == id);
    return new _PostPageViewModel(
      feed: feed,
    );
  }

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
      other is _PostPageViewModel &&
        runtimeType == other.runtimeType &&
          feed == other.feed;

  @override
  int get hashCode =>
      feed.hashCode;
}
