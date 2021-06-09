import 'package:flutter/material.dart';
import 'package:moxie_fitness/components/components.dart';

class FormWizardCompleter extends StatefulWidget {

  final Function onAttemptFinish;
  final bool show;
  final bool saving;

  FormWizardCompleter({
    this.show,
    this.saving = false,
    this.onAttemptFinish
  });

  @override
  FormWizardCompleterState createState() {
    return new FormWizardCompleterState();
  }
}

class FormWizardCompleterState extends State<FormWizardCompleter> {

  @override
  Widget build(BuildContext context) {
    if (widget.saving) {
      return new CenteredCircularProgress();
    } else {
      return new Column(
      children: <Widget>[
        new Expanded(
          child: new Container()
        ),
        new Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            new Padding(
              padding: new EdgeInsets.only(right: 10.0, bottom: 20.0),
              child: new FlatButton(
                shape: new CircleBorder(),
                child: widget.show ?
                  new Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 35.0,
                  )
                  : new Container()
                ,
                onPressed: () async {
                  if(!widget.saving) {
                    await this.widget.onAttemptFinish();
                  }
                },
              ),
            )
          ],
        ),
      ],
    );
    }
  }
}
