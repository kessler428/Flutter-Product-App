import 'package:flutter/material.dart';

class NotificationService {

  static late GlobalKey<ScaffoldMessengerState> messengerKey = GlobalKey();

  static showSnackBar( String message ){

    final snackBar = SnackBar(
      content: Text (message, style: const TextStyle( color: Colors.white, fontSize: 20))
    );

    messengerKey.currentState!.showSnackBar(snackBar);
  }

}