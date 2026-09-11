import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../../services/firebase_service.dart';
import '../../theme/extensions.dart';
import '../../util/dependencies.dart';
import '../../widgets/navigation_bar_widget.dart';
import '../meals/meals_controller.dart';
import '../walks/walks_controller.dart';
import '../weights/weights_controller.dart';

class AccountScreen extends StatelessWidget {
  /// Cancels user-specific listeners before Firebase sign-out
  Future<void> handleLogOut() async {
    unRegisterIfNotDisposed<MealsController>();
    unRegisterIfNotDisposed<WeightsController>();
    unRegisterIfNotDisposed<WalksController>();

    await getIt.get<FirebaseService>().logOut();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.colors.scaffoldBackground,
    bottomNavigationBar: NavigationBarWidget(),
    floatingActionButton: SizedBox(
      height: 68,
      width: 68,
      child: FloatingActionButton(
        heroTag: const ValueKey('account-fab'),
        elevation: 0,
        backgroundColor: context.colors.delete,
        foregroundColor: context.colors.listTileBackground,
        splashColor: context.colors.listTileBackground.withValues(alpha: 0.5),
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        shape: const CircleBorder(),
        onPressed: () {
          HapticFeedback.lightImpact();
          handleLogOut();
        },
        child: PhosphorIcon(
          PhosphorIconsBold.signOut,
          color: context.colors.listTileBackground,
          size: 32,
        ),
      ),
    ),
  );
}
