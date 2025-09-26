import 'package:flutter/material.dart';

// โครงสร้างข้อมูลสำหรับแต่ละปุ่มในแถบนำทางด้านล่าง
class NavDestination {
  final IconData icon;
  final IconData iconSelected;
  final String label;

  const NavDestination({
    required this.icon,
    required this.iconSelected,
    required this.label,
  });
}

// รายการปลายทางมาตรฐานที่ใช้ซ้ำในหลายหน้า
class AppDestinations {
  static const List<NavDestination> destinations = [
    NavDestination(
      icon: Icons.home_outlined,
      iconSelected: Icons.home,
      label: 'หน้าแรก',
    ),
    NavDestination(
      icon: Icons.message_outlined,
      iconSelected: Icons.message,
      label: 'ข้อความ',
    ),
    NavDestination(
      icon: Icons.notifications_outlined,
      iconSelected: Icons.notifications,
      label: 'แจ้งเตือน',
    ),
    NavDestination(
      icon: Icons.person_outlined,
      iconSelected: Icons.person,
      label: 'โปรไฟล์',
    ),
  ];
}

// จับคู่ปลายทางกับ widget หน้าจอและชื่อที่จะโชว์บน AppBar
class AppNavItem {
  final NavDestination destination;
  final WidgetBuilder builder;
  final String title;

  AppNavItem({
    required this.destination,
    required this.builder,
    String? title,
  }) : title = title ?? destination.label;
}

// วิดเจ็ต NavigationBar ส่วนกลางสำหรับทั้งแอป
class AppNavigationBar extends StatelessWidget {
  final List<NavDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Color? backgroundColor;
  final NavigationBarThemeData? theme;

  const AppNavigationBar({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.backgroundColor,
    this.theme,
  });

  // ประกอบ Scaffold หลักพร้อม IndexedStack เพื่อคงสถานะของแต่ละแท็บ
  @override
  Widget build(BuildContext context) {
    final navigationBar = NavigationBar(
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.primary,
      elevation: 0,
      indicatorColor: Colors.transparent,
      height: 70,
      destinations: destinations
          .map(
            (destination) => NavigationDestination(
              icon: Icon(destination.icon),
              selectedIcon: Icon(destination.iconSelected),
              label: destination.label,
            ),
          )
          .toList(),
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
    );

    final themeData = theme ?? _defaultNavTheme(Theme.of(context));

    return NavigationBarTheme(
      data: themeData,
      child: navigationBar,
    );
  }
}

// ธีมพื้นฐานของ NavigationBar กำหนดสีไอคอนและข้อความ
NavigationBarThemeData _defaultNavTheme(ThemeData theme) {
  final onPrimary = theme.colorScheme.onPrimary;

  return NavigationBarThemeData(
    labelTextStyle: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const TextStyle(color: Colors.black, height: 0.5);
      }
      return TextStyle(color: onPrimary, height: 0.5);
    }),
    iconTheme: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const IconThemeData(size: 30, color: Colors.black);
      }
      return IconThemeData(size: 30, color: onPrimary);
    }),
    labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
  );
}

// ตัวครอบแถบนำทาง จัดการสถานะและประกอบโครงสร้างหลักของหน้า
class NavBarWrapper extends StatefulWidget {
  final List<AppNavItem> items;
  final int initialIndex;
  final Color? backgroundColor;
  final Color? scaffoldBackgroundColor;
  final NavigationBarThemeData? navigationBarTheme;
  final bool showAppBar;
  final PreferredSizeWidget Function(
    BuildContext context,
    AppNavItem currentItem,
    int currentIndex,
  )? appBarBuilder;
  final bool Function(int newIndex)? onDestinationSelected;

  const NavBarWrapper({
    super.key,
    required this.items,
    this.initialIndex = 0,
    this.backgroundColor,
    this.scaffoldBackgroundColor,
    this.navigationBarTheme,
    this.showAppBar = true,
    this.appBarBuilder,
    this.onDestinationSelected,
  }) : assert(items.length > 0, 'NavBarWrapper requires at least one navigation item');

  @override
  State<NavBarWrapper> createState() => _NavBarWrapperState();
}

class _NavBarWrapperState extends State<NavBarWrapper> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = _sanitizeIndex(widget.initialIndex);
  }

  @override
  void didUpdateWidget(covariant NavBarWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.items.length != oldWidget.items.length) {
      _currentIndex = _sanitizeIndex(_currentIndex);
    }

    if (widget.initialIndex != oldWidget.initialIndex) {
      _currentIndex = _sanitizeIndex(widget.initialIndex);
    }
  }

  // ป้องกันไม่ให้ index หลุดช่วงรายการ
  int _sanitizeIndex(int index) {
    final maxIndex = widget.items.length - 1;
    if (index < 0) return 0;
    if (index > maxIndex) return maxIndex;
    return index;
  }

  // อัปเดตสถานะเมื่อผู้ใช้เลือกแท็บใหม่
  void _handleNavigation(int index) {
    if (index < 0 || index >= widget.items.length) {
      return;
    }

    final allowChange = widget.onDestinationSelected?.call(index) ?? true;
    if (!allowChange || index == _currentIndex) {
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  // สร้างหรือปรับแต่ง AppBar ตามหน้าปัจจุบัน
  PreferredSizeWidget? _buildAppBar(BuildContext context) {
    if (!widget.showAppBar) {
      return null;
    }

    final currentItem = widget.items[_currentIndex];

    if (widget.appBarBuilder != null) {
      return widget.appBarBuilder!(context, currentItem, _currentIndex);
    }

    final theme = Theme.of(context);

    return AppBar(
      title: Text(currentItem.title),
      centerTitle: true,
      backgroundColor: widget.backgroundColor ?? theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      automaticallyImplyLeading: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final destinations = widget.items.map((item) => item.destination).toList();

    return Scaffold(
      backgroundColor: widget.scaffoldBackgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: IndexedStack(
        index: _currentIndex,
        children: List.generate(widget.items.length, (index) {
          final item = widget.items[index];

          return KeyedSubtree(
            key: PageStorageKey<String>('nav-item-${item.destination.label}-$index'),
            child: Builder(builder: item.builder),
          );
        }),
      ),
      bottomNavigationBar: AppNavigationBar(
        destinations: destinations,
        selectedIndex: _currentIndex,
        onDestinationSelected: _handleNavigation,
        backgroundColor: widget.backgroundColor,
        theme: widget.navigationBarTheme,
      ),
    );
  }
}
