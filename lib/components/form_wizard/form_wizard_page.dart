import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:moxie_fitness/components/form_wizard/page_reveal.dart';

class FormWizardPage extends StatelessWidget {
  final FormWizardPageViewModel pageModel;
  final double percentVisible;

  FormWizardPage({
    @required this.pageModel,
    this.percentVisible = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: this.pageModel.color,
      child: PageReveal(
        revealPercent: percentVisible,
        child: Opacity(
          opacity: percentVisible,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              this.pageModel.assetPath != null &&
                      this.pageModel.assetPath.length > 0
                  ? Transform(
                      transform: Matrix4.translationValues(
                          0.0, 50.0 * (1 - percentVisible), 0.0),
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 20.0),
                        child: Image.asset(
                          this.pageModel.assetPath,
                          width: 150.0,
                          height: 150.0,
                        ),
                      ),
                    )
                  : Container(),
              Transform(
                transform: Matrix4.translationValues(
                    0.0, 30.0 * (1 - percentVisible), 0.0),
                child: Padding(
                  padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 40.0),
                  child: Text(
                    this.pageModel.heading,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'FlamanteRoma',
                      fontSize: 26.0,
                    ),
                  ),
                ),
              ),
              Transform(
                transform: Matrix4.translationValues(
                    0.0, 30.0 * (1 - percentVisible), 0.0),
                child: Padding(
                    padding:
                        EdgeInsets.only(right: 25.0, left: 25.0, bottom: 50.0),
                    child: this.pageModel.input),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class FormWizardPageViewModel {
  final String heading;
  final Widget input;
  final String assetPath;
  final color;

  FormWizardPageViewModel(
      {@required this.heading,
      @required this.input,
      this.assetPath,
      this.color});
}
