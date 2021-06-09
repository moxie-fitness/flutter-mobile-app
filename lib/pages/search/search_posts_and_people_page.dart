import 'package:flutter/material.dart';
import 'package:moxie_fitness/components/app_bar_search_field.dart';

class SearchPostsAndPeoplePage extends StatefulWidget {

  @override
  _SearchPostsAndPeoplePageState createState () => new _SearchPostsAndPeoplePageState();
}

class _SearchPostsAndPeoplePageState extends State<SearchPostsAndPeoplePage> {

  final TextEditingController _searchEditingController = new TextEditingController();

  @override
  void initState() {
    super.initState();
  }


  @override
  void dispose() {
    _searchEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new AppBarSearchField(
          hint: "Looking for something?",
          textEditingController: _searchEditingController,
        ),
        centerTitle: true,
      ),
      body: new Text('Todo (at the end): Crete an Elastic Search with Indexing to quickly filter through People & Posts.'),
    );
  }
}