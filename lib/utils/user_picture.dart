import 'package:flutter/material.dart';
import 'package:random_avatar/random_avatar.dart';

Widget getUserPicture(String? displayName, String email) {
  return RandomAvatar(displayName ?? email, height: 50, width: 50);
}
