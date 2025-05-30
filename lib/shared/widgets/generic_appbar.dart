import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:sistema_compras/features/home/screens/home_screen.dart';
import '../../features/modules/article/screens/article_screen.dart';
import '../../features/modules/brand/screens/brand_screen.dart';
import '../../features/modules/department/screens/department_screen.dart';
import '../../features/modules/employee/screens/employee_screen.dart';
import '../../features/modules/purchase _order/screens/purchase _order_screen.dart';
import '../../features/modules/request_articles/screens/request_articles_screen.dart';
import '../../features/modules/supplier/screens/supplier_screen.dart';
import '../../features/modules/unit/screens/unit_screen.dart';
import '../../features/profile/screens/user_profile_screen.dart';

// 1. Define la clase de datos para los menús
class MenuItemData {
  final String title;
  final IconData icon;
  final String routeName;
  final String path;

  const MenuItemData({
    required this.title,
    required this.icon,
    required this.routeName,
    required this.path,
  });
}

// 2. Lista única de menús
const List<MenuItemData> appMenuItems = [
  MenuItemData(
    title: 'Portada',
    icon: Icons.dashboard,
    routeName: HomeScreen.name,
    path: '/home',
  ),
  MenuItemData(
    title: 'Departamentos',
    icon: Icons.apartment,
    routeName: DepartmentScreen.name,
    path: '/departamentos',
  ),
  MenuItemData(
    title: 'Artículos',
    icon: Icons.inventory,
    routeName: ArticleScreen.name,
    path: '/articulos',
  ),
  MenuItemData(
    title: 'Proveedores',
    icon: Icons.local_shipping,
    routeName: SupplierScreen.name,
    path: '/proveedores',
  ),
  MenuItemData(
    title: 'Solicitud de Artículos',
    icon: Icons.assignment,
    routeName: RequestArticlesScreen.name,
    path: '/solicitud-articulos',
  ),
  MenuItemData(
    title: 'Órdenes de Compra',
    icon: Icons.shopping_cart,
    routeName: PurchaseOrderScreen.name,
    path: '/ordenes-compra',
  ),
  MenuItemData(
    title: 'Marcas',
    icon: Icons.label,
    routeName: BrandScreen.name,
    path: '/marcas',
  ),
  MenuItemData(
    title: 'Unidades de Medida',
    icon: Icons.straighten,
    routeName: UnitScreen.name,
    path: '/unidades-medida',
  ),
  MenuItemData(
    title: 'Empleados',
    icon: Icons.people_alt,
    routeName: EmployeeScreen.name,
    path: '/empleados',
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
                            path: item.path,
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
              path: item.path,
            ),
        ],
      ),
    );
  }
}

// ...existing code...
class _DrawerItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? routeName;
  final String path;

  const _DrawerItem({
    required this.title,
    required this.icon,
    this.routeName,
    required this.path,
  });

  @override
  Widget build(BuildContext context) {
    final String currentPath = GoRouterState.of(context).uri.toString();
    final bool isSelected = path == currentPath;

    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.blue : Colors.black87),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.blue : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onTap: () {
        if (routeName == null) return;
        if (Scaffold.of(context).isDrawerOpen) {
          Navigator.pop(context);
        }
        context.go(path); // Cambiado a usar path
      },
    );
  }
}

class HorizontalMenuItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? routeName;
  final String path;

  const HorizontalMenuItem({
    super.key,
    required this.title,
    required this.icon,
    this.routeName,
    required this.path,
  });

  @override
  Widget build(BuildContext context) {
    final GoRouter router = GoRouter.of(context);
    final String currentPath = router.routeInformationProvider.value.location;

    final bool isSelected = currentPath == path;

    return TextButton.icon(
      onPressed: () {
        if (routeName == null) return;
        context.go(path); // Cambiado a usar path
      },
      icon: Icon(icon, color: isSelected ? Colors.blue : Colors.black87),
      label: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.blue : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      style: TextButton.styleFrom(
        foregroundColor: isSelected ? Colors.blue : Colors.black,
        backgroundColor:
            isSelected ? Colors.blue.withOpacity(0.08) : Colors.transparent,
      ),
    );
  }
}
// ...existing code...