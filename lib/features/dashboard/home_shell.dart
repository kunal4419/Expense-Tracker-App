import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

class HomeShell extends ConsumerWidget {
  final Widget child;

  const HomeShell({super.key, required this.child});

  int _getSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/sales')) return 1;
    if (location.startsWith('/expenses')) return 2;
    if (location.startsWith('/categories')) return 3;
    if (location.startsWith('/reports')) return 4;
    return 0; // Default to Dashboard
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/sales');
        break;
      case 2:
        context.go('/expenses');
        break;
      case 3:
        context.go('/categories');
        break;
      case 4:
        context.go('/reports');
        break;
    }
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out of your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(authProvider.notifier).signOut();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final selectedIndex = _getSelectedIndex(context);
    final authState = ref.watch(authProvider);
    final username = authState.profile?.username ?? authState.user?.email?.split('@').first ?? 'User';

    final isLargeScreen = size.width > 850;

    if (isLargeScreen) {
      return Scaffold(
        body: Row(
          children: [
            // Responsive Sidebar
            Container(
              width: 260,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                border: Border(
                  right: BorderSide(
                    color: theme.colorScheme.outlineVariant,
                    width: 0.5,
                  ),
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Sidebar Header
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.wallet,
                            color: theme.colorScheme.primary,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Expenses Tracker',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // User profile widget in sidebar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: theme.colorScheme.primaryContainer,
                              foregroundColor: theme.colorScheme.onPrimaryContainer,
                              child: Text(username.substring(0, 1).toUpperCase()),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    username,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    authState.user?.email ?? '',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Sidebar Navigation Items
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        children: [
                          _SidebarItem(
                            icon: Icons.home_outlined,
                            selectedIcon: Icons.home,
                            label: 'Dashboard',
                            selected: selectedIndex == 0,
                            onTap: () => _onItemTapped(0, context),
                          ),
                          _SidebarItem(
                            icon: Icons.trending_up_outlined,
                            selectedIcon: Icons.trending_up,
                            label: 'Sales',
                            selected: selectedIndex == 1,
                            onTap: () => _onItemTapped(1, context),
                          ),
                          _SidebarItem(
                            icon: Icons.attach_money_outlined,
                            selectedIcon: Icons.attach_money,
                            label: 'Expenses',
                            selected: selectedIndex == 2,
                            onTap: () => _onItemTapped(2, context),
                          ),
                          _SidebarItem(
                            icon: Icons.folder_open_outlined,
                            selectedIcon: Icons.folder,
                            label: 'Categories',
                            selected: selectedIndex == 3,
                            onTap: () => _onItemTapped(3, context),
                          ),
                          _SidebarItem(
                            icon: Icons.bar_chart_outlined,
                            selectedIcon: Icons.bar_chart,
                            label: 'Reports',
                            selected: selectedIndex == 4,
                            onTap: () => _onItemTapped(4, context),
                          ),
                        ],
                      ),
                    ),
                    
                    // Sidebar Footer (Logout)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _SidebarItem(
                        icon: Icons.exit_to_app_outlined,
                        selectedIcon: Icons.exit_to_app,
                        label: 'Logout',
                        selected: false,
                        onTap: () => _logout(context, ref),
                        isDestructive: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Content Pane
            Expanded(
              child: Scaffold(
                body: child,
              ),
            ),
          ],
        ),
      );
    } else {
      // Mobile View Layout
      return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Icon(
                Icons.wallet,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              const Text('Expenses'),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Chip(
                avatar: CircleAvatar(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  child: Text(
                    username.substring(0, 1).toUpperCase(),
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
                label: Text(username),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout_outlined),
              onPressed: () => _logout(context, ref),
            ),
          ],
        ),
        body: child,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (index) => _onItemTapped(index, context),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor: theme.colorScheme.onSurfaceVariant,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.trending_up_outlined),
              activeIcon: Icon(Icons.trending_up),
              label: 'Sales',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.attach_money_outlined),
              activeIcon: Icon(Icons.attach_money),
              label: 'Expenses',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.folder_open_outlined),
              activeIcon: Icon(Icons.folder),
              label: 'Categories',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Reports',
            ),
          ],
        ),
      );
    }
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SidebarItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = isDestructive ? theme.colorScheme.error : theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? theme.colorScheme.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                selected ? selectedIcon : icon,
                color: selected ? activeColor : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  color: selected ? activeColor : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
