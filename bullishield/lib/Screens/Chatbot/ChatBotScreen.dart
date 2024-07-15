import 'dart:convert';
import 'package:bullishield/Screens/Login/login_screen.dart';
import 'package:bullishield/backend_config.dart';
import 'package:bullishield/constants.dart';
import 'package:bullishield/toasts.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
class ChatBotScreen extends StatefulWidget {
  final String userImageURL;
  const ChatBotScreen({super.key, required this.userImageURL});

  @override
  ChatBotScreenState createState() => ChatBotScreenState();
}

class ChatBotScreenState extends State<ChatBotScreen> {
  List<Message> messages = [];
  BackendConfiguration backend = BackendConfiguration();
  ShowToasts toast = ShowToasts();
  TextEditingController textEditingController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  bool _isLoading = false; // Loading state variable

  @override
  void initState() {
    super.initState();
    retrieveMessages();
  }

  void retrieveMessages() async {
    setState(() {
      _isLoading = true; // Start loading
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');
    String backendApiURL = backend.getBackendApiURL();

    var getchatbotUrl = "$backendApiURL/chatbot/";
    try {
      final response = await http.get(
        Uri.parse(getchatbotUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        List userPreviousMessage = responseData['user_chat_list'];
        List userPreviousMessageReversed =
            userPreviousMessage.reversed.toList();
        List assistantPreviousMessage = responseData['assistant_chat_list'];
        List assistantPreviousMessageReversed =
            assistantPreviousMessage.reversed.toList();
        int maxLength =
            userPreviousMessageReversed.length > assistantPreviousMessageReversed.length
                ? userPreviousMessageReversed.length
                : assistantPreviousMessageReversed.length;

        setState(() {
          // set for user messages
          for (int i = 0; i < maxLength; i++) {
            if (i < userPreviousMessageReversed.length) {
              messages
                  .add(Message(sender: 'You', message: userPreviousMessageReversed[i]));
            }
            if (i < assistantPreviousMessageReversed.length) {
              messages.add(Message(
                  sender: 'Chat Bot', message: assistantPreviousMessageReversed[i]));
            }
          }
          _isLoading = false; // End loading
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });

        toast.showSuccessToast(responseData['msg']);
      } else if (response.statusCode == 401) {
        setState(() {
          _isLoading = false; // End loading
        });
        toast.showErrorToast(responseData['msg']);
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else if (response.statusCode == 400) {
        setState(() {
          _isLoading = false; // End loading
        });
        toast.showErrorToast(responseData['msg']);
      } else {
        setState(() {
          _isLoading = false; // End loading
        });
        toast.showErrorToast(
            'Failed to fetch Bullishield bot. Try again later!');
        Navigator.pop(context);
      }
    } catch (error, traceback) {
      setState(() {
        _isLoading = false; // End loading
      });
      print(traceback);
      toast.showErrorToast('Failed to fetch complain details');
    }
  }

  void sendMessage(String message) async {
    setState(() {
      messages.add(Message(sender: 'You', message: message));
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');
    String backendApiURL = backend.getBackendApiURL();

    var getchatbotUrl = "$backendApiURL/chatbot/";
    try {
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
        String message = botResponse['msg'];
        setState(() {
          messages.add(Message(sender: 'Chat Bot', message: message));
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      } else if (response.statusCode == 401) {
        toast.showErrorToast(message);
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else if (response.statusCode == 400) {
        toast.showErrorToast(message);
      } else {
        toast.showErrorToast(
            'Failed to fetch Bullishield bot. Try again later!');
        Navigator.pop(context);
      }
    } catch (error, traceback) {
      print(traceback);
      toast.showErrorToast('Failed to fetch complain details');
    }
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bullishield Bot',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: kPrimaryColor,
      ),
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            controller: _scrollController,
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              return MessageBubble(
                                sender: messages[index].sender,
                                message: messages[index].message,
                                userImageURL: widget.userImageURL,
                              );
                            },
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          color: Colors.grey.shade200,
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: textEditingController,
                                  decoration: const InputDecoration(
                                    hintText: "Let's talk...",
                                    border: UnderlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: const CircleBorder(),
                                  backgroundColor: kPrimaryColor,
                                  padding: const EdgeInsets.all(16),
                                ),
                                onPressed: () {
                                  String message = textEditingController.text;
                                  if (message.isNotEmpty) {
                                    sendMessage(message);
                                    textEditingController.clear();
                                  }
                                },
                                child: const Icon(
                                  Icons.send,
                                  color: Colors.white,
                                ),
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
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
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
  final String userImageURL;

  const MessageBubble({
    super.key,
    required this.sender,
    required this.message,
    required this.userImageURL,
  });

  @override
  Widget build(BuildContext context) {
    bool isBot = sender == 'Chat Bot';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isBot)
            const CircleAvatar(
              backgroundImage: AssetImage('assets/images/chat-bot.png'),
            ),
          if (isBot) const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  isBot ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: isBot ? Colors.blue : kPrimaryColor,
                    borderRadius: BorderRadius.circular(12),
                    border:
                        isBot ? Border.all(color: Colors.grey.shade300) : null,
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!isBot) const SizedBox(width: 10),
          if (!isBot)
            CircleAvatar(
              backgroundImage: NetworkImage(userImageURL),
            ),
        ],
      ),
    );
  }
}
