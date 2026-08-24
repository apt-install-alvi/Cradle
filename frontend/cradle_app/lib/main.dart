import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/routes/app_routes.dart';
import 'core/routes/route_generator.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/language_provider.dart';
import 'providers/font_size_provider.dart';
import 'providers/education_provider.dart';
import 'providers/health_tracking_provider.dart';
import 'providers/medication_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/settings_provider.dart';
import 'repositories/medication_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Enable edge-to-edge display
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
    statusBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.dark,
  ));
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(const CradleApp());
}

class CradleApp extends StatelessWidget {
  const CradleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FontSizeProvider()),
        ChangeNotifierProvider(create: (_) => EducationProvider()),
        ChangeNotifierProxyProvider<AuthProvider, HealthTrackingProvider>(
          create: (context) => HealthTrackingProvider(null),
          update: (context, auth, previous) {
            if (previous != null && previous.token == auth.token) return previous;
            return HealthTrackingProvider(auth.token);
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, SettingsProvider?>(
          create: (context) => null,
          update: (context, auth, previous) {
            if (!auth.isLoggedIn) return null;
            if (previous != null) return previous;
            return SettingsProvider(auth.token);
          },
        ),
        ChangeNotifierProxyProvider<SettingsProvider?, LanguageProvider>(
          create: (_) => LanguageProvider(),
          update: (_, settings, language) {
            if (settings != null && settings.language != language!.localeCode) {
              Future.microtask(() => language.setLocaleCode(settings.language));
            }
            return language!;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, MedicationProvider?>(
          create: (context) => null,
          update: (context, auth, previous) {
            if (!auth.isLoggedIn) return null;
            if (previous != null) return previous;
            final repo = MedicationRepository(auth.token ?? '');
            return MedicationProvider(repo);
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, NotificationProvider?>(
          create: (context) => null,
          update: (context, auth, previous) {
            if (!auth.isLoggedIn) return null;
            if (previous != null) return previous;
            return NotificationProvider(auth.token);
          },
        ),
      ],
      child: Consumer<FontSizeProvider>(
        builder: (context, fontSizeProvider, child) {
          return MaterialApp(
            title: 'Cradle',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            initialRoute: AppRoutes.splash,
            onGenerateRoute: RouteGenerator.generateRoute,
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(fontSizeProvider.scaleFactor),
                ),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}
