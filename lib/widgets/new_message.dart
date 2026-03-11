import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  // Logic ส่งข้อความเดิม 
  void _submitMessage() async {
    final enteredMessage = _messageController.text;
    
    
    if (enteredMessage.trim().isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Type a message first.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    _messageController.clear();

    final user = FirebaseAuth.instance.currentUser!;
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    FirebaseFirestore.instance.collection('chat').add({
      'text': enteredMessage,
      'createdAt': Timestamp.now(),
      'userId': user.uid,
      'username': userData.data()!['username'],
      'userImage': userData.data()!['image_url'],
    });
  }

  @override
  Widget build(BuildContext context) {
    const actionGreen = Color(0xFF4A775C);

    return SafeArea(
      bottom: true, 
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8, top: 8), 
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _messageController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Send a message...',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), 
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              height: 48, 
              width: 48,
              decoration: const BoxDecoration(
                color: actionGreen,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                color: Colors.white,
                icon: const Icon(Icons.send_rounded, size: 22), 
                onPressed: _submitMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}