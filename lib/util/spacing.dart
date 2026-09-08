import 'package:flutter/material.dart';

double getTopSpacing(BuildContext context) => MediaQuery.paddingOf(context).top + MediaQuery.viewInsetsOf(context).top + 16;

double getBottomSpacing(BuildContext context) => MediaQuery.paddingOf(context).bottom + MediaQuery.viewInsetsOf(context).bottom + 16;
