import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../providers/app_state.dart';
import 'match_detail_screen.dart';

class OrgMatchesScreen extends StatelessWidget {
  const OrgMatchesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final matches = appState.matchRequests;

        if (matches.isEmpty) {
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
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppTheme.md),
          itemCount: matches.length,
          itemBuilder: (context, index) {
            final match = matches[index];
            return Card(
              margin: const EdgeInsets.only(bottom: AppTheme.md),
              child: ListTile(
                title: Text(
                  match.landListingTitle ?? 'Unknown Land',
                  style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppTheme.sm),
                    Text('Restorer: ${match.restorerName ?? "Unknown"}'),
                    Text(
                      'Requested: ${DateFormat('MMM d, y').format(DateTime.parse(match.createdAt))}',
                      style: AppTheme.bodySmall,
                    ),
                  ],
                ),
                trailing: _buildStatusChip(match.status),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MatchDetailScreen(matchRequest: match),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    String displayText;

    switch (status) {
      case 'pending':
        backgroundColor = AppTheme.warningOrange;
        displayText = 'PENDING';
        break;
      case 'accepted':
        backgroundColor = AppTheme.successGreen;
        displayText = 'ACCEPTED';
        break;
      case 'declined':
        backgroundColor = AppTheme.errorRed;
        displayText = 'DECLINED';
        break;
      case 'land_no_longer_available':
        backgroundColor = AppTheme.mediumGray;
        displayText = 'UNAVAILABLE';
        break;
      default:
        backgroundColor = AppTheme.mediumGray;
        displayText = status.toUpperCase();
    }

    return Chip(
      label: Text(displayText),
      backgroundColor: backgroundColor,
      labelStyle: const TextStyle(
        color: AppTheme.white,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}