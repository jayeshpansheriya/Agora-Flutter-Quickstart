import 'package:agora_flutter_quickstart/src/chat/Message.dart';
import 'package:agora_flutter_quickstart/src/utils/settings.dart';
import 'package:agora_rtm/agora_rtm.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyChatScreen extends StatefulWidget {
  const MyChatScreen({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyChatState createState() => new _MyChatState();
}

class _MyChatState extends State<MyChatScreen> {
  final List<Message> _messages = <Message>[];

  // Create a text controller. We will use it to retrieve the current value
  // of the TextField!
  final _textController = TextEditingController();

  bool _isLogin = false;
  bool _isInChannel = false;
  String userName;


  AgoraRtmClient _client;
  AgoraRtmChannel _channel;


  static TextStyle textStyle = TextStyle(fontSize: 18, color: Colors.blue);

  final _userNameController = TextEditingController();
  final _channelNameController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    DateTime time = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd hh:mm').format(time);


    return new Scaffold(
        appBar: new AppBar(
          title: const Text(
            'Chat App',

            textAlign: TextAlign.center,
          ),
        ),
        body: _isLogin && _isInChannel ? Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white,
            child: new Container(
              child: new Column(
                children: <Widget>[
                  //Chat list
                  new Flexible(
                    child: new ListView.builder(
                      padding: new EdgeInsets.all(8.0),
                      reverse: true,
                      itemBuilder: (_, int index) => _messages[index],
                      itemCount: _messages.length,
                    ),
                  ),
                  new Divider(height: 1.0),
                  new Container(
                      decoration:
                      new BoxDecoration(color: Theme
                          .of(context)
                          .cardColor),
                      child: new IconTheme(
                          data: new IconThemeData(
                              color: Theme
                                  .of(context)
                                  .accentColor),
                          child: new Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2.0),
                            child: new Row(
                              children: <Widget>[
                                //left send button

//                                new Container(
//                                  width: 48.0,
//                                  height: 48.0,
//                                  child: new IconButton(
//                                      icon: Image.asset(
//                                          "assets/images/send_in.png"),
//                                      onPressed: () => _sendMsg(
//                                          _textController.text,
//                                          'left',
//                                          formattedDate)),
//                                ),

                                //Enter Text message here
                                new Flexible(
                                  child: new TextField(
                                    controller: _textController,
                                    decoration: new InputDecoration.collapsed(
                                        hintText: "Enter message"),
                                  ),
                                ),

                                //right send button

                                new Container(
                                  margin:
                                  new EdgeInsets.symmetric(horizontal: 2.0),
                                  width: 48.0,
                                  height: 48.0,
                                  child: new IconButton(
                                      icon: Image.asset(
                                          "assets/images/send_out.png"),
                                      onPressed: _toggleSendChannelMessage
                                  ),
                                ),
                              ],
                            ),
                          ))),
                ],
              ),
            )) : Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              _buildLogin(),
              _buildJoinChannel(),
            ],
          ),
        )
    );
  }

  Widget _buildJoinChannel() {
    if (!_isLogin) {
      return Container();
    }
    return Row(children: <Widget>[
      _isInChannel
          ? new Expanded(
          child: new Text('Channel: ' + _channelNameController.text,
              style: textStyle))
          : new Expanded(
          child: new TextField(
              controller: _channelNameController,
              decoration: InputDecoration(hintText: 'Input channel id'))),
      new OutlineButton(
        child: Text(_isInChannel ? 'Leave Channel' : 'Join Channel',
            style: textStyle),
        onPressed: _toggleJoinChannel,
      )
    ]);
  }


  void _toggleJoinChannel() async {
    if (_isInChannel) {
      try {
        await _channel.leave();
        //_log('Leave channel success.');
        _client.releaseChannel(_channel.channelId);
        //_channelMessageController.text = null;

        setState(() {
          _isInChannel = false;
        });
      } catch (errorCode) {
        //_log('Leave channel error: ' + errorCode.toString());
      }
    } else {
      String channelId = _channelNameController.text;
      if (channelId.isEmpty) {
        // _log('Please input channel id to join.');
        return;
      }

      try {
        _channel = await _createChannel(channelId);
        await _channel.join();
        //_log('Join channel success.');

        setState(() {
          _isInChannel = true;
        });
      } catch (errorCode) {
        //_log('Join channel error: ' + errorCode.toString());
      }
    }
  }

  Future<AgoraRtmChannel> _createChannel(String name) async {
    AgoraRtmChannel channel = await _client.createChannel(name);
    channel.onMemberJoined = (AgoraRtmMember member) {
//      _log(
//          "Member joined: " + member.userId + ', channel: ' + member.channelId);
    };
    channel.onMemberLeft = (AgoraRtmMember member) {
      //  _log("Member left: " + member.userId + ', channel: ' + member.channelId);
    };
    channel.onMessageReceived =
        (AgoraRtmMessage message, AgoraRtmMember member) {
      DateTime time = DateTime.now();
      String formattedDate = DateFormat('yyyy-MM-dd hh:mm').format(time);
      _sendMsg(
          message.text,
          'left',
          formattedDate);

      // _log("Channel msg: " + member.userId + ", msg: " + message.text);
    };
    return channel;
  }

  Widget _buildLogin() {
    return Row(children: <Widget>[
      _isLogin
          ? new Expanded(
          child: new Text('User Id: ' + _userNameController.text,
              style: textStyle))
          : new Expanded(
          child: new TextField(
              controller: _userNameController,
              decoration: InputDecoration(hintText: 'Input your user id'))),
      new OutlineButton(
        child: Text(_isLogin ? 'Logout' : 'Login', style: textStyle),
        onPressed: _toggleLogin,
      )
    ]);
  }

  void _toggleLogin() async {
    if (_isLogin) {
      try {
        await _client.logout();
        //_log('Logout success.');

        setState(() {
          _isLogin = false;
          _isInChannel = false;
        });
      } catch (errorCode) {
        //_log('Logout error: ' + errorCode.toString());
      }
    } else {
      String userId = _userNameController.text;
      if (userId.isEmpty) {
        //_log('Please input your user id to login.');
        return;
      }

      try {
        await _client.login(null, userId);
        //_log('Login success: ' + userId);
        setState(() {
          _isLogin = true;
          userName = userId;
        });
      } catch (errorCode) {
        // _log('Login error: ' + errorCode.toString());
      }
    }
  }

  void _sendMsg(String msg, String messageDirection, String date) {
    if (msg.length == 0) {

    } else {
      _textController.clear();
      Message message = new Message(
        msg: msg,
        direction: messageDirection,
        dateTime: date,
      );
      setState(() {
        _messages.insert(0, message);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _createClient();
  }


  void _createClient() async {
    _client =
    await AgoraRtmClient.createInstance(APP_ID);
    _client.onMessageReceived = (AgoraRtmMessage message, String peerId) {
      //_log("Peer msg: " + peerId + ", msg: " + message.text);
    };
    _client.onConnectionStateChanged = (int state, int reason) {
//      _log('Connection state changed: ' +
//          state.toString() +
//          ', reason: ' +
//          reason.toString());
      if (state == 5) {
        _client.logout();
        // _log('Logout.');
        setState(() {
          _isLogin = false;
        });
      }
    };
  }

  @override
  void dispose() {
    // Every listener should be canceled, the same should be done with this stream.
    // Clean up the controller when the Widget is disposed
    _textController.dispose();
    super.dispose();
  }

  void _toggleSendChannelMessage() async {
    DateTime time = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd hh:mm').format(time);
    String text = _textController.text;
    if (text.isEmpty) {
      //_log('Please input text to send.');
      return;
    }
    try {
      await _channel.sendMessage(AgoraRtmMessage.fromText(text));
      _sendMsg(
          _textController.text,
          'right',
          formattedDate);
      //_log('Send channel message success.');
    } catch (errorCode) {
      //_log('Send channel message error: ' + errorCode.toString());
    }
  }
}