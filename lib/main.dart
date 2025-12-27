import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/database_service.dart';
import 'services/detection_service.dart';
import 'services/location_service.dart';
import 'services/supabase_service.dart';
import 'services/logger_service.dart';
import 'security/app_guard.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';

// ============================================================================
// APP COLORS - Central color definitions for consistency
// ============================================================================
class AppColors {
  // Primary colors (matching website: #134E48)
  static const Color primary = Color(0xFF173F45);
  static const Color primaryLight = Color(0xFF1A6B63);
  static const Color primaryDark = Color(0xFF0D3A35);

  // Secondary/Accent colors (complementary to teal)
  static const Color accent = Color(0xFF4DB6AC);
  static const Color accentLight = Color(0xFF80CBC4);

  // Background colors (dark theme)
  static const Color background = Color(0xFF0A1512);
  static const Color surface = Color(0xFF152420);
  static const Color surfaceLight = Color(0xFF1E332E);

  // Background colors (light theme)
  static const Color backgroundLight = Color(0xFFF8FAF9);
  static const Color surfaceWhite = Colors.white;
  static const Color surfaceLightGray = Color(0xFFF1F5F4);

  // Text colors (dark theme)
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Text colors (light theme)
  static const Color textDark = Color(0xFF1E293B);
  static const Color textGray = Color(0xFF475569);

  // Status colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Border colors
  static const Color border = Color(0xFF2D4548);
  static const Color borderLight = Color(0xFFE2E8F0);

  // Damage type colors
  static const Color berlubang = Color(0xFF3B82F6);
  static const Color retakBuaya = Color(0xFF8B5CF6);
  static const Color amblas = Color(0xFFEF4444);
  static const Color bergelombang = Color(0xFFF97316);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style for a premium look
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.surface,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize services
  log.i('Initializing app...');

  // Load environment variables
  try {
    await dotenv.load(fileName: '.env');
    log.i('Environment variables loaded');
  } catch (e) {
    log.w('.env file not found, using defaults');
  }

  // Security check - verify app is not cloned
  final isValidApp = await AppGuard.initialize();
  if (!isValidApp) {
    log.e('Security check failed - app may be cloned!');
    AppGuard.showSecurityWarning();
  }

  // Initialize database
  final database = AppDatabase();
  log.i('Database initialized');
  await database.syncUnsyncedToSupabase();
  log.d('Detection service will initialize lazily when needed');

  // Initialize Supabase (optional - app works offline if this fails)
  try {
    await SupabaseService.instance.initialize(
      'https://midjlnxbmvzmtuqurceh.supabase.co',
      'sb_publishable_Fs3XPKYrIt6DIOc5u9K52w_Yf6cNi7g',
    );
  } catch (e) {
    log.w('Supabase initialization failed', error: e);
  }

  // Check location permission
  final locationPermission = await LocationService.instance.checkPermission();
  log.d('Location permission: $locationPermission');

  runApp(
    MultiProvider(
      providers: [
        Provider<AppDatabase>.value(value: database),
        Provider<DetectionService>.value(value: DetectionService.instance),
        Provider<LocationService>.value(value: LocationService.instance),
        Provider<SupabaseService>.value(value: SupabaseService.instance),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'VGTec - Pavement Detector',
          debugShowCheckedModeBanner: false,
          theme: _buildLightTheme(),
          darkTheme: _buildDarkTheme(),
          themeMode: themeProvider.themeMode,
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(),
            '/login': (context) => const LoginScreen(),
            '/home': (context) => const HomeScreen(),
          },
        );
      },
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        tertiary: AppColors.primaryLight,
        surface: AppColors.surfaceWhite,
        surfaceContainerHighest: AppColors.surfaceLightGray,
        onPrimary: Colors.white,
        onSurface: AppColors.textDark,
        onSurfaceVariant: AppColors.textGray,
      ),
      scaffoldBackgroundColor: AppColors.backgroundLight,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textDark,
        titleTextStyle: TextStyle(
          color: AppColors.textDark,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: AppColors.surfaceWhite,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceWhite,
        indicatorColor: AppColors.primary.withOpacity(0.15),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary);
          }
          return const IconThemeData(color: AppColors.textMuted);
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderLight,
        thickness: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textDark,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return Colors.grey;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary.withOpacity(0.3);
          }
          return Colors.grey.withOpacity(0.3);
        }),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        tertiary: AppColors.primaryLight,
        surface: AppColors.surface,
        surfaceContainerHighest: AppColors.surfaceLight,
        onPrimary: Colors.white,
        onSurface: Colors.white,
        onSurfaceVariant: AppColors.textSecondary,
      ),
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: AppColors.surface,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withOpacity(0.3),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.accent);
          }
          return const IconThemeData(color: AppColors.textMuted);
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surface,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.accent),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accent,
          side: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }
}
