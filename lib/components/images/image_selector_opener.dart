import 'dart:io';
import 'package:flutter/material.dart';
import 'package:moxie_fitness/components/components.dart';


class ImageSelectorOpener extends StatelessWidget {
  final List<File> images;
  final Color fontAndIconColors;
  final Color backgroundColor;
  final Function onImagesUpdated;
  final num maxImages;
  final withHint;

  ImageSelectorOpener({
    this.images,
    this.fontAndIconColors = Colors.white,
    this.backgroundColor = Colors.white,
    this.onImagesUpdated,
    this.maxImages = 6,
    this.withHint = true
  });

  @override
  Widget build(BuildContext context) {
    return new Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        images.length > 0 && withHint ? new Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: new Text(
            "Images : ${images.length}",
            style: new TextStyle(
              color: Colors.white
            )
          ),
        ) : new Container(),
        new MoxieRoundButton(
          data: "${images.length > 0 ? "Update" : "Upload"}",
          color: backgroundColor,
          textColor: fontAndIconColors,
          height: 45.0,
          width: 180.0,
          image: new Image(
            image: new AssetImage("assets/circle-camera-512.png"),
              height: 40.0,
              color: fontAndIconColors,
            ),
          onTap: () {
            var updatedImages = Navigator.push(
              context,
              new MaterialPageRoute(
                builder: (context) =>
                new ImageSelector(
                  images: images,
                  fontAndIconColors: fontAndIconColors,
                  backgroundColor: backgroundColor,
                  maxImages: maxImages,
                ),
              ),
            );
            if(onImagesUpdated != null)
              onImagesUpdated(updatedImages);
          }
        ),
      ]
    );
  }
}
