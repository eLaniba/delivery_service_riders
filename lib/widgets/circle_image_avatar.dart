import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

final Color white80 = Colors.white.withOpacity(0.8);

class CircleImageAvatar extends StatelessWidget {
  final String? imageUrl;
  final double size;

  const CircleImageAvatar({
    Key? key,
    this.imageUrl,
    this.size = 80.0, // Default size
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: imageUrl != null
          ? CachedNetworkImage(
              imageUrl: imageUrl!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: size,
                  height: size,
                  color: Colors.grey[300],
                  child: Center(
                    child: Icon(
                      PhosphorIcons.image(PhosphorIconsStyle.fill),
                      size: size * 0.4,
                    ),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                width: size,
                height: size,
                color: white80,
                child: Icon(
                  PhosphorIcons.imageBroken(PhosphorIconsStyle.fill),
                  color: Colors.white,
                  size: size * 0.6,
                ),
              ),
            )
          : Container(
              width: size,
              height: size,
              color: white80,
              child: Icon(
                PhosphorIcons.imageBroken(PhosphorIconsStyle.fill),
                color: Colors.white,
                size: size * 0.6,
              ),
            ),
    );
  }
}
