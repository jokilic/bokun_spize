import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../constants/colors.dart';
import '../../services/firebase_service.dart';
import '../../util/dependencies.dart';
import '../../widgets/navigation_bar_widget.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.redAccent,
    bottomNavigationBar: NavigationBarWidget(),
    floatingActionButton: SizedBox(
      height: 68,
      width: 68,
      child: FloatingActionButton(
        heroTag: const ValueKey('profile-fab'),
        elevation: 0,
        backgroundColor: BokunSpizeColors.primary,
        foregroundColor: BokunSpizeColors.white,
        splashColor: BokunSpizeColors.white.withValues(alpha: 0.5),
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        shape: const CircleBorder(),
        onPressed: () {
          unawaited(
            HapticFeedback.lightImpact(),
          );
          unawaited(
            getIt.get<FirebaseService>().logOut(),
          );
        },
        child: const PhosphorIcon(
          PhosphorIconsBold.signOut,
          color: BokunSpizeColors.white,
          size: 32,
        ),
      ),
    ),
  );
}
