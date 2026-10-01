import 'dart:async';
import 'dart:developer';

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:watch_it/watch_it.dart';

import 'constants/durations.dart';
import 'generated/codegen_loader.g.dart';
import 'screens/entrance/entrance_screen.dart';
import 'services/screen_service.dart';
import 'services/theme_service.dart';
import 'theme/extensions.dart';
import 'theme/theme.dart';
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
    await registerServices();

    runApp(
      BokunSpizeApp(),
    );
  } catch (error) {
    log(
      'Bokun spize startup failed',
      error: error,
    );
  }
}

class BokunSpizeApp extends WatchingWidget {
  @override
  Widget build(BuildContext context) => EasyLocalization(
    useOnlyLangCode: true,
    supportedLocales: const [
      Locale('en'),
      Locale('hr'),
    ],
    fallbackLocale: const Locale('hr'),
    path: 'assets/translations',
    assetLoader: const CodegenLoader(),
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        initialData: FirebaseAuth.instance.currentUser,
        builder: (_, authSnapshot) => authSnapshot.data == null ? EntranceScreen() : BokunSpizeWidget(),
      ),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      onGenerateTitle: (_) => 'appName'.tr(),
      themeMode: watchIt<ThemeService>().value,
      theme: BokunSpizeTheme.light(),
      darkTheme: BokunSpizeTheme.dark(),
      themeAnimationCurve: Curves.easeIn,
      themeAnimationDuration: BokunSpizeDurations.animation,
      builder: (context, child) {
        final overlayStyle = Theme.brightnessOf(context) == Brightness.dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;

        final appWidget =
            child ??
            const Scaffold(
              body: SizedBox.shrink(),
            );

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: overlayStyle.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.transparent,
          ),
          child: kDebugMode
              ? Banner(
                  message: '',
                  color: context.colors.fat,
                  location: BannerLocation.topEnd,
                  layoutDirection: TextDirection.ltr,
                  child: appWidget,
                )
              : appWidget,
        );
      },
    ),
  );
}

class BokunSpizeWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) => getIt.get<ScreenService>().getProperWidget(
    watchIt<ScreenService>().value,
  );
}
