import 'dart:convert';
import 'dart:io';
import 'package:bullishield/backend_config.dart';
import 'package:bullishield/toasts.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velocity_x/velocity_x.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  ChatBotScreenState createState() => ChatBotScreenState();
}

class ChatBotScreenState extends State<ChatBotScreen> {
  List<Message> messages = [];
  BackendConfiguration backend = BackendConfiguration();
  ShowToasts toast = ShowToasts();


  TextEditingController textEditingController = TextEditingController();

  void sendMessage(String message) async {
    setState(() {
      messages.add(Message(sender: 'You', message: message));
    });
    
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');
    String backendApiURL = backend.getBackendApiURL();

    var getchatbotUrl = "$backendApiURL/chatbot/";
    try{
       final response = await http.post(
          Uri.parse(getchatbotUrl),
          body: json.encode({'user_message': message}),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
       );

       if (response.statusCode == 200) {
        final botResponse = jsonDecode(response.body);
        String botMessage = botResponse['assistant_message'];

        setState(() {
          messages.add(Message(sender: 'Chat Bot', message: botMessage));
        });
      }
      else if(response.statusCode==400){
        if(Platform.isAndroid){
          Fluttertoast.showToast(
            msg: "Please wait a moment and try again later!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.grey[700],
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }else if(Platform.isWindows){
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Please wait a moment and try again later!"),
            ));
        }
      }
    }catch(error,traceback){
      print(traceback);
      toast.showErrorToast('Failed to fetch complain details');
    }
       
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bullishield Bot'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Bullishield Bot is a chatbot that can help you overcome the trauma of cyberbullying. Feel free to explain your problems and to seek help. Together we can be a shield to cyberbullying.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.grey.shade200,
                      child: const Text(
                        'Bullishield Bot',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          return MessageBubble(
                            sender: messages[index].sender,
                            message: messages[index].message,
                          );
                        },
                      ),
                    ),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: Colors.grey.shade200,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: textEditingController,
                              decoration: const InputDecoration(
                                hintText: 'Type your message...',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              String message = textEditingController.text;
                              if (message.isNotEmpty) {
                                sendMessage(message);
                                textEditingController.clear();
                              }
                            },
                            child: const Text('Send'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Message {
  final String sender;
  final String message;

  Message({required this.sender, required this.message});
}

class MessageBubble extends StatelessWidget {
  final String sender;
  final String message;

  const MessageBubble({super.key, 
    required this.sender,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(message),
        ],
      ),
    );
  }
}
