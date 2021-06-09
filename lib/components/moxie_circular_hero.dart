import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:moxie_fitness/utils/utils.dart';

class MoxieCircularHero extends StatelessWidget {
  final double diameter;
  final String imgUrl;
  final Widget imgWidget;
  final Function onTap;

  MoxieCircularHero.withUrl({this.diameter = 75.0, this.imgUrl, this.onTap})
      : imgWidget = null;

//  MoxieCircularHero.withWidget({
//    this.diameter = 75.0,
//    this.imgWidget,
//    this.onTap
//  }) : imgUrl = null;

  @override
  Widget build(BuildContext context) {
    return Utils.addClick(
        widget: imgWidget != null
            ? imgWidget
            : Container(
                margin: const EdgeInsets.all(8.0),
                height: diameter,
                width: diameter,
                child: ClipOval(
                    child: CachedNetworkImage(
                  imageUrl: imgUrl,
                  placeholder: (context, url) => Center(
                    child: Container(
                      height: 75.0,
                      width: 75.0,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  fit: BoxFit.cover,
                ))),
        param: onTap);
  }
}
