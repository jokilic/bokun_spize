![Header](https://raw.githubusercontent.com/jokilic/bokun_spize/main/screenshots/header-wide.png)

- [x] Move meal generation logic to backend + remove AIService (handling AI in-app)
- [x] Generate meals in English and Croatian
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
