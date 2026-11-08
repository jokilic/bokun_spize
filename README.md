![Header](https://raw.githubusercontent.com/jokilic/bokun_spize/main/screenshots/header-wide.png)

- [ ] Replace all `TextStyle()`
- [ ] Animations
    - [ ] Staggered animation in `MealsSuccess` - animate 7 list tiles instead of 5
    - [ ] `AccountScreen` - Staggered animation - Fix language and notification ListTiles fading at same time
    - [ ] `CalendarSheet` - Staggered animation - title -> subtitle -> calendar
    - [ ] `TimeSheet` - Staggered animation - title -> subtitle -> picker
    - [ ] `WeightsAddWeightSheet` - Staggered animation - title -> subtitle -> time -> kilograms -> picker -> two buttons -> main button
- [ ] Think about `constants.dart`
- [ ] Maybe smaller button padding and text size
    - [ ] New to Bokun spize - smaller font
- [ ] App name -> Bokun / Bite
- [ ] Email that user gets when logged in using Google and probably Apple
- [ ] Remove Apple login from Android
- [ ] Go through every hardcoded text and check if it makes sense
- [ ] Test by writing nonsense in the [AIAddMealScreen]
- [ ] Add Meal screens - show dismissible widgets with info
- [ ] `AccountScreen`
    - [ ] Notifications
        - [ ] Notifications reminding to weight
        - [ ] Notifications analyzing previous day (meals, weight, walks)
        - [ ] Announcements
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
