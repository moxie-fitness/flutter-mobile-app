import 'package:flutter/material.dart';
import 'package:moxie_fitness/components/components.dart';
import 'package:moxie_fitness/config/routes.dart';

class MoxieRoundImageCard extends StatelessWidget {
  final Color background;
  final Color cardColor;
  final String tag;
  final MoxieNetworkImage imageProvider;
  final String route;
  final String title;
  final String desc;

  MoxieRoundImageCard({
    this.background,
    this.cardColor,
    @required this.tag,
    @required this.title,
    @required this.desc,
    @required this.imageProvider,
    @required this.route,
  });

  @override
  Widget build(BuildContext context) {
    final planetThumbnail = Container(
      height: 115,
      width: 115,
      alignment: FractionalOffset(0.0, 0.5),
      margin: const EdgeInsets.only(left: 24.0, bottom: 8.0),
      child: Hero(
        tag: tag,
        child: imageProvider,
      ),
    );

    final planetCard = Container(
      margin: const EdgeInsets.only(left: 72.0, right: 24.0, bottom: 8.0),
      decoration: BoxDecoration(
        color: cardColor ?? Colors.orangeAccent,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: Colors.black54, blurRadius: 7.0, offset: Offset(0.0, 7.0))
        ],
      ),
      child: Container(
        margin: const EdgeInsets.only(top: 16.0, left: 72.0),
        constraints: BoxConstraints.expand(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title,
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 24.0)),
            Text(desc,
                style: TextStyle(
                    color: Colors.white70,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    fontSize: 17.0)),
            Container(
                color: const Color(0xFF00C6FF),
                width: 48.0,
                height: 1.5,
                margin: const EdgeInsets.symmetric(vertical: 8.0)),
          ],
        ),
      ),
    );

    return Container(
      height: 120.0,
      margin: const EdgeInsets.only(top: 16.0, bottom: 12.0),
      child: FlatButton(
        onPressed: () => Routes.router.navigateTo(context, route),
        child: Stack(
          children: <Widget>[
            planetCard,
            planetThumbnail,
          ],
        ),
      ),
    );
  }
}
