import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../constants/colors.dart';
import '../../services/firebase_service.dart';
import '../../util/dependencies.dart';
import '../../widgets/navigation_bar_widget.dart';
import '../meals/meals_controller.dart';
import '../walks/walks_controller.dart';
import '../weights/weights_controller.dart';

class ProfileScreen extends StatelessWidget {
  /// Cancels user-specific listeners before Firebase sign-out
  Future<void> handleLogOut() async {
    unRegisterIfNotDisposed<MealsController>();
    unRegisterIfNotDisposed<WeightsController>();
    unRegisterIfNotDisposed<WalksController>();

    await getIt.get<FirebaseService>().logOut();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: BokunSpizeColors.red,
    bottomNavigationBar: NavigationBarWidget(),
    floatingActionButton: SizedBox(
      height: 68,
      width: 68,
      child: FloatingActionButton(
        heroTag: const ValueKey('profile-fab'),
        elevation: 0,
        backgroundColor: BokunSpizeColors.green,
        foregroundColor: BokunSpizeColors.white,
        splashColor: BokunSpizeColors.white.withValues(alpha: 0.5),
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        shape: const CircleBorder(),
        onPressed: () {
          HapticFeedback.lightImpact();
          handleLogOut();
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
