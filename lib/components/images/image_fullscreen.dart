import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageFullscreenPage extends StatefulWidget {
  final File image;
  final String imageUrl;

  ImageFullscreenPage({this.image, this.imageUrl})
      : assert(image != null || imageUrl != null);

  @override
  _ImageFullscreenPageState createState() => _ImageFullscreenPageState();
}

class _ImageFullscreenPageState extends State<ImageFullscreenPage> {
  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Center(
        child: widget.image != null
            ? Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                  fit: BoxFit.fill,
                  alignment: FractionalOffset.center,
                  image: FileImage(widget.image),
                )),
              )
            : Container(
                child: CachedNetworkImage(
                  imageUrl: widget.imageUrl,
                  fit: BoxFit.fill,
                  alignment: FractionalOffset.center,
                  placeholder: (context, url) => Center(
                        child: Container(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                  errorWidget: (context, url, error) => Center(
                        child: Container(
                          child: Icon(Icons.error),
                        ),
                      ),
                ),
              ),
      ),
    ]);
  }
}
