import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart';

class ShowToasts {
  void showSuccessToast(String message) {
    if (Platform.isAndroid) {
      print("Working in Android");
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: const Color.fromARGB(255, 20, 20, 20),
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } else if (Platform.isWindows) {
      print("Working in Windows");
      // to make scaffold work pass buildcontext to method 
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    }
  }

  void showErrorToast(String message) {
    if (Platform.isAndroid) {
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: const Color.fromARGB(255, 99, 98, 98),
        textColor: const Color.fromARGB(255, 247, 164, 173),
        fontSize: 16.0,
      );
    } else if (Platform.isWindows) {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    }
  }
}
