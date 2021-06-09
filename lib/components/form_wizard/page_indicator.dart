import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:jaguar_serializer/jaguar_serializer.dart';
import 'package:moxie_fitness/components/components.dart';

class PagerIndicator extends StatelessWidget {

  final PagerIndicatorViewModel viewModel;
  final StreamController<FormWizardUpdate> formWizardUpdateStream;


  PagerIndicator({
    this.viewModel,
    this.formWizardUpdateStream
  });

  @override
  Widget build(BuildContext context) {

    List<PageBubble> bubbles = [];

    for(var i = 0; i < viewModel.pages.length; i++) {
      final page = viewModel.pages[i];

      SlideDirection directionIfClicked = SlideDirection.none;
      var percentActive = viewModel.slidePercent;
      if(i == viewModel.activeIndex) {
        percentActive = 1.0 - viewModel.slidePercent;
      } else if(i == viewModel.activeIndex - 1) {
        if(viewModel.slideDirection == SlideDirection.leftToRight){
          percentActive = viewModel.slidePercent;
        } else {
          percentActive = 0.0;
        }
        directionIfClicked = SlideDirection.leftToRight;
      } else if(i == viewModel.activeIndex + 1) {
        if(viewModel.slideDirection == SlideDirection.rightToLeft){
          percentActive = viewModel.slidePercent;
        } else {
          percentActive = 0.0;
        }
        directionIfClicked = SlideDirection.rightToLeft;
      } else {
        percentActive = 0.0;
      }

      bool isHollow = i > viewModel.activeIndex || (i == viewModel.activeIndex && viewModel.slideDirection == SlideDirection.leftToRight);

      bubbles.add(new PageBubble(
        viewModel: new PageBubbleViewModel(
            page.assetPath,
            page.color,
            isHollow,
            percentActive,
        ),
        streamController: this.formWizardUpdateStream,
        slideDirectionWhenClicked: directionIfClicked,
      ));
    }

    final bubbleWidth = 55.0;
    final baseTranslation = ((viewModel.pages.length * bubbleWidth / 2) - (bubbleWidth / 2));
    var translation = baseTranslation - viewModel.activeIndex * bubbleWidth;

    // Offset translation when sliding
    if(viewModel.slideDirection == SlideDirection.leftToRight) {
      translation += bubbleWidth * viewModel.slidePercent;
    } else if(viewModel.slideDirection == SlideDirection.rightToLeft) {
      translation -= bubbleWidth * viewModel.slidePercent;
    }

    return new Column(
      children: <Widget>[
        new Expanded(child: new Container()),
        new Transform(
            transform: new Matrix4.translationValues(translation + 10.0, 0.0, 0.0),
            child: new Container(
              width: 385.0,
              padding: const EdgeInsets.only(bottom: 10.0),
              child: new Row(
                mainAxisSize: MainAxisSize.max,
                children: bubbles,
              )
            ),
          )
      ],
    );
  }
}

class PageBubble extends StatelessWidget {

  final PageBubbleViewModel viewModel;
  final StreamController<FormWizardUpdate> streamController;
  final SlideDirection slideDirectionWhenClicked; //

  PageBubble({
    this.viewModel,
    this.streamController,
    this.slideDirectionWhenClicked
  });

  @override
  Widget build(BuildContext context) {
    return new InkResponse(
      onTap: (){
        streamController.add(
            new FormWizardUpdate(
              slideDirectionWhenClicked,
              viewModel.activePercent,
              FormWizardUpdateType.indicatorClicked,
            )
        );
      },
      child: new Container(
        width: 55.0,
        height: 65.0,
        child: new Center(
          child: new Container(
            width: lerpDouble(20.0, 45.0, viewModel.activePercent),
            height: lerpDouble(20.0, 45.0, viewModel.activePercent),
            decoration: new BoxDecoration(
              shape: BoxShape.circle,
              color: viewModel.isHollow
                    ? const Color(0x88FFFFFF).withAlpha((0x88 * viewModel.activePercent).round())
                    : const Color(0x88FFFFFF),
              border: new Border.all(
                color: viewModel.isHollow
                    ? const Color(0x88FFFFFF)
                    : const Color(0x88FFFFFF).withAlpha((0x88 * (1.0 - viewModel.activePercent)).round()),
                width: 3.0
              )
            ),
            child: new Opacity(
              opacity: viewModel.activePercent,
              // ignore: conflicting_dart_import
              child: viewModel.iconAssetPath != null ? new Image.asset(
                viewModel.iconAssetPath,
                color: viewModel.color,
              ) : new Container(),
            ),
          ),
        ),
      ),
    );
  }
}

class PageBubbleViewModel {
  @nullable final String iconAssetPath;
  final Color color;
  final bool isHollow;
  final double activePercent;

  PageBubbleViewModel(
    this.iconAssetPath,
    this.color,
    this.isHollow,
    this.activePercent
  );
}

class PagerIndicatorViewModel {
  final List<FormWizardPageViewModel> pages;
  final int activeIndex;
  final SlideDirection slideDirection;
  final double slidePercent;

  PagerIndicatorViewModel(
    this.pages,
    this.activeIndex,
    this.slideDirection,
    this.slidePercent
  );
}

