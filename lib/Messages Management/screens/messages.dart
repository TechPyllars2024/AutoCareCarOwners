import 'package:flutter/material.dart';

import 'chatScreen.dart';

class CarOwnerMessagesScreen extends StatefulWidget {
  const CarOwnerMessagesScreen({super.key, this.child});

  final Widget? child;

  @override
  State<CarOwnerMessagesScreen> createState() => _CarOwnerMessagesScreenState();
}

class _CarOwnerMessagesScreenState extends State<CarOwnerMessagesScreen> {
  // Mock data for conversations
  final List<Map<String, String>> conversations = [
    {
      'name': 'John Doe',
      'lastMessage': 'Hey, how are you?',
      'time': '10:30 AM',
    },
    {
      'name': 'Jane Smith',
      'lastMessage': 'Can we reschedule our meeting?',
      'time': '9:15 AM',
    },
    {
      'name': 'Mike Johnson',
      'lastMessage': 'Sure, let me check my calendar. Make sure that day will cool and fun.',
      'time': 'Yesterday',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Messages',
        style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black)),
      ),
      body: ListView.builder(
        itemCount: conversations.length,
        itemBuilder: (context, index) {
          final conversation = conversations[index];
          return ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.orange,
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text(
              conversation['name']!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              conversation['lastMessage']!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              conversation['time']!,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            onTap: () {
              // Navigate to the chat screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatScreen(serviceProviderUid: '', conversationId: '')
                ),
              );
            },
          );
        },
      ),
    );
  }
}
