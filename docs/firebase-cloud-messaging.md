# Firebase Cloud Messaging setup

The app uses Firebase Cloud Messaging for every user-visible system notification. It does not schedule local notifications.

## Firebase and Apple configuration

1. Open the `bokun-spize` project in Google Cloud Console and verify that **Firebase Cloud Messaging API (V1)** is enabled
2. In Apple Developer, create an APNs authentication key with the **Apple Push Notifications service (APNs)** capability and securely download the `.p8` file
3. In Firebase Console, open **Project settings → Cloud Messaging → Apple app configuration** for `com.josipkilic.bokunSpize`
4. Upload the `.p8` file and enter its key ID and Apple team ID (`QDS42PXGRU`)
5. Keep the APNs key outside source control and the application bundle

The Xcode project enables **Push Notifications** and **Background Modes → Remote notifications**. Firebase method swizzling is explicitly enabled through `FirebaseAppDelegateProxyEnabled` in `Info.plist`. Do not disable it unless APNs token forwarding is implemented in `AppDelegate`.

## Android channels

Server payloads must use one of these stable `android.notification.channel_id` values:

| Channel ID | Purpose | Importance |
| --- | --- | --- |
| `reminders` | Weigh-in and activity reminders | High |
| `daily_summaries` | Previous-day and progress summaries | Default |
| `announcements` | Product announcements and fallback notifications | Default |

Android uses `announcements` when a payload does not specify a channel. The app creates all channels before Firebase processes messages and requests `POST_NOTIFICATIONS` through `FirebaseMessaging.requestPermission()` only after the user presses **Allow notifications** in Account → Notifications.

## iOS authorization

The app requests alert, badge and sound authorization only after the user presses **Allow notifications**. Firebase can return `authorized`, `denied`, `deniedPermanently`, `notDetermined` or `provisional`; callers preserve these states instead of reducing them to a Boolean. iOS presents foreground alerts, badges and sounds. Android intentionally does not present notifications while the app is in the foreground.

## Notification preferences

Client-managed preferences are stored at `users/{uid}/notificationSettings/preferences`. Firestore rules restrict access to the owning user, reject unexpected fields and prevent clients from writing server-managed scheduling timestamps.

The `syncNotificationSchedule` Cloud Function calculates the next delivery timestamp whenever a reminder is enabled or the user's timezone changes. Weigh reminders run at 07:00 local time and daily summaries run at 08:00 local time. The mobile client does not schedule local notifications.

The `dispatchScheduledNotifications` Cloud Function runs every 10 minutes. It queries the indexed `nextWeighReminderAt` and `nextDailySummaryAt` collection-group timestamps rather than scanning users. Before sending, it creates `users/{uid}/notificationDispatches/{type_localDate}` and advances the next occurrence in one Firestore transaction. That reservation makes overlapping and retried executions idempotent. Dispatch documents are server-only and must not be made client-writable.

Occurrence calculation uses the user's IANA timezone through timezone database rules, so the local delivery hour remains stable across daylight-saving changes. A missing or invalid timezone falls back to UTC. Each user is isolated during processing, so one failed query or FCM request does not stop delivery for other users.

The debug build signs with the development APNs environment. Profile and release builds sign with the production APNs environment.

## Per-device registrations

After notification permission is granted, each signed-in installation writes one document at `users/{uid}/notificationDevices/{deviceId}`. The device ID is a random installation UUID persisted in shared preferences and is deliberately unrelated to the FCM token. A token refresh therefore updates the existing installation document instead of creating another active record.

Each document contains the current `token`, `locale`, IANA `timezone`, `appVersion`, `deviceInfo`, `createdAt` and `lastActiveAt`. `deviceInfo` is the device name reported by Android or iOS, or the browser user agent on web. The app refreshes the document after authentication, token, permission, locale, preference and foreground-lifecycle changes. Failed synchronization is retried with a bounded backoff.

