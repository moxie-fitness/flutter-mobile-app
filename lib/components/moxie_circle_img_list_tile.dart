import 'package:flutter/widgets.dart';
import 'package:moxie_fitness/components/components.dart';

class MoxieCircleImgListTile extends StatelessWidget {

  final imgUrl;
  final Function onTap;
  final description;

  MoxieCircleImgListTile({
    this.imgUrl,
    this.onTap,
    this.description
  });

  @override
  Widget build(BuildContext context) {
    return new Row(
      children: <Widget>[
        new Expanded(
          flex: 2,
          child: new Container(
            child: new Center(
              child: new MoxieCircularHero.withUrl(
                diameter: 75.0,
                imgUrl: imgUrl,
                onTap: onTap,
              ),
            ),
          ),
        )  ,
        new Expanded(
            flex: 4,
            child: new CustomText.qarmicSans(
              text: description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
        )
      ],
    );
  }
}
