import 'package:flutter/material.dart';

void volverAlInicio(BuildContext context) {
  //Navigator.popUntil(context, (route) => route.isFirst);
  Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
}
