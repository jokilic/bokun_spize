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

Android uses `announcements` when a payload does not specify a channel. The app creates all channels before Firebase processes messages and requests `POST_NOTIFICATIONS` through `FirebaseMessaging.requestPermission()` on Android 13 and newer.

## iOS authorization

The app requests alert, badge and sound authorization. Firebase can return `authorized`, `denied`, `notDetermined` or `provisional`; callers must preserve these states instead of reducing them to a Boolean. Foreground notifications present alerts, badges and sounds.

The debug build signs with the development APNs environment. Profile and release builds sign with the production APNs environment.

## Physical-device verification

1. Install and open a fresh build on a physical device, then respond to the system notification prompt
2. Retrieve the FCM registration token while debugging or from the device-registration implementation
3. In Firebase Console, use **Messaging → Send test message** and target that token
4. Verify delivery while the app is foregrounded, backgrounded and terminated
5. On Android 13 or newer, repeat once after denying permission and once after granting it in system settings
6. On iOS, verify denied and provisional authorization states separately, using a clean install or device notification settings as needed

Console/APNs configuration and physical-device delivery cannot be verified from source control alone and must be completed for each Firebase and Apple environment.