On logout, the app removes the document, leaves announcement topics and deletes the FCM token before signing out. Deleting the token prevents user-specific delivery even if an offline Firestore deletion has not reached the server yet. A later sign-in obtains a new token and reuses the installation UUID.

Firestore rules allow an owner to get, create, update or delete only a UUID-addressed device document. Collection listing is denied, registration fields are allow-listed and `lastActiveAt` must resolve to the server request time.

## Announcement topics

Announcements use locale-specific `announcements_en` and `announcements_hr` topics. An authorized, signed-in installation subscribes only when `announcementsEnabled` is true. The client reconciles both known topics after startup, token refresh, authentication changes and preference changes so a locale switch cannot leave an old subscription active.

## Sender cleanup and retention

Trusted sender code must retain each token's device-document reference while sending. Delete that document when FCM returns `messaging/registration-token-not-registered`. Delete it for `messaging/invalid-argument` only after the sender has independently validated the complete message payload; otherwise the payload itself may be invalid and healthy registrations must be kept. Handle other per-token failures without aborting delivery to the user's remaining devices.

Never write a complete registration token to application, function or crash logs. Use the device document path or a short irreversible digest when correlation is necessary.

Registrations expire 30 days after their latest successful client synchronization. Enable a Firestore TTL policy for the `lastActiveAt` field on the `notificationDevices` collection group with a 30-day expiration offset. Senders must also ignore documents whose `lastActiveAt` is more than 30 days old because Firestore TTL deletion is asynchronous. Active clients continuously refresh `lastActiveAt`; expired or invalid documents are safe to delete.

## Data payload contract

Every actionable message uses these stable string fields in its FCM `data` payload:

| Field | Required | Supported values |
| --- | --- | --- |
| `type` | Yes | `weightReminder`, `dailySummary`, `announcement` |
| `route` | Yes | `meals`, `weights`, `walks`, `account` |
| `sentAt` | Yes | An ISO-8601 timestamp |
| `idempotencyKey` | Server notifications | A stable `{type}_{localDate}` delivery key |

Unknown, missing or malformed values are ignored safely. Notification taps route to the matching primary application screen. More specific entity routing can be added without changing the base contract.

## Physical-device verification

1. Install and open a fresh build on a physical device, open Account → Notifications, press **Allow notifications** and respond to the system prompt
2. Read the token from the installation's protected `notificationDevices` document using trusted tooling without adding it to logs
3. In Firebase Console, use **Messaging → Send test message** and target that token
4. Verify foreground delivery on iOS and confirm Android stays silent while foregrounded
5. Verify delivery while the app is backgrounded and terminated on both platforms
6. On Android 13 or newer, repeat once after denying permission and once after granting it in system settings
7. On iOS, verify denied and provisional authorization states separately, using a clean install or device notification settings as needed

Console/APNs configuration and physical-device delivery cannot be verified from source control alone and must be completed for each Firebase and Apple environment.

## Functions deployment

Scheduled Functions require the Firebase project to use the **Blaze** pay-as-you-go plan. Before the first deployment, enable the **Cloud Scheduler API**, **Cloud Functions API**, **Cloud Build API**, **Artifact Registry API**, **Eventarc API**, **Pub/Sub API** and **Firebase Cloud Messaging API** for `bokun-spize`. The deployed Node.js service account needs Firestore read/write access and permission to send FCM messages. Application Default Credentials are supplied by the Functions runtime; do not add a service-account key or any Admin credential to the Flutter application.

Install and deploy from the repository root:

```sh
cd functions
npm install
npm run build
cd ..
firebase deploy --only firestore,functions
```

The first index deployment may take several minutes to finish. Wait until both `notificationSettings` collection-group indexes report **Enabled** before relying on the scheduled dispatcher.

For local unit and Firestore emulator coverage:

```sh
cd functions
npm run test:emulator
```

The emulator test starts two concurrent reservations against the same due occurrence and verifies that only one succeeds. Unit coverage also verifies due selection and Europe/Zagreb spring and autumn DST transitions. FCM calls are not made by the emulator test.
