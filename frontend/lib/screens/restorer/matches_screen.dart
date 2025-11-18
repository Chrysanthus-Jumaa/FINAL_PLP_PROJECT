import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../providers/app_state.dart';
import '../../widgets/common/loading_indicator.dart';
import 'match_detail_screen.dart';

class MatchesScreen extends StatelessWidget {
  const MatchesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        if (appState.isLoading) {
          return const LoadingIndicator(message: 'Loading matches...');
        }

        final matchRequests = appState.matchRequests;

        if (matchRequests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.handshake_outlined,
                  size: 80,
                  color: AppTheme.lightGray,
                ),
                const SizedBox(height: AppTheme.md),
                Text(
                  'No match requests yet',
                  style: AppTheme.h3.copyWith(color: AppTheme.mediumGray),
                ),
                const SizedBox(height: AppTheme.sm),
                Text(
                  'When organizations request your land, they will appear here',
                  style: AppTheme.bodyMedium.copyWith(color: AppTheme.mediumGray),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppTheme.md),
          itemCount: matchRequests.length,
          itemBuilder: (context, index) {
            final match = matchRequests[index];
            return Card(
              margin: const EdgeInsets.only(bottom: AppTheme.md),
              child: ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MatchDetailScreen(matchRequest: match),
                    ),
                  );
                },
                title: Text(
                  match.landListingTitle ?? 'Unknown Land',
                  style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppTheme.xs),
                    Text(match.organizationName ?? 'Unknown Organization'),
                    Text(
                      DateFormat('MMM dd, yyyy - HH:mm').format(
                        DateTime.parse(match.createdAt),
                      ),
                      style: AppTheme.bodySmall,
                    ),
                  ],
                ),
                trailing: _buildStatusChip(match.status),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status) {
      case 'pending':
        color = AppTheme.warningOrange;
        label = 'PENDING';
        break;
      case 'accepted':
        color = AppTheme.successGreen;
        label = 'ACCEPTED';
        break;
      case 'declined':
        color = AppTheme.mediumGray;
        label = 'DECLINED';
        break;
      default:
        color = AppTheme.lightGray;
        label = status.toUpperCase();
    }

    return Chip(
      label: Text(label),
      backgroundColor: color,
      labelStyle: const TextStyle(
        color: AppTheme.white,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}