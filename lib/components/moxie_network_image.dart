import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:moxie_fitness/components/components.dart';
import 'package:moxie_fitness/utils/utils.dart';

class MoxieNetworkImage extends StatelessWidget {
  final imgUrl;
  final margin;
  final width;
  final height;
  final bool openImagefullscreen;
  final bool fillCover;

  MoxieNetworkImage(
      {this.imgUrl,
      this.margin = const EdgeInsets.all(8.0),
      this.width = 75.0,
      this.height = 75.0,
      this.openImagefullscreen = false,
      this.fillCover = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.all(0.0),
      child: Utils.addClick(
          widget: _buildCachedNetworkImage(context, imgUrl),
          param: openImagefullscreen
              ? () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ImageFullscreenPage(imageUrl: imgUrl),
                  ))
              : () => {}),
    );
  }

  _buildCachedNetworkImage(ctx, url) {
    if (this.fillCover) {
      return CachedNetworkImage(
          imageUrl: url,
          imageBuilder: this.fillCover
              ? (context, image) => Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      image: DecorationImage(image: image, fit: BoxFit.cover),
                    ),
                  )
              : null,
          fit: BoxFit.cover,
          placeholder: _buildPlaceholder(ctx, url),
          errorWidget: _buildError(ctx, url));
    } else {
      return CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: _buildPlaceholder(ctx, url),
          errorWidget: _buildError(ctx, url));
    }
  }

  _buildPlaceholder(ctx, url) {
    return (context, url) => Center(
          child: Container(
            width: this.width,
            height: this.height,
            child: CircularProgressIndicator(),
          ),
        );
  }

  _buildError(ctx, url) {
    return (context, url, error) => Center(
          child: Container(
            width: this.width,
            height: this.height,
            child: Icon(Icons.error),
          ),
        );
  }
}
