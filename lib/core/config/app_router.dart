import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sistema_compras/features/modules/brand/screens/brand_screen.dart';
import 'package:sistema_compras/features/modules/employee/screens/employee_screen.dart';

// Importa tus pantallas aquí
import '../../features/auth/screens/auth_gate.dart';
import '../../features/auth/screens/forgot_password.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/modules/article/screens/article_screen.dart';
import '../../features/modules/department/screens/department_screen.dart';
import '../../features/modules/supplier/screens/supplier_screen.dart';
import '../../features/modules/unit/screens/unit_screen.dart';
import '../../features/profile/screens/user_profile_screen.dart';
import '../../features/profile/services/user_profile_service.dart';
import '../../shared/widgets/custom_google_maps.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  // initialLocation: '/auth-gate',
  initialLocation: '/empleados',
  routes: [
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/auth-gate',
      name: 'auth-gate',
      builder: (context, state) => const AuthGate(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      name: 'forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/user-profile',
      name: 'user-profile',
      builder:
          (context, state) => ChangeNotifierProvider(
            create: (context) => UserProfileService(),
            child: const UserProfileScreen(),
          ),
    ),
    // Ruta para la pantalla de empleados
    GoRoute(
      path: '/empleados',
      name: EmployeeScreen.name,
      builder: (context, state) => EmployeeScreen(),
    ),
    GoRoute(
      path: '/departamentos',
      name: DepartmentScreen.name,
      builder: (context, state) => DepartmentScreen(),
    ),
    GoRoute(
      path: '/brans',
      name: BrandScreen.name,
      builder: (context, state) => BrandScreen(),
    ),
    GoRoute(
      path: '/units',
      name: UnitScreen.name,
      builder: (context, state) => UnitScreen(),
    ),
    GoRoute(
      path: '/Suppliers',
      name: SupplierScreen.name,
      builder: (context, state) => SupplierScreen(),
    ),
    GoRoute(
      path: '/articles',
      name: ArticleScreen.name,
      builder: (context, state) => ArticleScreen(),
    ),
    // La rutas dependiendo de la estructura de la app
    GoRoute(
      path: '/maps',
      name: CustomGoogleMaps.name,
      builder: (context, state) => const CustomGoogleMaps(),
    ),
  ],
  errorBuilder:
      (context, state) => Scaffold(
        body: Center(child: Text('Página no encontrada: ${state.error}')),
      ),
);
