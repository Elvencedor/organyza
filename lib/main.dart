import "package:flutter/material.dart";
import "./chatPage.dart";

void main () => runApp(Home());

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat',
      home: ChatPage()
    );
  }
}
