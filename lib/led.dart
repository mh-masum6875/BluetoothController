import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:control_button/control_button.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ChatPage extends StatefulWidget {
  final BluetoothDevice server;

  const ChatPage({this.server});

  @override
  _ChatPage createState() => new _ChatPage();
}

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

class _ChatPage extends State<ChatPage> {
  static final clientID = 0;
  BluetoothConnection connection;

  List<_Message> messages = List<_Message>();
  String _messageBuffer = '';

  final TextEditingController textEditingController =
      new TextEditingController();
  final ScrollController listScrollController = new ScrollController();

  bool isConnecting = true;
  bool get isConnected => connection != null && connection.isConnected;

  bool isDisconnecting = false;

  @override
  void initState() {
    super.initState();

    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection.input.listen(_onDataReceived).onDone(() {
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {
            //
          });
        }
      });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print('error is here ===> $error');

      Fluttertoast.showToast(
          msg: "Error is $error",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection.dispose();
      connection = null;
    }

    super.dispose();
  }

  double _value = 90.0;
  @override
  Widget build(BuildContext context) {
    final List<Row> list = messages.map((_message) {
      return Row(
        children: <Widget>[
          Container(
            child: Text(
                (text) {
                  return text == '/shrug' ? '¯\\_(ツ)_/¯' : text;
                }(_message.text.trim()),
                style: TextStyle(color: Colors.white)),
            padding: EdgeInsets.all(12.0),
            margin: EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
            width: 222.0,
            decoration: BoxDecoration(
                color: _message.whom == clientID
                    ? Colors.greenAccent
                    : Colors.grey,
                borderRadius: BorderRadius.circular(7.0)),
          ),
        ],
        mainAxisAlignment: _message.whom == clientID
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
          title: (isConnecting
              ? Text('Connecting chat to ' + widget.server.name + '...')
              : isConnected
                  ? Text('Live chat with ' + widget.server.name)
                  : Text('Chat log with ' + widget.server.name))),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 100,
            ),
            //route shape button control from here
            ControlButton(
              sectionOffset: FixedAngles.Zero,
              externalDiameter: 300,
              internalDiameter: 120,
              dividerColor: Colors.greenAccent,
              elevation: 2,
              externalColor: Colors.green[500],
              internalColor: Colors.grey[300],
              mainAction: () {
                _sendMessage('3');
              },
              sections: [
                () => _sendMessage('!r30'),
                () => _sendMessage('!f60'),
                () => _sendMessage('!l30'),
                () => _sendMessage('!f00'),
                () => _sendMessage('!b60'),
                () => _sendMessage('!f00'),
              ],
            ),
            Flexible(
              child: ListView(
                  padding: const EdgeInsets.all(12.0),
                  controller: listScrollController,
                  children: list),
            ),
            Row(
              children: <Widget>[
                Flexible(
                  child: Container(
                    margin: const EdgeInsets.only(left: 16.0),
                    child: TextField(
                      style: const TextStyle(fontSize: 15.0),
                      controller: textEditingController,
                      decoration: InputDecoration.collapsed(
                        hintText: isConnecting
                            ? 'Wait until connected...'
                            : isConnected
                                ? 'Type your message...'
                                : 'Chat got disconnected',
                        hintStyle: const TextStyle(color: Colors.grey),
                      ),
                      enabled: isConnected,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(8.0),
                  child: IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: isConnected
                          ? () => _sendMessage(textEditingController.text)
                          : null),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _onDataReceived(Uint8List data) {
    print('_onDataReceived');
    print(data);
    String dataString =
        String.fromCharCodes(data); // Dec -> char // Hex -> value
    // String dataString = 'Test dataString';
    print('dataString: ' + dataString);

    String msg = '';
    switch (dataString) {
      case '#0':
        msg = 'Battery LOW';
        break;
      case '#1':
        msg = 'Battery HIGH';
        break;
    }

    if (msg == '' || msg == null) {
      String _dataString = dataString.substring(1);
      if (dataString.contains('+')) {
        // determine left / right sensor == 1
        // #0+0, #1+0, #0+1, #1+1
        List<String> sensors = _dataString.split('+');

        if (sensors[0] == '1' && sensors[1] == '1') {
          msg = 'Collision Detected';
        } else if (sensors[0] == '0' && sensors[1] == '1') {
          msg = 'Collision Detected right Side';
        } else if (sensors[0] == '1' && sensors[1] == '0') {
          msg = 'Collision Detected left Side';
        } else {
          msg = 'No Collision Detected';
        }
      } else {
        msg = _dataString + ' cm';
      }
    }
    print('msg: ' + msg);

    setState(() {
      messages.add(
        _Message(1, msg),
      );
    });

    // // Allocate buffer for parsed data
    // int backspacesCounter = 0;
    // data.forEach((byte) {
    //   if (byte == 8 || byte == 127) {
    //     backspacesCounter++; //8 == Backspace, 127 == Delete
    //   }
    // });
    // Uint8List buffer = Uint8List(data.length - backspacesCounter);
    // int bufferIndex = buffer.length;

    // // Apply backspace control character
    // backspacesCounter = 0;
    // for (int i = data.length - 1; i >= 0; i--) {
    //   if (data[i] == 8 || data[i] == 127) {
    //     backspacesCounter++;
    //   } else {
    //     if (backspacesCounter > 0) {
    //       backspacesCounter--;
    //     } else {
    //       buffer[--bufferIndex] = data[i];
    //     }
    //   }
    // }

    // // Create message if there is new line character
    // String dataString = String.fromCharCodes(buffer);
    // int index = buffer.indexOf(13);
    // if (~index != 0) {
    //   setState(() {
    //     messages.add(
    //       _Message(
    //         1,
    //         backspacesCounter > 0
    //             ? _messageBuffer.substring(
    //                 0, _messageBuffer.length - backspacesCounter)
    //             : _messageBuffer + dataString.substring(0, index),
    //       ),
    //     );
    //     _messageBuffer = dataString.substring(index);
    //   });
    // } else {
    //   _messageBuffer = (backspacesCounter > 0
    //       ? _messageBuffer.substring(
    //           0, _messageBuffer.length - backspacesCounter)
    //       : _messageBuffer + dataString);
    // }
  }

  void _sendMessage(String text) async {
    text = text.trim();
    textEditingController.clear();

    if (text.length > 0) {
      try {
        connection.output.add(utf8.encode(text + "\r\n"));
        await connection.output.allSent;

        setState(() {
          messages.add(_Message(clientID, text));
        });

        Future.delayed(Duration(milliseconds: 333)).then((_) {
          listScrollController.animateTo(
              listScrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 333),
              curve: Curves.easeOut);
        });
      } catch (e) {
        // Ignore error, but notify state
        print('error ===>$e');
        setState(() {});
      }
    }
  }
}
