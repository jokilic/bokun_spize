![Header](https://raw.githubusercontent.com/jokilic/bokun_spize/main/screenshots/header-wide.png)

- [ ] Different widget indicating missed notification permissions (it's too similar to list tiles, ask Google Stitch for help)
- [ ] Like 'Messages' where we parse all `contactMessages` and show in sheet, do the same parsing implementation for relevant users `dailySummaries` + a `NotificationHistorySheet` where it'll be shown (accessed from `AccountScreen`, like `MessagesSheet`)
- [ ] Think about how to approach `AIMeal` and `ManualMeal` FABs in `MealsScreen`
- [ ] Check all snackbars and make sure they show good error messages
- [ ] Perhaps some loading when deleting user
- [ ] Logout doesn't go to `EntranceScreen` right away, it takes some time. Perhaps loading or somekind of 'hack' to show Entrance and logout in the background
- [ ] Check this: https://pub.dev/packages/keyboard_controller
- [ ] Animations
- [ ] App name -> Bokun / Bite
- [ ] Go through every hardcoded text and check if it makes sense
- [ ] Add Meal screens - show dismissible widgets with info
- [ ] `AccountScreen`
    - [ ] Notifications
- [ ] Firebase App Check
    - [ ] Add the Play App Signing SHA-256
    - [ ] Change PLAY_RECOGNIZED to Required
    - [ ] Optionally change LICENSED to Required
    - [ ] Minimum acceptable device integrity -> Don't explicitly check
    - [ ] The legacy sideloaded APK will then stop working
- [ ] Analytics
- [ ] Crashlytics
- [ ] Perhaps anonymous sign-in
- [ ] App purchases - Research & initial implementation

### Quick test checklist

1. Create AI meal in English
    - Verify Firestore contains complete `en` and `hr` objects
    - Verify English values appear in the app
2. Switch app to Croatian
    - Verify the same meal immediately displays Croatian names and units
    - Nutrition, quantities, emojis, and colors should remain consistent
3. Create AI meal in Croatian
    - Verify both language objects are generated
    - Switch languages and verify both versions
4. Test AI inputs
    - Text only
    - Image only
    - Text and image together
5. Test existing meals
    - Open an older root-level meal
    - Verify it still displays correctly in both app languages
    - Verify search can find it
6. Create a manual meal
    - Verify it saves at the document root without `en`/`hr`
    - Verify it displays correctly after changing language
7. Edit a manual meal
    - Verify name, foods, nutrition, date, and image changes persist
8. Edit a localized AI meal
    - Verify the current behavior: `en`/`hr` are removed and replaced by root-level values
    - Decide whether this flattening is acceptable
9. Copy a localized AI meal
    - Verify the copy becomes root-level in the active language **(now it will copy both languages)**
    - Verify the original remains bilingual
10. Search and daily summary
    - Search for meal and food names in each active language
    - Verify localized AI meals are included in the next daily summary
11. Error handling
    - Test failed image upload or AI generation
    - Verify the meal stops loading and shows the appropriate error without parser failures

# Bokun spize 🥗

🥗 **Bokun spize** is a simple fitness app made in **Flutter**. 👨‍💻

It gives you the ability to add your meals, weights and walks into a list. 🍂\
Everything is displayed using a minimalistic design which gives you all info at a glance. 📈\
You can see data by day and keep everything organized. 🗂️

### Bokun spize can be downloaded from [HERE](https://play.google.com/store/apps/details?id=com.josipkilic.bokun_spize).
&nbsp;

![Multi](https://raw.githubusercontent.com/jokilic/bokun_spize/main/screenshots/multi.png)

**Meals** 🥙

Shows a list of your meals.\
It's grouped by day, so you can see everything properly structured.

**Weights** 🧾

Shows a list of your weights.\
You can add your new weight when necessary.\

**Walks** 🐾

Shows a list of your walks.\
Gets values from your phone data.\

**Account** 📈

Set your calorie goals here.\
Add data about yourself and the app will calculate your daily calorie needs.
