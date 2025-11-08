import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../theme/app_colors.dart';
import 'navigation_item.dart';

typedef FabBuilder = Widget? Function(BuildContext context, int currentIndex);

/// Shared navigation shell that powers both investor and entrepreneur flows.
class NavigationShell extends StatefulWidget {
  const NavigationShell({
    super.key,
    required this.items,
    this.initialIndex = 0,
    this.fabBuilder,
  }) : assert(items.length >= 2, 'Provide at least two navigation items.');

  final List<NavigationItem> items;
  final int initialIndex;
  final FabBuilder? fabBuilder;

  @override
  State<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends State<NavigationShell> {
  late int _currentIndex;
  late final List<Widget?> _cachedPages;

  @override
  void initState() {
    super.initState();
    _currentIndex =
        widget.initialIndex.clamp(0, widget.items.length - 1).toInt();
    _cachedPages = List<Widget?>.filled(widget.items.length, null);
  }

  Widget _pageAt(int index) {
    return _cachedPages[index] ??=
        KeyedSubtree(
          key: PageStorageKey<String>(
            'nav-tab-${widget.items[index].label}-$index',
          ),
          child: widget.items[index].builder(context),
        );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: List<Widget>.generate(
          widget.items.length,
          _pageAt,
        ),
      ),
      floatingActionButton:
          widget.fabBuilder?.call(context, _currentIndex),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          child: ClipRRect(
            borderRadius: AppRadius.lg,
            child: NavigationBarTheme(
              data: NavigationBarThemeData(
                height: 68,
                indicatorColor: AppColors.accent.withValues(alpha: 0.18),
                backgroundColor: theme.colorScheme.surface,
                overlayColor: MaterialStateProperty.resolveWith(
                  (Set<MaterialState> states) =>
                      states.contains(MaterialState.pressed)
                          ? AppColors.accent.withValues(alpha: 0.18)
                          : Colors.transparent,
                ),
                iconTheme: MaterialStateProperty.resolveWith(
                  (Set<MaterialState> states) {
                    final Color color = states.contains(MaterialState.selected)
                        ? AppColors.primary
                        : AppColors.muted;
                    return IconThemeData(color: color, size: 22);
                  },
                ),
                labelTextStyle: MaterialStateProperty.resolveWith(
                  (Set<MaterialState> states) {
                    final TextStyle base =
                        theme.textTheme.labelMedium ??
                        const TextStyle(fontSize: 12);
                    return states.contains(MaterialState.selected)
                        ? base.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          )
                        : base.copyWith(color: AppColors.muted);
                  },
                ),
              ),
              child: NavigationBar(
                selectedIndex: _currentIndex,
                elevation: 0,
                animationDuration: const Duration(milliseconds: 300),
                labelBehavior:
                    NavigationDestinationLabelBehavior.onlyShowSelected,
                destinations: widget.items
                    .map(
                      (NavigationItem item) => NavigationDestination(
                        icon: Icon(item.icon),
                        selectedIcon:
                            Icon(item.activeIcon ?? item.icon),
                        label: item.label,
                      ),
                    )
                    .toList(),
                onDestinationSelected: (int index) {
                  if (_currentIndex == index) return;
                  setState(() => _currentIndex = index);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

