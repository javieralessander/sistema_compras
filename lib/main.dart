import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sistema_compras/features/modules/article/providers/article_provider.dart';
import 'package:sistema_compras/features/modules/department/providers/department_provider.dart';
import 'package:sistema_compras/features/modules/unit/providers/unit_provider.dart';

import 'core/config/app_router.dart';
import 'core/config/app_theme.dart';
import 'core/config/env.dart';
import 'core/config/web_config.dart';
import 'core/config/http_api_client.dart';
import 'core/localization/app_localizations_delegate.dart';
import 'core/providers/theme_provider.dart';
import 'core/services/preferences.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/guards/auth_guard.dart';
import 'features/modules/brand/providers/brand_provider.dart';
import 'features/modules/employee/providers/employee_provider.dart';
import 'features/modules/purchase _order/providers/purchase _order_provider.dart';
import 'features/modules/request_articles/providers/request_articles_provider.dart';
import 'features/modules/supplier/providers/supplier_provider.dart';
import 'features/home/providers/dashboard_provider.dart';
import 'features/home/services/dashboard_service.dart';

Future<void> main() async {
  // Evitar el error de "WidgetsBinding not initialized"
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar error handling para Flutter web
  if (kIsWeb) {
    WebConfig.configureWebDevelopment();
  }

  // Cargar las variables de entorno
  try {
    await dotenv.load(fileName: Environment.fileName);
  } catch (e) {
    debugPrint('Error loading .env file: $e');
  }

  //Inicializar de las preferencias
  await Preferences.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EmployeeProvider()),
        ChangeNotifierProvider(create: (_) => DepartmentProvider()),
        ChangeNotifierProvider(create: (_) => BrandProvider()),
        ChangeNotifierProvider(create: (_) => UnitProvider()),
        ChangeNotifierProvider(create: (_) => SupplierProvider()),
        ChangeNotifierProvider(create: (_) => ArticleProvider()),
        ChangeNotifierProvider(create: (_) => RequestProvider()),
        ChangeNotifierProvider(create: (_) => PurchaseOrderProvider()),
        // Dashboard Provider con configuración
        ChangeNotifierProvider(
          create: (_) {
            final httpClient = HttpApiClient(Environment.apiUrl);
            final dashboardService = DashboardService(httpClient);
            return DashboardProvider(dashboardService);
          },
        ),
      ],
      child: const AuthInitializer(child: MyApp()),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Screen de lo ya hecho
    // Diagrama de clases UML
    // Diagrama de casos de uso

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'SICOM - Sistema de Compras',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode:
          // themeProvider.isDarkMode ? ThemeMode.dark :
          ThemeMode.light,
      routerConfig: appRouter,
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', ''), Locale('es', '')],
    );
  }
}
