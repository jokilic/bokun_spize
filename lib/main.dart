import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:watch_it/watch_it.dart';

import 'constants/durations.dart';
import 'firebase_options.dart';
import 'screens/home/home_screen.dart';
import 'theme/colors.dart';
import 'theme/extensions.dart';
import 'theme/theme.dart';
import 'util/dependencies.dart';
import 'util/display_mode.dart';

Future<void> main() async {
  /// Initialize Flutter related tasks
  WidgetsFlutterBinding.ensureInitialized();

  /// Initialize everything before starting app
  await initializeBeforeAppStart();

  /// Run `Troško`
  runApp(
    AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
      child: BokunSpizeApp(),
    ),
  );
}

/// Initialize all functionality before starting app
Future<void> initializeBeforeAppStart() async {
  /// Make sure the orientation is only `portrait`
  await SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp],
  );

  /// Use `edge-to-edge` display
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );

  /// Set refresh rate to high
  await setDisplayMode();

  /// Initialize date formatting
  await initializeDateFormatting('en');
  await initializeDateFormatting('hr');

  /// Initialize [Firebase]
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  /// Initialize services
  await initializeServices();
}

class BokunSpizeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => BokunSpizeWidget();
}

class BokunSpizeWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomeScreen(),
    locale: const Locale('hr'),
    supportedLocales: const [
      Locale('hr'),
      Locale('en'),
    ],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    themeMode: ThemeMode.light,
    theme: BokunSpizeTheme.light(
      primaryColor: BokunSpizeColors.primaryLight,
    ),
    darkTheme: BokunSpizeTheme.dark(
      primaryColor: BokunSpizeColors.primaryDark,
    ),
    themeAnimationCurve: Curves.easeIn,
    themeAnimationDuration: BokunSpizeDurations.animation,
    builder: (_, child) {
      final appWidget =
          child ??
          const Scaffold(
            body: SizedBox.shrink(),
          );

      return kDebugMode
          ? Banner(
              message: '',
              color: context.colors.buttonPrimary,
              location: BannerLocation.topEnd,
              layoutDirection: TextDirection.ltr,
              child: appWidget,
            )
          : appWidget;
    },
  );
}
