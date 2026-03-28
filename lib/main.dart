import 'dart:async';

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:watch_it/watch_it.dart';

import 'firebase_options.dart';
import 'generated/codegen_loader.g.dart';
import 'screens/home/home_screen.dart';
import 'theme/colors.dart';
import 'theme/extensions.dart';
import 'theme/theme.dart';
import 'util/dependencies.dart';
import 'util/display_mode.dart';
import 'util/localization.dart';

Future<void> main() async {
  /// Initialize Flutter related tasks
  WidgetsFlutterBinding.ensureInitialized();

  /// Initialize everything before starting app
  await initializeBeforeAppStart();

  /// Get `settings` value from [Hive]
  // final settings = getIt.get<HiveService>().getSettings();

  /// Run `Troško`
  runApp(
    const AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
      child: BokunSpizeApp(
        // isLoggedIn: settings.isLoggedIn && FirebaseAuth.instance.currentUser != null,
        isLoggedIn: false,
      ),
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
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  /// Set refresh rate to high
  await setDisplayMode();

  /// Initialize [EasyLocalization]
  await initializeLocalization();

  /// Initialize [Firebase]
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  /// Initialize services
  await initializeServices();
}

class BokunSpizeApp extends StatelessWidget {
  final bool isLoggedIn;

  const BokunSpizeApp({
    required this.isLoggedIn,
  });

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
    child: BokunSpizeWidget(
      isLoggedIn: isLoggedIn,
    ),
  );
}

class BokunSpizeWidget extends WatchingWidget {
  final bool isLoggedIn;

  const BokunSpizeWidget({
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context)
  // final settings = watchIt<HiveService>().value.settings;
  // final activeBokunSpizeTheme = getBokunSpizeTheme(
  //   id: settings?.bokunSpizeThemeId,
  //   primaryColor: settings?.primaryColor ?? context.colors.buttonPrimary,
  // );
  => MaterialApp(
    localizationsDelegates: context.localizationDelegates,
    supportedLocales: context.supportedLocales,
    locale: context.locale,
    debugShowCheckedModeBanner: false,
    home: HomeScreen(),
    // home: isLoggedIn
    //     ? const HomeScreen(
    //         key: ValueKey('home'),
    //       )
    //     : const EntranceScreen(
    //         key: ValueKey('entrance'),
    //       ),
    onGenerateTitle: (_) => 'appName'.tr(),
    // theme:
    //     activeBokunSpizeTheme ??
    //     BokunSpizeTheme.light(
    //       primaryColor: settings?.primaryColor,
    //     ),
    // darkTheme:
    //     activeBokunSpizeTheme ??
    //     BokunSpizeTheme.dark(
    //       primaryColor: settings?.primaryColor,
    //     ),
    // themeMode: activeBokunSpizeTheme == null ? ThemeMode.system : null,
    // themeAnimationDuration: BokunSpizeDurations.animation,
    theme: BokunSpizeTheme.light(
      primaryColor: BokunSpizeColors.darkBlue,
    ),
    themeAnimationCurve: Curves.easeIn,
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
