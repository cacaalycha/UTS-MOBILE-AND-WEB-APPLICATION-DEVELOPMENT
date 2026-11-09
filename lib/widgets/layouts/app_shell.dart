import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/spacing.dart';
import '../../core/constants/typography.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';

/// Item navigasi utama.
class NavItem {
  const NavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String route;
}

const List<NavItem> buyerNavItems = [
  NavItem(
    label: 'Beranda',
    icon: Icons.home_outlined,
    selectedIcon: Icons.home_rounded,
    route: '/beranda',
  ),
  NavItem(
    label: 'Katalog',
    icon: Icons.grid_view_outlined,
    selectedIcon: Icons.grid_view_rounded,
    route: '/katalog',
  ),
  NavItem(
    label: 'Keranjang',
    icon: Icons.shopping_bag_outlined,
    selectedIcon: Icons.shopping_bag_rounded,
    route: '/keranjang',
  ),
  NavItem(
    label: 'Pesanan',
    icon: Icons.receipt_long_outlined,
    selectedIcon: Icons.receipt_long_rounded,
    route: '/pesanan',
  ),
];

const List<NavItem> adminNavItems = [
  NavItem(
    label: 'Dashboard',
    icon: Icons.dashboard_outlined,
    selectedIcon: Icons.dashboard_rounded,
    route: '/admin',
  ),
  NavItem(
    label: 'Produk',
    icon: Icons.inventory_2_outlined,
    selectedIcon: Icons.inventory_2_rounded,
    route: '/admin/produk',
  ),
];

/// Kerangka aplikasi responsif.
///
/// - Mobile (< 900 px): bottom navigation.
/// - Web / layar lebar: sidebar di kiri (sesuai keputusan navigasi Minggu 3).
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const double _webBreakpoint = 900;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= _webBreakpoint;
    final auth = context.watch<AuthProvider>();
    final items = auth.isAdmin ? adminNavItems : buyerNavItems;

    return Scaffold(
      body: isWide
          ? Row(
              children: [
                _Sidebar(
                  items: items,
                  currentIndex: navigationShell.currentIndex,
                  onSelect: _onSelect,
                  userName: auth.user?.name ?? '',
                  isAdmin: auth.isAdmin,
                ),
                const VerticalDivider(width: 1),
                Expanded(child: navigationShell),
              ],
            )
          : navigationShell,
      bottomNavigationBar: isWide
          ? null
          : _BottomNav(
              items: items,
              currentIndex: navigationShell.currentIndex,
              onSelect: _onSelect,
            ),
    );
  }

  void _onSelect(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.items,
    required this.currentIndex,
    required this.onSelect,
  });

  final List<NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartProvider>().itemCount;

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onSelect,
      destinations: [
        for (var i = 0; i < items.length; i++)
          NavigationDestination(
            icon: _withBadge(
              items[i].icon,
              i == 2 ? cartCount : 0,
            ),
            selectedIcon: _withBadge(
              items[i].selectedIcon,
              i == 2 ? cartCount : 0,
            ),
            label: items[i].label,
          ),
      ],
    );
  }

  Widget _withBadge(IconData icon, int count) {
    final iconWidget = Icon(icon);
    if (count <= 0) return iconWidget;

    return Badge(
      label: Text('$count'),
      backgroundColor: AppColors.error,
      textColor: AppColors.textOnPrimary,
      child: iconWidget,
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.items,
    required this.currentIndex,
    required this.onSelect,
    required this.userName,
    required this.isAdmin,
  });

  final List<NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onSelect;
  final String userName;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartProvider>().itemCount;

    return Container(
      width: 248,
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: const Icon(
                  Icons.phone_iphone_rounded,
                  color: AppColors.textOnPrimary,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  'Case iPhone\nCaca',
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            isAdmin ? 'PANEL ADMIN' : 'MENU UTAMA',
            style: AppTypography.caption.copyWith(
              fontSize: 12,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          for (var i = 0; i < items.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: _SidebarTile(
                item: items[i],
                selected: i == currentIndex,
                badgeCount: i == 2 ? cartCount : 0,
                onTap: () => onSelect(i),
              ),
            ),
          const Spacer(),
          const Divider(),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primarySurface,
                child: Text(
                  userName.isEmpty ? '?' : userName[0].toUpperCase(),
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(fontSize: 15),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SidebarTile extends StatelessWidget {
  const _SidebarTile({
    required this.item,
    required this.selected,
    required this.onTap,
    required this.badgeCount,
  });

  final NavItem item;
  final bool selected;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primarySurface : Colors.transparent,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: 10,
          ),
          child: Row(
            children: [
              Icon(
                selected ? item.selectedIcon : item.icon,
                size: 22,
                color: selected
                    ? AppColors.primaryDark
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  item.label,
                  style: AppTypography.caption.copyWith(
                    fontSize: 16,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    color: selected
                        ? AppColors.primaryDark
                        : AppColors.textPrimary,
                  ),
                ),
              ),
              if (badgeCount > 0)
                Badge(
                  label: Text('$badgeCount'),
                  backgroundColor: AppColors.error,
                  textColor: AppColors.textOnPrimary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
