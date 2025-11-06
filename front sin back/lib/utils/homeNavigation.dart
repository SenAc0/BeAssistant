import 'package:flutter/material.dart';

void volverAlInicio(BuildContext context) {
  //Navigator.popUntil(context, (route) => route.isFirst);
  Navigator.popUntil(context, ModalRoute.withName('/main'));
}
