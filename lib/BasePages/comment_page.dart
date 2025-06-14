import 'package:flutter/material.dart';
import 'package:omnirate/BasePages/Assets/animated_entry.dart';
import 'package:omnirate/Database/model_entry.dart';
import 'package:omnirate/Shared/utils.dart';

class CommentPage extends StatefulWidget {
    // ===== Input Variables ===== //
  final MediaEntry inEntry;

  // ===== Constructor ===== //
  const CommentPage({Key? key, required this.inEntry}) : super(key: key);
  
  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final _textController = TextEditingController();

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Container(
      decoration: BoxDecoration(gradient: gradientBackground(context)),

      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 80, 8, 0),
        child: Column(
          children: [
AnimatedBackgroundCard(inEntry: widget.inEntry, commentPage: true,),
            Expanded(
              child: ListView.builder(
                itemCount: 10, // Replace with actual comments
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('Comment $index'),
                    subtitle: Text('This is a sample comment'),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  labelText: 'Write a comment',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
            ),

            ElevatedButton(
              onPressed: () {
                print(_textController.text);
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    ),
  );
}

}