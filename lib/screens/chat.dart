import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_app/widgets/chat_messages.dart';
import 'package:chat_app/widgets/new_message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    //Signature 
    const actionGreen = Color(0xFF48825F);
    const bgColor = Color(0xFFF0F7F4);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(

        //Icon 
        title: Row(
          children: [
            const Icon(
              Icons.radar, 
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12), 
            const Text(
              'The Intelligence HUB',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 18, 
              ),
            ),
          ],
        ),
        backgroundColor: actionGreen,
        centerTitle: false,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => FirebaseAuth.instance.signOut(),
            icon: const Icon(
              Icons.exit_to_app_rounded,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: const Column(
        children: [
          Expanded(
            child: ChatMessages(),
          ),
          NewMessage(),
        ],
      ),
    );
  }
}