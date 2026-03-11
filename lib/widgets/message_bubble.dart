import 'dart:convert'; 
import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble.first({
    super.key,
    required this.userImage,
    required this.username,
    required this.message,
    required this.isMe,
  }) : isFirstInSequence = true;

  const MessageBubble.next({
    super.key,
    required this.message,
    required this.isMe,
  })  : isFirstInSequence = false,
        userImage = null,
        username = null;

  final bool isFirstInSequence;
  final String? userImage;
  final String? username;
  final String message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
   
    const actionGreen = Color(0xFF4A775C); 

    return Stack(
      children: [
        if (userImage != null)
          Positioned(
            top: 10, 
            right: isMe ? 0 : null,
            left: isMe ? null : 0, 
            child: CircleAvatar(
              backgroundImage: userImage!.startsWith('data:image')
                  ? MemoryImage(base64Decode(userImage!.split(',')[1])) as ImageProvider
                  : NetworkImage(userImage!),
              backgroundColor: actionGreen.withOpacity(0.2),
              radius: 17, 
            ),
          ),
        Container(
          width: double.infinity, 
          margin: const EdgeInsets.symmetric(horizontal: 42), 
          child: Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (isFirstInSequence) const SizedBox(height: 12), 
              if (username != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    username!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12, 
                      color: Color(0xFF1A202C), 
                    ),
                  ),
                ),
              Container(
                decoration: BoxDecoration(
                  color: isMe ? actionGreen : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: !isMe && isFirstInSequence ? Radius.zero : const Radius.circular(14),
                    topRight: isMe && isFirstInSequence ? Radius.zero : const Radius.circular(14),
                    bottomLeft: const Radius.circular(14),
                    bottomRight: const Radius.circular(14),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                constraints: const BoxConstraints(maxWidth: 240),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12), 
                margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8), 
                child: Text(
                  message,
                  style: TextStyle(
                    height: 1.2, 
                    color: isMe ? Colors.white : const Color(0xFF1A202C),
                    fontSize: 13.5, 
                    fontWeight: FontWeight.w600,
                  ),
                  softWrap: true,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}