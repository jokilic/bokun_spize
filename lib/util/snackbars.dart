import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../constants/colors.dart';

void showSnackbar(
  BuildContext context, {
  required String text,
  required IconData icon,
}) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      elevation: 1,
      content: Row(
        children: [
          PhosphorIcon(
            icon,
            color: BokunSpizeColors.neutralDark,
            size: 28,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      behavior: SnackBarBehavior.floating,
      backgroundColor: BokunSpizeColors.neutralLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(
          color: BokunSpizeColors.neutralDark,
          width: 1.5,
        ),
      ),
    ),
  );
}
