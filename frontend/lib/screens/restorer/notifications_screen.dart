import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../providers/app_state.dart';
import '../../widgets/common/loading_indicator.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        if (appState.isLoading) {
          return const LoadingIndicator(message: 'Loading notifications...');
        }

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
                const SizedBox(height: AppTheme.sm),
                Text(
                  'You\'ll be notified when organizations request your land',
                  style: AppTheme.bodyMedium.copyWith(color: AppTheme.mediumGray),
                  textAlign: TextAlign.center,
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
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getNotificationColor(notification.type).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getNotificationIcon(notification.type),
                    color: _getNotificationColor(notification.type),
                  ),
                ),
                title: Text(
                  notification.message,
                  style: AppTheme.bodyLarge,
                ),
                subtitle: Text(
                  _formatTimestamp(notification.createdAt),
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

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'new_request':
        return Icons.notification_important;
      case 'request_accepted':
        return Icons.check_circle;
      case 'request_declined':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'new_request':
        return AppTheme.primaryBlue;
      case 'request_accepted':
        return AppTheme.successGreen;
      case 'request_declined':
        return AppTheme.errorRed;
      default:
        return AppTheme.mediumGray;
    }
  }

  String _formatTimestamp(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return DateFormat('MMM dd, yyyy - HH:mm').format(dateTime);
    }
  }

  Future<void> _markAsRead(BuildContext context, appState, int notificationId) async {
    await appState.markNotificationRead(notificationId);
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification marked as read')),
      );
    }
  }
}