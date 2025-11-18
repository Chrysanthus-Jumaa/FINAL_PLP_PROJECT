import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/app_state.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_dialog.dart';
import '../auth/login_screen.dart';
import 'add_land_screen.dart';
import 'matches_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'edit_land_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  bool _showInAcres = true; // Unit toggle state

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final appState = Provider.of<AppState>(context, listen: false);
    await appState.loadLandListings();
    await appState.loadMatchRequests();
    await appState.loadNotifications();
  }

  void _onNavItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  Future<void> _onLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final appState = Provider.of<AppState>(context, listen: false);
      await appState.logout();
      
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final user = appState.currentUser;
        
        if (user == null) {
          return const Scaffold(body: LoadingIndicator());
        }

        // Responsive layout
        final isDesktop = MediaQuery.of(context).size.width > 1024;
        final isTablet = MediaQuery.of(context).size.width > 600;

        return Scaffold(
          appBar: isDesktop || isTablet ? _buildDesktopAppBar(user) : null,
          drawer: isDesktop || isTablet ? null : _buildDrawer(user),
          body: _buildBody(appState),
          bottomNavigationBar: isDesktop || isTablet ? null : _buildBottomNav(appState),
          floatingActionButton: _selectedIndex == 0 && !(isDesktop || isTablet)
              ? FloatingActionButton.extended(
                  onPressed: () => _navigateToAddLand(),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Land'),
                )
              : null,
        );
      },
    );
  }

  PreferredSizeWidget _buildDesktopAppBar(user) {
    return AppBar(
      title: Row(
        children: [
          // User avatar
          CircleAvatar(
            backgroundColor: AppTheme.primaryBlue,
            child: Text(
              user.initials,
              style: AppTheme.buttonText,
            ),
          ),
          const SizedBox(width: AppTheme.md),
          Text('Hello, ${user.firstName}', style: AppTheme.h3),
        ],
      ),
      actions: [
        // Navigation tabs
        TextButton(
          onPressed: () => _onNavItemTapped(0),
          child: Text(
            'Land Listings',
            style: TextStyle(
              color: _selectedIndex == 0
                  ? AppTheme.primaryBlue
                  : AppTheme.mediumGray,
              fontWeight: _selectedIndex == 0
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ),
        TextButton(
          onPressed: () => _onNavItemTapped(1),
          child: Text(
            'Matches',
            style: TextStyle(
              color: _selectedIndex == 1
                  ? AppTheme.primaryBlue
                  : AppTheme.mediumGray,
              fontWeight: _selectedIndex == 1
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ),
        Consumer<AppState>(
          builder: (context, appState, _) {
            final unreadCount = appState.unreadNotificationCount;
            return Stack(
              children: [
                TextButton(
                  onPressed: () => _onNavItemTapped(2),
                  child: Text(
                    'Notifications',
                    style: TextStyle(
                      color: _selectedIndex == 2
                          ? AppTheme.primaryBlue
                          : AppTheme.mediumGray,
                      fontWeight: _selectedIndex == 2
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppTheme.errorRed,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$unreadCount',
                        style: const TextStyle(
                          color: AppTheme.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        TextButton(
          onPressed: () => _onNavItemTapped(3),
          child: Text(
            'My Profile',
            style: TextStyle(
              color: _selectedIndex == 3
                  ? AppTheme.primaryBlue
                  : AppTheme.mediumGray,
              fontWeight: _selectedIndex == 3
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: _onLogout,
          tooltip: 'Logout',
        ),
        const SizedBox(width: AppTheme.md),
      ],
    );
  }

  Widget _buildDrawer(user) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppTheme.primaryBlue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTheme.white,
                  child: Text(
                    user.initials,
                    style: AppTheme.h3.copyWith(color: AppTheme.primaryBlue),
                  ),
                ),
                const SizedBox(height: AppTheme.md),
                Text(
                  'Hello, ${user.firstName}',
                  style: AppTheme.h3.copyWith(color: AppTheme.white),
                ),
                Text(
                  user.email,
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.white),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.landscape),
            title: const Text('Land Listings'),
            selected: _selectedIndex == 0,
            onTap: () {
              _onNavItemTapped(0);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.handshake),
            title: const Text('Matches'),
            selected: _selectedIndex == 1,
            onTap: () {
              _onNavItemTapped(1);
              Navigator.pop(context);
            },
          ),
          Consumer<AppState>(
            builder: (context, appState, _) {
              return ListTile(
                leading: Badge(
                  isLabelVisible: appState.unreadNotificationCount > 0,
                  label: Text('${appState.unreadNotificationCount}'),
                  child: const Icon(Icons.notifications),
                ),
                title: const Text('Notifications'),
                selected: _selectedIndex == 2,
                onTap: () {
                  _onNavItemTapped(2);
                  Navigator.pop(context);
                },
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('My Profile'),
            selected: _selectedIndex == 3,
            onTap: () {
              _onNavItemTapped(3);
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppTheme.errorRed),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              _onLogout();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(AppState appState) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onNavItemTapped,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppTheme.primaryBlue,
      unselectedItemColor: AppTheme.mediumGray,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.landscape),
          label: 'Listings',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.handshake),
          label: 'Matches',
        ),
        BottomNavigationBarItem(
          icon: Badge(
            isLabelVisible: appState.unreadNotificationCount > 0,
            label: Text('${appState.unreadNotificationCount}'),
            child: const Icon(Icons.notifications),
          ),
          label: 'Notifications',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  Widget _buildBody(AppState appState) {
  switch (_selectedIndex) {
    case 0:
      return _buildLandListingsTab(appState);
    case 1:
      return const MatchesScreen();
    case 2:
      return const NotificationsScreen();
    case 3:
      return const ProfileScreen();
    default:
      return _buildLandListingsTab(appState);
  }
}

  Widget _buildLandListingsTab(AppState appState) {
    final isDesktop = MediaQuery.of(context).size.width > 1024;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Unit toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('My Land Listings', style: AppTheme.h3),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: true, label: Text('Acres')),
                    ButtonSegment(value: false, label: Text('Hectares')),
                  ],
                  selected: {_showInAcres},
                  onSelectionChanged: (Set<bool> selection) {
                    setState(() => _showInAcres = selection.first);
                  },
                ),
              ],
            ),
            const SizedBox(height: AppTheme.md),

            if (isDesktop)
              ElevatedButton.icon(
                onPressed: _navigateToAddLand,
                icon: const Icon(Icons.add),
                label: const Text('Add Land Profile'),
              ),
            const SizedBox(height: AppTheme.md),

            // Land listings
            Expanded(
              child: appState.landListings.isEmpty
                  ? _buildEmptyState()
                  : _buildLandGrid(appState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.landscape,
            size: 80,
            color: AppTheme.lightGray,
          ),
          const SizedBox(height: AppTheme.md),
          Text(
            'No land listings yet',
            style: AppTheme.h3.copyWith(color: AppTheme.mediumGray),
          ),
          const SizedBox(height: AppTheme.sm),
          Text(
            'Add your first land profile to get started',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.mediumGray),
          ),
        ],
      ),
    );
  }

  Widget _buildLandGrid(AppState appState) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        childAspectRatio: 1.2,
        crossAxisSpacing: AppTheme.md,
        mainAxisSpacing: AppTheme.md,
      ),
      itemCount: appState.landListings.length,
      itemBuilder: (context, index) {
        final land = appState.landListings[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  land.title,
                  style: AppTheme.h3,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppTheme.sm),
                Text(
                  _showInAcres
                      ? '${land.sizeAcres} acres'
                      : '${land.sizeHectares} hectares',
                  style: AppTheme.bodyLarge,
                ),
                Text(
                  '${land.countyName}, ${land.subcountyName}',
                  style: AppTheme.bodySmall,
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Chip(
                      label: Text(land.availability.toUpperCase()),
                      backgroundColor: land.isAvailable
                          ? AppTheme.successGreen
                          : AppTheme.mediumGray,
                      labelStyle: const TextStyle(color: AppTheme.white),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditLandScreen(landListing: land),
                              ),
                            ).then((_) => _loadData());
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: AppTheme.errorRed),
                          onPressed: () => _confirmDelete(appState, land.id),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder(String title) {
    return Center(
      child: Text('$title - Coming in next steps'),
    );
  }

  Future<void> _confirmDelete(AppState appState, int landId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Land Profile?'),
        content: const Text(
          'Are you sure you want to delete this land profile? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await appState.deleteLandListing(landId);
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Land profile deleted')),
          );
        } else {
          ErrorDialog.show(context, appState.errorMessage ?? 'Failed to delete');
        }
      }
    }
  }

  void _navigateToAddLand() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddLandScreen()),
    ).then((_) => _loadData());
  }
}