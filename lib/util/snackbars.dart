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
            color: BokunSpizeColors.black,
            size: 28,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: BokunSpizeColors.black,
              ),
            ),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      behavior: SnackBarBehavior.floating,
      backgroundColor: BokunSpizeColors.grey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
        side: const BorderSide(
          color: BokunSpizeColors.black,
          width: 1.5,
        ),
      ),
    ),
  );
}
