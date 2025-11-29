import 'package:flutter/material.dart';



class PostScreen extends StatelessWidget {
  const PostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
      ),
      body: const Center(
        child: Text('Post Creation Screen'),
      ),
    );
  }
}