import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../theme/theme_data.dart';
import '../../services/notification_service.dart';
import '../../data/models/notification_model.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationService>().refresh();
    });
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(dt);
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'booking':
      case 'status':
        return Icons.build_circle_rounded;
      case 'chat':
        return Icons.chat_bubble_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _colorFor(String type) {
    switch (type) {
      case 'status':
        return Theme.of(context).colorScheme.primary;
      case 'booking':
        return Colors.blue;
      case 'chat':
        return Colors.green;
      default:
        return AppTheme.textGray;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Notifications',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.titleTextStyle?.color ?? Theme.of(context).colorScheme.onSurface,
        centerTitle: true,
        actions: [
          Consumer<NotificationService>(
            builder: (_, svc, __) => svc.unreadCount > 0
                ? TextButton(
                    onPressed: svc.markAllRead,
                    child: Text('Mark all read',
                        style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 13)),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: Consumer<NotificationService>(
        builder: (_, svc, __) {
          final notifs = svc.notifications;
          if (notifs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.notifications_none_rounded,
                        size: 56, color: Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(height: 20),
                  Text('No notifications yet',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface)),
                  const SizedBox(height: 8),
                  Text('Booking status updates will appear here',
                      style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: Theme.of(context).colorScheme.primary,
            onRefresh: svc.refresh,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: notifs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 2),
              itemBuilder: (context, index) {
                final n = notifs[index];
                return _NotifTile(
                  notification: n,
                  icon: _iconFor(n.type),
                  iconColor: _colorFor(n.type),
                  timeAgo: _timeAgo(n.createdAt),
                  onTap: () => svc.markRead(n.id),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final NotificationModel notification;
  final IconData icon;
  final Color iconColor;
  final String timeAgo;
  final VoidCallback onTap;

  const _NotifTile({
    required this.notification,
    required this.icon,
    required this.iconColor,
    required this.timeAgo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.read;
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        decoration: BoxDecoration(
          color: isUnread 
              ? (Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor) 
              : (Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor).withOpacity(0.6),
          borderRadius: BorderRadius.circular(14),
          border: Border(
            left: BorderSide(
              color: isUnread ? iconColor : Colors.transparent,
              width: 4,
            ),
          ),
          boxShadow: isUnread
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isUnread ? FontWeight.w600 : FontWeight.w400,
                        color: isUnread 
                            ? Theme.of(context).colorScheme.onSurface 
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(timeAgo,
                        style: TextStyle(
                            fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              if (isUnread)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 4, left: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
