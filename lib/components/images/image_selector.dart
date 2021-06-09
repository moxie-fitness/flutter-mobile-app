import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moxie_fitness/components/components.dart';

class ImageSelectorUpdate {
  final File image;
  final int currentIndex;
  final int switchWith;
  final ImageSelectorUpdateType type;

  ImageSelectorUpdate(
      {this.image, this.currentIndex = -1, this.switchWith = -1, this.type});
}

enum ImageSelectorUpdateType { addImage, removeImage, shiftImage }

class ImageSelector extends StatefulWidget {
  final List<File> images;
  final Color fontAndIconColors;
  final Color backgroundColor;
  final num maxImages;

  ImageSelector(
      {@required this.images,
      this.fontAndIconColors = Colors.white,
      this.backgroundColor = Colors.white,
      this.maxImages = 6});

  @override
  _ImageUploaderState createState() => new _ImageUploaderState(this.images);
}

class _ImageUploaderState extends State<ImageSelector> {
  final key = new GlobalKey<ScaffoldState>();
  final images;
  StreamController<ImageSelectorUpdate> _imagesSelectorController;
  List<File> currentImages;

  Future getImage(ImageSource source) async {
    if (currentImages.length >= widget.maxImages.toInt()) {
      key.currentState.showSnackBar(new SnackBar(
        content:
            new Text("You can only select up to ${widget.maxImages} Images"),
        duration: new Duration(seconds: 4),
      ));
    } else {
      var image = await ImagePicker.pickImage(source: source);

      if (image != null) {
        _imagesSelectorController.add(new ImageSelectorUpdate(
            image: image, type: ImageSelectorUpdateType.addImage));
      }
    }
  }

  _ImageUploaderState(this.images) {
    currentImages = images;
    _imagesSelectorController =
        new StreamController<ImageSelectorUpdate>.broadcast(sync: true);
    _imagesSelectorController.stream.listen((ImageSelectorUpdate update) {
      setState(() {
        if (update.type == ImageSelectorUpdateType.addImage) {
          currentImages.add(update.image);
        } else if (update.type == ImageSelectorUpdateType.removeImage) {
          currentImages.remove(update.image);
        } else if (update.type == ImageSelectorUpdateType.shiftImage) {
          final otherImage = currentImages[update.switchWith];
          currentImages[update.switchWith] = currentImages[update.currentIndex];
          currentImages[update.currentIndex] = otherImage;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: key,
      appBar: new AppBar(
        backgroundColor: widget.backgroundColor,
        title: new Text(
          "Select Images",
          style: new TextStyle(color: widget.fontAndIconColors),
        ),
        actions: <Widget>[
          new IconButton(
              icon: new Icon(Icons.check, color: widget.fontAndIconColors),
              onPressed: () =>
                  Navigator.of(context).pop(currentImages ?? widget.images))
        ],
        elevation: 0.0,
      ),
      backgroundColor: widget.backgroundColor,
      body: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          new Container(
            height: 220.0,
            width: 220.0,
            child: currentImages == null || currentImages.isEmpty
                ? new Center(
                    child: new Text(
                    'No images selected.',
                    style: new TextStyle(color: widget.fontAndIconColors),
                  ))
                : new Carousel(
                    widgets: currentImages.map((img) {
                      return new Builder(builder: (BuildContext context) {
                        return new GestureDetector(
                          onTap: () => _openFullscreenImagePage(img),
                          child: new Stack(
                            children: <Widget>[
                              new Container(
                                width: MediaQuery.of(context).size.width,
                                child: new Image.file(
                                  img,
                                  fit: BoxFit.fitWidth,
                                ),
                              ),
                              currentImages.length >= 2
                                  ? new Align(
                                      alignment: Alignment.topRight,
                                      child: new IconButton(
                                        icon: new Icon(Icons.compare_arrows),
                                        color: widget.fontAndIconColors,
                                        onPressed: () => _swapImage(img),
                                      ),
                                    )
                                  : new Container(),
                              new Align(
                                alignment: Alignment.topLeft,
                                child: new IconButton(
                                  icon: new Icon(Icons.delete),
                                  color: widget.fontAndIconColors,
                                  onPressed: () => _removeImageDialog(img),
                                ),
                              ),
                              new Padding(
                                padding: new EdgeInsets.all(12.0),
                                child: new Align(
                                    alignment: Alignment.bottomRight,
                                    child: new Text(
                                        "${currentImages.indexOf(img) + 1}",
                                        style: new TextStyle(
                                            color: widget.fontAndIconColors))),
                              )
                            ],
                          ),
                        );
                      });
                    }).toList(),
                    autoplay: false,
                  ),
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Padding(
                padding: const EdgeInsets.all(10.0),
                child: new FloatingActionButton(
                  onPressed: () => getImage(ImageSource.gallery),
                  child: new Icon(Icons.image),
                  heroTag: null,
                ),
              ),
              new Padding(
                padding: const EdgeInsets.all(10.0),
                child: new FloatingActionButton(
                  onPressed: () => getImage(ImageSource.camera),
                  child: new Icon(Icons.camera_alt),
                  heroTag: null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openFullscreenImagePage(image) {
    Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (context) => new ImageFullscreenPage(image: image),
      ),
    );
  }

  void _removeImageDialog(image) {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text("Remove Image"),
              content: new Text("Are you sure you want to remove this image?"),
              actions: <Widget>[
                new FlatButton(
                    child: const Text("Remove"),
                    onPressed: () {
                      _imagesSelectorController.add(new ImageSelectorUpdate(
                          image: image,
                          type: ImageSelectorUpdateType.removeImage));
                      Navigator.pop(context);
                    }),
                new FlatButton(
                    child: const Text("Keep",
                        style: const TextStyle(color: Colors.blue)),
                    onPressed: () => Navigator.pop(context))
              ],
            ));
  }

  void _swapImage(image) {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text("Image Swap"),
              content: new Text("Swap image with another?"),
              actions: <Widget>[
                new FlatButton(
                    child: const Text("Swap Left",
                        style: const TextStyle(color: Colors.blue)),
                    onPressed: () {
                      final currentIndex = currentImages.indexOf(image);
                      // First position >> switch with last >> length - 1
                      final switchWith = (currentIndex == 0)
                          ? currentImages.length - 1
                          : currentIndex - 1;
                      _imagesSelectorController.add(new ImageSelectorUpdate(
                          currentIndex: currentIndex,
                          switchWith: switchWith,
                          type: ImageSelectorUpdateType.shiftImage));
                      Navigator.pop(context);
                    }),
                new FlatButton(
                    child: const Text("Cancel"),
                    onPressed: () => Navigator.pop(context)),
                new FlatButton(
                    child: const Text("Swap Right",
                        style: const TextStyle(color: Colors.blue)),
                    onPressed: () {
                      final currentIndex = currentImages.indexOf(image);
                      // Last position >> switch with first >> 0
                      final switchWith =
                          (currentIndex + 1 == currentImages.length)
                              ? 0
                              : currentIndex + 1;
                      _imagesSelectorController.add(new ImageSelectorUpdate(
                          currentIndex: currentIndex,
                          switchWith: switchWith,
                          type: ImageSelectorUpdateType.shiftImage));
                      Navigator.pop(context);
                    })
              ],
            ));
  }
}
