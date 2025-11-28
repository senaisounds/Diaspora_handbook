import 'package:flutter/material.dart';
import 'feed_screen.dart';
import 'channels_screen.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Community'),
          bottom: const TabBar(
            indicatorColor: Color(0xFFFFD700),
            labelColor: Color(0xFFFFD700),
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'Social Feed'),
              Tab(text: 'Chat Groups'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            FeedScreen(),
            ChannelsScreen(showAppBar: false), // Need to update ChannelsScreen to accept this
          ],
        ),
      ),
    );
  }
}

