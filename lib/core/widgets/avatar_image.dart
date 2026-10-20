import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../api/api_constants.dart';

class AvatarImage extends StatelessWidget {
  final String? avatarUrl;
  final double size;
  final IconData fallbackIcon;
  final Color backgroundColor;

  const AvatarImage({
    super.key,
    required this.avatarUrl,
    this.size = 96,
    this.fallbackIcon = Icons.person,
    this.backgroundColor = const Color(0xFFD6D6D6),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final url = avatarUrl?.trim();
    if (url == null || url.isEmpty) {
      return Icon(fallbackIcon, size: size * 0.58, color: const Color(0xFF424242));
    }

    // 1. Asset Image
    if (url.startsWith('assets/')) {
      return Image.asset(url, width: size, height: size, fit: BoxFit.cover);
    }

    // 2. Base64 Data URL or string
    if (url.startsWith('data:image')) {
      try {
        final commaIdx = url.indexOf(',');
        final base64Str = commaIdx != -1 ? url.substring(commaIdx + 1) : url;
        return Image.memory(
          base64Decode(base64Str),
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (ctx, err, stack) => Icon(
            fallbackIcon,
            size: size * 0.58,
            color: const Color(0xFF424242),
          ),
        );
      } catch (_) {}
    }

    // 3. Local file path (e.g. from Camera or Gallery)
    if (!url.startsWith('http')) {
      try {
        final file = File(url);
        if (file.existsSync()) {
          return Image.file(
            file,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (ctx, err, stack) => Icon(
              fallbackIcon,
              size: size * 0.58,
              color: const Color(0xFF424242),
            ),
          );
        }
      } catch (_) {}
    }

    // 4. Remote HTTP URL
    final fullUrl = url.startsWith('http') ? url : '${ApiConstants.baseUrl}$url';
    return Image.network(
      fullUrl,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (ctx, err, stack) => Icon(
        fallbackIcon,
        size: size * 0.58,
        color: const Color(0xFF424242),
      ),
    );
  }
}
