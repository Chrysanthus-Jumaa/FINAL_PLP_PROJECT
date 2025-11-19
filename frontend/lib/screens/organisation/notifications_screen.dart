import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../providers/app_state.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final notifications = appState.notifications;

        if (notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_none,
                  size: 80,
                  color: AppTheme.lightGray,
                ),
                const SizedBox(height: AppTheme.md),
                Text(
                  'No new notifications',
                  style: AppTheme.h3.copyWith(color: AppTheme.mediumGray),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppTheme.md),
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            
            return Card(
              margin: const EdgeInsets.only(bottom: AppTheme.md),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getNotificationColor(notification.type),
                  child: Icon(
                    _getNotificationIcon(notification.type),
                    color: AppTheme.white,
                  ),
                ),
                title: Text(
                  notification.message,
                  style: AppTheme.bodyLarge,
                ),
                subtitle: Text(
                  _formatTime(notification.createdAt),
                  style: AppTheme.bodySmall,
                ),
                trailing: TextButton(
                  onPressed: () => _markAsRead(context, appState, notification.id),
                  child: const Text('Mark as read'),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'request_accepted':
        return AppTheme.successGreen;
      case 'request_declined':
        return AppTheme.errorRed;
      default:
        return AppTheme.primaryBlue;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'request_accepted':
        return Icons.check_circle;
      case 'request_declined':
        return Icons.cancel;
      default:
        return Icons.notifications;
    }
  }

  String _formatTime(String dateString) {
    final date = DateTime.parse(dateString);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return DateFormat('MMM d, y \'at\' h:mm a').format(date);
    }
  }

  Future<void> _markAsRead(BuildContext context, AppState appState, int notificationId) async {
    await appState.markNotificationRead(notificationId);
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification marked as read')),
      );
    }
  }
}