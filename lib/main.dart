import 'dart:async';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:watch_it/watch_it.dart';

import 'constants/colors.dart';
import 'screens/entrance/entrance_screen.dart';
import 'services/screen_service.dart';
import 'util/dependencies.dart';
import 'util/display_mode.dart';

Future<void> main() async {
  /// Initialize Flutter related tasks
  WidgetsFlutterBinding.ensureInitialized();

  /// Enable high refresh rate
  unawaited(
    setDisplayMode(),
  );

  try {
    await initializeBeforeAppStart();
    registerServices();

    runApp(
      AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
        ),
        child: BokunSpizeApp(),
      ),
    );
  } catch (error) {
    log(
      'Bokun spize startup failed',
      error: error,
    );
  }
}

class BokunSpizeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    home: StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      initialData: FirebaseAuth.instance.currentUser,
      builder: (_, authSnapshot) => authSnapshot.data == null ? EntranceScreen() : BokunSpizeWidget(),
    ),
    locale: const Locale('en'),
    supportedLocales: const [
      Locale('hr'),
      Locale('en'),
    ],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    theme: ThemeData.light().copyWith(
      scaffoldBackgroundColor: BokunSpizeColors.grey,
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: BokunSpizeColors.green,
        selectionColor: BokunSpizeColors.green,
        selectionHandleColor: BokunSpizeColors.green,
      ),
    ),
    builder: (_, child) {
      final appWidget =
          child ??
          const Scaffold(
            body: SizedBox.shrink(),
          );

      return kDebugMode
          ? Banner(
              message: '',
              color: Colors.red,
              location: BannerLocation.topEnd,
              layoutDirection: TextDirection.ltr,
              child: appWidget,
            )
          : appWidget;
    },
  );
}

class BokunSpizeWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) => getIt.get<ScreenService>().getProperWidget(
    watchIt<ScreenService>().value,
  );
}
