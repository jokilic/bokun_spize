import 'package:url_launcher/url_launcher.dart';

/// Checks whether [email] has a valid email address format
bool isValidEmail(String email) {
  /// [RegEx] pattern for email validation
  final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  return emailRegExp.hasMatch(email);
}

/// Opens the default email application with `email` as the recipient
Future<bool> openEmail(String email) => launchUrl(
  Uri(
    scheme: 'mailto',
    path: email,
  ),
);
