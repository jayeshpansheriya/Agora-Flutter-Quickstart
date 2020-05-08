import 'package:agora_flutter_quickstart/chat.dart';
import 'package:agora_flutter_quickstart/src/chat/ChatScreen.dart';
import 'package:flutter/material.dart';
import './src/pages/index.dart';

void main() => runApp(MaterialApp(home: MyApp()));

class MyApp extends StatelessWidget {

  static TextStyle textStyle = TextStyle(fontSize: 18, color: Colors.blue);


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(title: Text("Agora"),),
        body: Container(
          child: Column(
            
            children: <Widget>[
            RaisedButton(
              child: Text('Video Broadcasting',
                  style: textStyle),
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=> IndexPage()));
              },
            ),

            RaisedButton(
              child: Text("Chat",
                  style: textStyle),
              onPressed:() =>
                Navigator.push(context, MaterialPageRoute(builder: (context) => MyChatScreen()))

            )
          ],),
        ),
      ),
    );
  }
}
