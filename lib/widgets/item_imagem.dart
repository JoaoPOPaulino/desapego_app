import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/item_model.dart';

class ItemImage extends StatelessWidget {
  final ItemModel item;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const ItemImage({
    super.key,
    required this.item,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    Widget image = _buildImage();

    image = SizedBox(width: width, height: height, child: image);

    if (borderRadius != null){
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }

    return image;
  }

 Widget _buildImage() {
    if (item.imagemBase64 != null) {
      final bytes = base64Decode(item.imagemBase64!);
      return Image.memory(
        bytes,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }

    if (item.imagemUrl != null) {
      return Image.network(
        item.imagemUrl!,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : _loadingPlaceholder(),
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }

    if (item.imagemAsset != null) {
      return Image.asset(
        item.imagemAsset!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }

    return _placeholder();
  }

  Widget _loadingPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFF0F0F0),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFF534AB7),
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFF0EFFC),
      child: const Center(
        child: Icon(Icons.image_outlined, color: Color(0xFF534AB7), size: 28),
      ),
    );
  }
}
