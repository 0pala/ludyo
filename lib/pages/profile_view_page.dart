import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ludyo/auth/firebase_auth.dart';

class ProfileViewPage extends StatelessWidget {
  const ProfileViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Row(
            spacing: 32,
            children: [
              ClipRRect(
                borderRadius: BorderRadiusGeometry.circular(50),
                child: CachedNetworkImage(
                  imageUrl: authService.value.currentUser!.photoURL ?? '',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                  errorWidget: (_, _, _) => Image.asset(
                    'assets/placeholders/user_picture_placeholder.png',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Text(
                authService.value.currentUser!.displayName ?? 'N/A',
                // textAlign: TextAlign.start,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
