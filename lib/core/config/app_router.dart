import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sistema_compras/features/modules/brand/screens/brand_screen.dart';
import 'package:sistema_compras/features/modules/employee/screens/employee_screen.dart';

// Importa tus pantallas aquí
import '../../features/auth/guards/auth_guard.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/forgot_password.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/modules/article/screens/article_screen.dart';
import '../../features/modules/department/screens/department_screen.dart';
import '../../features/modules/purchase _order/screens/purchase _order_screen.dart';
import '../../features/modules/request_articles/screens/request_articles_screen.dart';
import '../../features/modules/supplier/screens/supplier_screen.dart';
import '../../features/modules/unit/screens/unit_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  redirect: (context, state) {
    // Obtener el provider de autenticación
    final authProvider = context.read<AuthProvider>();
    final isLoggedIn = authProvider.isLoggedIn;
    final isLoading = authProvider.isLoading;

    // Rutas públicas que no requieren autenticación
    final publicRoutes = ['/login', '/register', '/forgot-password'];
    final isPublicRoute = publicRoutes.contains(state.matchedLocation);

    // Si está cargando, no redirigir
    if (isLoading) return null;

    // Si no está autenticado y no está en una ruta pública, ir a login
    if (!isLoggedIn && !isPublicRoute) {
      return '/login';
    }

    // Si está autenticado y está en una ruta pública, ir a home
    if (isLoggedIn && isPublicRoute) {
      return '/home';
    }

    // En cualquier otro caso, continuar normalmente
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      name: LoginScreen.name,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      name: RegisterScreen.name,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      name: ForgotPasswordScreen.name,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const AuthGuard(child: HomeScreen()),
    ),
    // Ruta para la pantalla de empleados
    GoRoute(
      path: '/empleados',
      name: EmployeeScreen.name,
      builder: (context, state) => AuthGuard(child: EmployeeScreen()),
    ),
    GoRoute(
      path: '/departamentos',
      name: DepartmentScreen.name,
      builder: (context, state) => AuthGuard(child: DepartmentScreen()),
    ),
    GoRoute(
      path: '/marcas',
      name: BrandScreen.name,
      builder: (context, state) => AuthGuard(child: BrandScreen()),
    ),
    GoRoute(
      path: '/unidades-medida',
      name: UnitScreen.name,
      builder: (context, state) => AuthGuard(child: UnitScreen()),
    ),
    GoRoute(
      path: '/proveedores',
      name: SupplierScreen.name,
      builder: (context, state) => AuthGuard(child: SupplierScreen()),
    ),
    GoRoute(
      path: '/articulos',
      name: ArticleScreen.name,
      builder: (context, state) => AuthGuard(child: ArticleScreen()),
    ),
    GoRoute(
      path: '/solicitud-articulos',
      name: RequestArticlesScreen.name,
      builder: (context, state) => AuthGuard(child: RequestArticlesScreen()),
    ),
    GoRoute(
      path: '/ordenes-compra',
      name: PurchaseOrderScreen.name,
      builder: (context, state) => AuthGuard(child: PurchaseOrderScreen()),
    ),
    // La rutas dependiendo de la estructura de la app
    // GoRoute(
    //   path: '/maps',
    //   name: CustomGoogleMaps.name,
    //   builder: (context, state) => const CustomGoogleMaps(),
    // ),
  ],
  errorBuilder:
      (context, state) => Scaffold(
        body: Center(child: Text('Página no encontrada: ${state.error}')),
      ),
);
