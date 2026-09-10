import 'package:flutter/material.dart';

/// A child's (or any person's) avatar: their photo, or their initials on a
/// tinted circle when there is no photo.
///
/// Kept dependency-free of `cached_network_image` for now — swap the `Image`
/// for `CachedNetworkImage` once photo uploads are wired up.
class ChildAvatar extends StatelessWidget {
  const ChildAvatar({
    required this.initials,
    this.photoUrl,
    this.size = 48,
    this.ringColor,
    super.key,
  });

  final String initials;
  final String? photoUrl;
  final double size;

  /// A coloured ring around the avatar, used to echo a status colour without
  /// needing a separate badge.
  final Color? ringColor;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Widget fallback = CircleAvatar(
      radius: size / 2,
      backgroundColor: scheme.primaryContainer,
      child: Text(
        initials,
        style: TextStyle(
          color: scheme.onPrimaryContainer,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.36,
        ),
      ),
    );

    final Widget avatar = (photoUrl == null || photoUrl!.isEmpty)
        ? fallback
        : ClipOval(
            child: Image.network(
              photoUrl!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => fallback,
            ),
          );

    if (ringColor == null) return avatar;

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ringColor!, width: 2),
      ),
      child: avatar,
    );
  }
}
