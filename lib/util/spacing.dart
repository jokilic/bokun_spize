import 'package:flutter/material.dart';

double getBottomSpacing(BuildContext context) => MediaQuery.paddingOf(context).bottom + MediaQuery.viewInsetsOf(context).bottom + 16;
