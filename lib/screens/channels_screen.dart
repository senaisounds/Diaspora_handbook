import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../models/channel.dart';
import 'chat_screen.dart';
import '../theme/app_theme.dart';

class ChannelsScreen extends StatefulWidget {
  final bool showAppBar;
  const ChannelsScreen({super.key, this.showAppBar = true});

  @override
  State<ChannelsScreen> createState() => _ChannelsScreenState();
}

class _ChannelsScreenState extends State<ChannelsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.purpleBackground,
      appBar: widget.showAppBar ? AppBar(
        backgroundColor: AppTheme.purpleBackground,
        elevation: 0,
        title: Row(
          children: [
            Text(
              'DIASPORA HANDBOOK',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.goldAccent,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.push_pin,
              size: 16,
              color: Colors.red,
            ),
            const SizedBox(width: 4),
            Text(
              '"DH"',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.whiteText,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppTheme.whiteText),
            onPressed: () {
              // Show options menu
            },
          ),
        ],
      ) : null,
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          if (chatProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppTheme.goldAccent,
              ),
            );
          }

          if (chatProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    chatProvider.error!,
                    style: const TextStyle(color: AppTheme.whiteText),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => chatProvider.initialize(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.goldAccent,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final announcements = chatProvider.channels
              .where((c) => c.isAnnouncement)
              .toList();
          final groups = chatProvider.channels
              .where((c) => !c.isAnnouncement)
              .toList();

          return CustomScrollView(
            slivers: [
              // Announcements Section
              if (announcements.isNotEmpty) ...[
                ...announcements.map((channel) => SliverToBoxAdapter(
                      child: _AnnouncementCard(channel: channel),
                    )),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],

              // Groups Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Text(
                    'Groups you can join',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.lightText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              // Groups List
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final channel = groups[index];
                    return _ChannelTile(channel: channel);
                  },
                  childCount: groups.length,
                ),
              ),

              // Add Group Button
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: ElevatedButton(
                    onPressed: () => _showAddGroupDialog(context, chatProvider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.goldAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Add group',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddGroupDialog(BuildContext context, ChatProvider chatProvider) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    String selectedEmoji = '💬';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.purpleBackground,
        title: const Text('Create New Group', style: TextStyle(color: AppTheme.whiteText)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: AppTheme.whiteText),
              decoration: InputDecoration(
                labelText: 'Group Name',
                labelStyle: const TextStyle(color: AppTheme.lightText),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.goldAccent),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.goldAccent, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              style: const TextStyle(color: AppTheme.whiteText),
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: const TextStyle(color: AppTheme.lightText),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.goldAccent),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.goldAccent, width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.lightText)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                await chatProvider.createChannel(
                  name: nameController.text,
                  description: descController.text,
                  icon: selectedEmoji,
                  emoji: selectedEmoji,
                );
                if (context.mounted) Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.goldAccent,
              foregroundColor: Colors.black,
            ),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final Channel channel;

  const _AnnouncementCard({required this.channel});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(channel: channel),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.goldAccent.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.goldAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: AppTheme.goldAccent,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  channel.icon,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    channel.name,
                    style: const TextStyle(
                      color: AppTheme.whiteText,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    channel.description ?? '',
                    style: const TextStyle(
                      color: AppTheme.lightText,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppTheme.goldAccent,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChannelTile extends StatelessWidget {
  final Channel channel;

  const _ChannelTile({required this.channel});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(channel: channel),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppTheme.goldAccent.withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Text(
                  channel.icon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        channel.name,
                        style: const TextStyle(
                          color: AppTheme.whiteText,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        channel.emoji ?? '',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${channel.memberCount} members',
                    style: const TextStyle(
                      color: AppTheme.lightText,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppTheme.goldAccent,
            ),
          ],
        ),
      ),
    );
  }
}

