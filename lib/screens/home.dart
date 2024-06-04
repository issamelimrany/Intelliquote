import 'package:dart_openai/openai.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../hive_model/chat_item.dart';
import 'chat_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<ChatItem> chats = [];

  @override
  void initState() {
    super.initState();
    setApiKeyOnStartup();
  }

  void setApiKeyOnStartup() {
    OpenAI.apiKey = spOpenApiKey;
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Quotey', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ValueListenableBuilder(
          valueListenable: Hive.box('chats').listenable(),
          builder: (context, box, _) {
            if (box.isEmpty) {
              return const Center(
                child: Text(
                  "No inspiration so far!",
                  style: TextStyle(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey),
                ),
              );
            }
            return ListView.builder(
              itemCount: box.length,
              itemBuilder: (context, index) {
                final chatItem = box.getAt(index) as ChatItem;
                return Card(
                  color: Colors.white,
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(
                      chatItem.title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) {
                        return ChatPage(chatItem: chatItem);
                      }));
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () {
                        box.deleteAt(index);
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final TextEditingController titleController = TextEditingController();

          // Show a dialog to get the chat title from the user
          final String? newChatTitle = await showDialog<String>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Make this session unique !'),
                content: TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                      hintText: 'choose a name for this session'),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pop(); // Close the dialog without returning a value
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(
                          titleController.text); // Return the entered title
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );

          if (newChatTitle != null && newChatTitle.isNotEmpty) {
            // create hive object
            final messagesBox = Hive.box('messages');
            var chatItem = ChatItem(newChatTitle, HiveList(messagesBox));

            // add to hive
            Hive.box('chats').add(chatItem);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatPage(chatItem: chatItem),
              ),
            );
          }
        },
        label: const Text('I need inspiration'),
        icon: const Icon(Icons.message_outlined),
        backgroundColor: Colors.lightBlueAccent,
      ),
    );
  }
}
