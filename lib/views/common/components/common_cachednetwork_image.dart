import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../utils/app_colors.dart';

class CommonCachedNetworkImage extends StatelessWidget {
  String imageUrl;
  double borderRadius;
  double? height,width;
  CommonCachedNetworkImage({super.key, required this.imageUrl,this.borderRadius=0,this.height,this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      child: ClipRRect(
        borderRadius:
        BorderRadius.circular(borderRadius),
        child: CachedNetworkImage(
          imageUrl:imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, _) {
            return Shimmer.fromColors(
              baseColor: AppColor.shimmerBaseColor,
              highlightColor: AppColor.shimmerHighlightColor,
              child: Container(
                alignment: Alignment.center,
                color: AppColor.shimmerContainerColor,
                child: Icon(
                  Icons.image,
                  size: 20,
                ),
              ),
            );
          },
          errorWidget: (___, __, _) => Container(
            color: Colors.grey[200],
            child: Icon(
              Icons.image_outlined,
              color: Colors.grey[400],
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
