import 'package:flutter/material.dart';
import 'package:moxie_fitness/components/components.dart';
import 'package:moxie_fitness/pages/pages.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  HomePageState createState() => HomePageState(title);
}

class HomePageState extends State<HomePage> {

  HomePageState(this.title);

  // For updating displayed page
  PageController _pageController;
  final String title;
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        children: [
          FeedPage(),
          DashboardPage(),
          MoxiePage(),
        ],
        controller: _pageController,
        onPageChanged: (int page) {
          setState((){
            this._page = page;
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.view_day,
            ),
            title: CustomText.qarmicSans(
              text:  'feed',
              color: Colors.grey,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.fitness_center,
            ),
            title: CustomText.qarmicSans(
              text:  'dashboard',
              color: Colors.grey,
            )
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.calendar_today,
            ),
            title: CustomText.qarmicSans(
              text:  'calendar',
              color: Colors.grey,
            )
          ),
        ],
        onTap: navigationBarClicked,
        currentIndex: _page,
      )
    );
  }

  void navigationBarClicked(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease
    );
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }
}
