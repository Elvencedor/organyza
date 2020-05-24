import "dart:convert";

import "package:flutter/material.dart";
import "package:flutter_socket_io/flutter_socket_io.dart";
import "package:flutter_socket_io/socket_io_manager.dart";

class ChatPage extends StatefulWidget {
  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  SocketIO socket;
  List<String> messages;
  double height,width;
  TextEditingController textController;
  ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    messages = List<String>();
    textController = TextEditingController();
    scrollController = ScrollController();

    socket = SocketIOManager().createSocketIO('https://duplex-chat.herokuapp.com/', '/');
    socket.init();
    socket.subscribe('receive_message', (jsonData) {
      Map<String, dynamic> data = json.decode(jsonData);
      this.setState(() => messages.add(data['message']));
      scrollController.animateTo(
        scrollController.position.maxScrollExtent, 
        duration: Duration(milliseconds: 600), 
        curve: Curves.ease
      );

    });

    socket.connect();
  }

  Widget buildSingleMessage(int index) {
    return Container(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        margin: const EdgeInsets.only(bottom: 20.0,left: 20.0),
        decoration: BoxDecoration(
          color: Colors.purple,
          borderRadius: BorderRadius.circular(20.0)
        ),
        child: Text(
          messages[index],
          style: TextStyle(color: Colors.white, fontSize: 15.0),
        ),
      )
    );
  }

  Widget messageList(){
    return Container(
      height: height * 0.8,
      width: width,
      child: ListView.builder(
        controller: scrollController,
        itemCount: messages.length,
        itemBuilder: (BuildContext context, int index) {
          return buildSingleMessage(index);
        }
      )
    );
  }

  Widget buildChatInput() {
    return Container(
      width: width * 0.7,
      padding: const EdgeInsets.all(20.0),
      margin: const EdgeInsets.only(left: 40.0),
      child: TextField(
        decoration: InputDecoration.collapsed(hintText: 'Send a message...'),
        controller: textController
      ),
    );
  }

  Widget buildSendButton() {
    return FloatingActionButton(
      backgroundColor: Colors.deepPurple,
      onPressed: () {
        if(textController.text.isNotEmpty) {
          socket.sendMessage('send_message', json.encode({'message': textController.text}));
          this.setState(()=>messages.add(textController.text));
          textController.text = '';
          scrollController.animateTo(
            scrollController.position.maxScrollExtent, 
            duration: Duration(milliseconds: 600), 
            curve: Curves.ease
          );
        }
      },
      child: Icon(Icons.send, size: 30),
    );
  }

  Widget buildInputArea() {
    return Container(
      height: height * 0.1,
      width: width,
      child: Row(
        children: <Widget>[
          buildChatInput(),
          buildSendButton()
        ],
      ),
    );
  }

  @override
  Widget  build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            messageList(),
            buildInputArea()
          ],
        ),
      ),
    );
  }
}
