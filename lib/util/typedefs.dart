import 'dart:io';

typedef MealSheetResult = ({String? words, DateTime? dateTime, File? imageFile, bool deleteMeal});

typedef ReauthenticationResult = ({bool success, String? appleAuthorizationCode});
