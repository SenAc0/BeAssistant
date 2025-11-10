import 'package:flutter/material.dart';

void volverAlInicio(BuildContext context) {
  // Navigate to the app main screen and clear the back stack to avoid landing on a blank page.
  Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
}

