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
    Widget image;

    if (item.imagemBase64 != null) {
      final bytes = base64Decode(item.imagemBase64!);
      image = Image.memory(
        bytes,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    } else if (item.imagemUrl != null) {
      image = Image.network(
        item.imagemUrl!,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : _placeholder(),
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    } else if (item.imagemAsset != null) {
      image = Image.asset(
        item.imagemAsset!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    } else {
      return _placeholder();
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFE1F5EE),
      child: const Center(
        child: Icon(Icons.image_outlined, color: Color(0xFF1D9E75), size: 32),
      ),
    );
  }
}