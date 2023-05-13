import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gif_view/gif_view.dart';
import 'package:green_bush/models/shot.dart';
import 'package:url_launcher/url_launcher.dart';

class Thumb extends StatefulWidget {
  final Shot shot;
  final Function setAuto;
  final Function precache;
  final Function getPrecaching;
  final Function refresh;

  const Thumb({
    Key? key,
    required this.shot,
    required this.setAuto,
    required this.precache,
    required this.getPrecaching,
    required this.refresh,
  }) : super(key: key);

  @override
  State<Thumb> createState() => _ThumbState();
}

class _ThumbState extends State<Thumb> {
  void gp() async {
    if (widget.shot.url.isNotEmpty && widget.shot.image == null) {
      if (!widget.getPrecaching().contains(widget.shot.id)) {
        widget.precache(widget.shot);
      }
    }
    if (kDebugMode) {
      print(
          'building ${widget.shot.id}, ${widget.shot.url} ${widget.shot.image.runtimeType} precaching:${widget.getPrecaching().contains(widget.shot.id)} ${widget.getPrecaching()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    gp();
    return IntrinsicHeight(
      child: GestureDetector(
          onTap: () {
            widget.setAuto(false);
            launchUrl(Uri.parse(widget.shot.url),
                mode: LaunchMode.externalApplication);
          },
          child: (widget.shot.url.isEmpty || widget.shot.image == null)
              ? GifView.asset('assets/images/loading.gif')
              : FittedBox(
                  fit: BoxFit.contain,
                  child: widget.shot.image,
                )),
    );
  }
}
