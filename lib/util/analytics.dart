enum AnalyticsEvent {
  mealSubmitted('meal_submitted'),
  mealSaveFailed('meal_save_failed'),
  mealDetailsOpened('meal_details_opened'),
  mealEdited('meal_edited'),
  mealCopied('meal_copied'),
  mealDeleted('meal_deleted'),
  mealCalendarUsed('meal_calendar_used'),
  mealPhotoAdded('meal_photo_added'),
  voiceInputFinished('voice_input_finished'),
  mealSearchOpened('meal_search_opened'),
  mealSearchCompleted('meal_search_completed'),
  mealSearchResultOpened('meal_search_result_opened'),
  primaryTabViewed('primary_tab_viewed'),
  notificationPermissionResult('notification_permission_result'),
  notificationPreferenceChanged('notification_preference_changed'),
  notificationDestinationOpened('notification_destination_opened'),
  notificationHistoryOpened('notification_history_opened'),
  passwordResetRequested('password_reset_requested'),
  accountDeletionStarted('account_deletion_started'),
  accountDeletionFailed('account_deletion_failed'),
  themeChanged('theme_changed'),
  languageChanged('language_changed'),
  contactFormOpened('contact_form_opened'),
  contactMessageSent('contact_message_sent'),
  contactMessageFailed('contact_message_failed');

  const AnalyticsEvent(this.eventName);

  final String eventName;
}

enum HealthAnalyticsEvent {
  weightEntryOpened('weight_entry_opened'),
  weightEntrySaved('weight_entry_saved'),
  weightEntryDeleted('weight_entry_deleted'),
  weightChartRangeChanged('weight_chart_range_changed'),
  stepPermissionResult('step_permission_result'),
  stepHistoryPermissionResult('step_history_permission_result'),
  walksChartRangeChanged('walks_chart_range_changed'),
  walksRetryTapped('walks_retry_tapped'),
  profileSettingsSaved('profile_settings_saved'),
  nutritionGoalsOpened('nutrition_goals_opened'),
  nutritionGoalsSaved('nutrition_goals_saved');

  const HealthAnalyticsEvent(this.eventName);

  final String eventName;
}

enum StepPermissionOutcome {
  granted,
  denied,
  unavailable,
  unknown,
  error,
}

enum MealSaveFailure {
  validation,
  imageUpload('image_upload'),
  generation,
  quota,
  persistence,
  request;

  const MealSaveFailure([this.eventValue]);

  final String? eventValue;
}

enum VoiceInputSurface {
  aiMeal('ai_meal'),
  manualMeal('manual_meal'),
  search('search');

  const VoiceInputSurface(this.eventValue);

  final String eventValue;
}

enum MealAnalyticsMethod {
  manual,
  ai,
}
