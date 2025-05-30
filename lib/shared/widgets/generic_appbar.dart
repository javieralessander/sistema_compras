import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:sistema_compras/features/home/screens/home_screen.dart';
import '../../features/modules/brand/screens/brand_screen.dart';
import '../../features/modules/department/screens/department_screen.dart';
import '../../features/modules/employee/screens/employee_screen.dart';
import '../../features/modules/unit/screens/unit_screen.dart';
import '../../features/profile/screens/user_profile_screen.dart';

// 1. Define la clase de datos para los menús
class MenuItemData {
  final String title;
  final IconData icon;
  final String routeName;

  const MenuItemData({
    required this.title,
    required this.icon,
    required this.routeName,
  });
}

// 2. Lista única de menús
const List<MenuItemData> appMenuItems = [
  MenuItemData(
    title: 'Portada',
    icon: Icons.dashboard,
    routeName: HomeScreen.name,
  ),
  MenuItemData(
    title: 'Departamentos',
    icon: Icons.apartment,
    routeName: DepartmentScreen.name,
  ),
  MenuItemData(
    title: 'Artículos',
    icon: Icons.inventory,
    routeName: 'articles',
  ),
  MenuItemData(
    title: 'Solicitudes',
    icon: Icons.assignment,
    routeName: 'requests',
  ),
  MenuItemData(
    title: 'Órdenes de Compra',
    icon: Icons.shopping_cart,
    routeName: 'purchase-orders',
  ),
  MenuItemData(title: 'Marcas', icon: Icons.label, routeName: BrandScreen.name),
  MenuItemData(
    title: 'Unidades de Medida',
    icon: Icons.straighten,
    routeName: UnitScreen.name,
  ),
  MenuItemData(
    title: 'Empleados',
    icon: Icons.people_alt,
    routeName: EmployeeScreen.name,
  ),
];

class GenericAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isMobile;
  final double height;

  const GenericAppBar({super.key, required this.isMobile, this.height = 60});

  @override
  Widget build(BuildContext context) {
    final sizeScreen = MediaQuery.of(context).size;
    final isSmall = sizeScreen.width < 600;
    final isMedium = sizeScreen.width >= 600 && sizeScreen.width < 900;

    return AppBar(
      backgroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.black),
      actionsPadding: EdgeInsets.symmetric(
        horizontal: sizeScreen.width * 0.02,
        vertical: sizeScreen.height * 0.01,
      ),
      toolbarHeight:
          isSmall
              ? 56
              : isMedium
              ? 64
              : 72,
      title: SvgPicture.asset(
        'assets/svgs/sicom.svg',
        height:
            isSmall
                ? 32
                : isMedium
                ? 40
                : 52,
      ),
      titleSpacing: isMobile ? 0 : sizeScreen.width * 0.02,
      centerTitle: isMobile,
      actions: [
        IconButton(
          icon: const Icon(Icons.account_circle_outlined),
          iconSize: isSmall ? 28 : 32,
          onPressed: () {
            context.pushNamed(UserProfileScreen.name);
          },
        ),
        if (!isSmall) ...[
          const SizedBox(width: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'JAVIER ALESSANDER MONTERO MONTERO',
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: isMedium ? 11 : 12,
                  overflow: TextOverflow.ellipsis,
                ),
                maxLines: 1,
              ),
              Text(
                'JA.MONTERO',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: isMedium ? 11 : 12,
                  overflow: TextOverflow.ellipsis,
                ),
                maxLines: 1,
              ),
            ],
          ),
        ],
      ],
      bottom:
          !isMobile
              ? PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  padding: EdgeInsets.only(left: sizeScreen.width * 0.02),
                  height: 48,
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade200, width: 2),
                      bottom: BorderSide(color: Colors.grey.shade200, width: 2),
                    ),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        for (final item in appMenuItems) ...[
                          HorizontalMenuItem(
                            title: item.title,
                            icon: item.icon,
                            routeName: item.routeName,
                          ),
                          const SizedBox(width: 8),
                        ],
                      ],
                    ),
                  ),
                ),
              )
              : PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(
                  color: Colors.grey.shade300,
                  height: 1,
                  width: double.infinity,
                ),
              ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height + (!isMobile ? 48 : 1));
}

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF0D2C4B)),
            child: Icon(Icons.shopping_cart, size: 48, color: Colors.white),
          ),
          for (final item in appMenuItems)
            _DrawerItem(
              title: item.title,
              icon: item.icon,
              routeName: item.routeName,
            ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? routeName;

  const _DrawerItem({required this.title, required this.icon, this.routeName});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(title, style: const TextStyle(color: Colors.black87)),
      onTap: () {
        if (routeName == null) return;
        if (Scaffold.of(context).isDrawerOpen) {
          Navigator.pop(context);
        }
        context.pushNamed(routeName!);
      },
    );
  }
}

class HorizontalMenuItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? routeName;

  const HorizontalMenuItem({
    super.key,
    required this.title,
    required this.icon,
    this.routeName,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () {
        if (routeName == null) return;
        if (Scaffold.of(context).isDrawerOpen) {
          Navigator.pop(context);
        }
        context.pushNamed(routeName!);
      },
      icon: Icon(icon, color: Colors.black87),
      label: Text(title, style: const TextStyle(color: Colors.black87)),
      style: TextButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
