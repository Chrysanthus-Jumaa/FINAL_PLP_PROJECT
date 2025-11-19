import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../models/match_request.dart';

class MatchDetailScreen extends StatelessWidget {
  final MatchRequest matchRequest;

  const MatchDetailScreen({Key? key, required this.matchRequest}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final landDetails = matchRequest.landListingDetails;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Badge
            Center(
              child: _buildStatusChip(matchRequest.status),
            ),
            const SizedBox(height: AppTheme.xl),

            // Restorer Info
            _buildSection(
              'Restorer Information',
              [
                _buildInfoRow('Name', matchRequest.restorerName ?? 'N/A'),
              ],
            ),
            const SizedBox(height: AppTheme.lg),

            // Request Info
            _buildSection(
              'Request Information',
              [
                _buildInfoRow(
                  'Date Requested',
                  DateFormat('MMM d, y').format(DateTime.parse(matchRequest.createdAt)),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.lg),

            // Land Details
            if (landDetails != null) ...[
              _buildSection(
                'Land Parcel Details',
                [
                  _buildInfoRow('Title', landDetails['title'] ?? 'N/A'),
                  _buildInfoRow(
                    'Size',
                    '${landDetails['size_acres']} acres (${landDetails['size_hectares']} hectares)',
                  ),
                  _buildInfoRow(
                    'Location',
                    '${landDetails['county_name']}, ${landDetails['subcounty_name']}',
                  ),
                  _buildInfoRow(
                    'Availability',
                    (landDetails['availability'] ?? 'N/A').toString().toUpperCase(),
                  ),
                ],
              ),
            ],
            const SizedBox(height: AppTheme.xl),

            // Accepted message
            if (matchRequest.isAccepted) ...[
              Card(
                color: AppTheme.successGreen.withOpacity(0.1),
                child: const Padding(
                  padding: EdgeInsets.all(AppTheme.md),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: AppTheme.successGreen),
                      SizedBox(width: AppTheme.md),
                      Expanded(
                        child: Text(
                          'Check your email for contact details to begin collaboration.',
                          style: AppTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTheme.h3),
            const SizedBox(height: AppTheme.md),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.mediumGray,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: AppTheme.bodyMedium),
          ),
        ],
      ),
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
        displayText = 'LAND NO LONGER AVAILABLE';
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
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}