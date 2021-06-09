import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:moxie_fitness/components/components.dart';
import 'package:moxie_fitness/components/form_wizard/page_indicator.dart';

class FormWizardPager extends StatefulWidget {

  final formKey;
  final List<FormWizardPageViewModel> pages;
  final Function onAttemptFinish;
  final bool saving;

  FormWizardPager({
    this.formKey,
    @required this.pages,
    @required this.onAttemptFinish,
    this.saving
  });

  @override
  _FormWizardPagerState createState() => new _FormWizardPagerState();
}

class _FormWizardPagerState extends State<FormWizardPager> with TickerProviderStateMixin {

  StreamController<FormWizardUpdate> formWizardUpdateStream;
  AnimatedPageDragger animatedPageDragger;
  bool keyboardOpen;

  int activeIndex = 0;
  int nextPageIndex = 0;
  SlideDirection slideDirection = SlideDirection.none;
  double slidePercent = 0.0;
  double dragVelocity;

  _FormWizardPagerState() {
    formWizardUpdateStream = new StreamController<FormWizardUpdate>();

    formWizardUpdateStream.stream.listen((FormWizardUpdate event) {
      setState(() {
        if(event.updateType == FormWizardUpdateType.dragging) {
          slideDirection = event.direction;
          slidePercent = event.slidePercent;

          if(slideDirection == SlideDirection.leftToRight) {
            nextPageIndex = activeIndex - 1;
          } else if (slideDirection == SlideDirection.rightToLeft) {
            nextPageIndex = activeIndex + 1;
          } else {
            nextPageIndex = activeIndex;
          }

        } else if(event.updateType == FormWizardUpdateType.doneDragging){

          final velocity = event.dragVelocity.abs();
          // How far are we to next page > should we transition?
          if(slidePercent > 0.27 || velocity > 12.0) {
            animatedPageDragger = new AnimatedPageDragger(
                slideDirection: slideDirection,
                transitionGoal: TransitionGoal.open,
                slidePercent: slidePercent,
                formWizardUpdateStream: formWizardUpdateStream,
                dragVelocity: dragVelocity,
                vsync: this,
            );
          } else {
            // Animate back to current page
            animatedPageDragger = new AnimatedPageDragger(
                slideDirection: slideDirection,
                transitionGoal: TransitionGoal.close,
                slidePercent: slidePercent,
                formWizardUpdateStream: formWizardUpdateStream,
                dragVelocity: dragVelocity,
                vsync: this,
            );

            nextPageIndex = activeIndex;
          }
          print('Ended Dragging: ${event.direction} at ${event.slidePercent} and $velocity velocity.');
          animatedPageDragger.run();
        } else if( event.updateType == FormWizardUpdateType.animating){
          print('Animating: ${event.direction} at ${event.slidePercent}');
          slideDirection = event.direction;
          slidePercent = event.slidePercent;
        } else if(event.updateType == FormWizardUpdateType.doneAnimating) {
          print('Done animating. Next page index: $nextPageIndex');
          activeIndex = nextPageIndex;
          slideDirection = SlideDirection.none;
          slidePercent = 0.0;

          animatedPageDragger.dispose();
        } else if(event.updateType == FormWizardUpdateType.indicatorClicked){
          // Animate to clicked indicator page
          animatedPageDragger = new AnimatedPageDragger(
            slideDirection: event.direction,
            transitionGoal: TransitionGoal.open,
            slidePercent: 0.0,
            formWizardUpdateStream: formWizardUpdateStream,
            dragVelocity: 0.0,
            vsync: this,
          );

          if(event.direction == SlideDirection.leftToRight) {
            nextPageIndex = activeIndex - 1;
          } else if (event.direction == SlideDirection.rightToLeft) {
            nextPageIndex = activeIndex + 1;
          } else {
            nextPageIndex = activeIndex;
          }

          animatedPageDragger.run();
        }
        nextPageIndex.clamp(0, widget.pages.length-1);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: _onWillPop,
        child: new Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: new Form(
            key: widget.formKey,
            child: new Stack(
              children: <Widget>[
                new FormWizardPage(
                  pageModel: widget.pages[activeIndex],
                  percentVisible: 1.0,
                ),
                new PageReveal(
                  revealPercent: slidePercent,
                  child: new FormWizardPage(
                    pageModel: widget.pages[nextPageIndex],
                    percentVisible: slidePercent,
                  ),
                ),
                MediaQuery.of(context).viewInsets.bottom == 0 ?
                  new PagerIndicator(
                    viewModel: new PagerIndicatorViewModel(
                        widget.pages,
                        activeIndex,
                        slideDirection,
                        slidePercent
                    ),
                    formWizardUpdateStream: this.formWizardUpdateStream,
                  )
                  : new Container(),
                new PageDragger(
                  canDragLeftToRight: activeIndex > 0,
                  canDragRightToLeft: activeIndex < widget.pages.length - 1,
                  formWizardUpdateStream: this.formWizardUpdateStream,
                ),
                _buildBackArrow(),
                new FormWizardCompleter(
                  show: activeIndex == widget.pages.length - 1,
                  onAttemptFinish: widget.onAttemptFinish,
                  saving: widget.saving,
                ),
              ],
          ),
        ),
      ),
    );
  }
      
  _buildBackArrow() {
    return new Column(
      children: <Widget>[
        new Container(
          margin: const EdgeInsets.only(top: 40.0, left: 10.0),
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              new BackButton(
                color: Colors.white,
              )
            ],
          ),
        ),
        new Expanded(child: new Container()),
      ],
    );
  }

  Future<bool> _onWillPop() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text('Leave?'),
          content: new Text('Progress/data for this form will be lost.'),
          actions: <Widget>[
            new MoxieFlatButton(
              data: 'Cancel',
              textColor: Theme.of(context).primaryColor,
              onPressed: () => Navigator.of(context).pop(false),
            ),
            new MoxieFlatButton(
              data: 'Leave',
              textColor: Theme.of(context).primaryColor,
              onPressed: () => Navigator.of(context).pop(true),
            )
          ],
        );
      }
    );
  }
}
