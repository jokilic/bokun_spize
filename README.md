### To-Do

- [ ] Finish `Readme.md`
- [ ] Add icon & splash screen
- [ ] Split `meals` into days, like in [Troško]
- [ ] Changing from `isLoading` to proper [Meal] or `error` should be animated
- [ ] Add missing values when expanding [BokunSpizeListTile]

- [x] Add `error` for each [Meal]
- [x] Place speech along with logic and permissions into [Sheet]
- [x] When starting app, if there's any [Meal] with `isLoading` in [Hive], remove it
- [x] Add `Be explicit` text in [Sheet]
- [x] Cleanup unnecessary code

![Header](https://raw.githubusercontent.com/jokilic/bokun_spize/main/screenshots/header-wide.png)


# Bokun spize 🥗

🥗 **Bokun spize** is a simple calorie tracker made in **Flutter**. 👨‍💻

It gives you the ability to add expenses into various categories. 💰\
Expenses are displayed using a minimalistic design which gives you all info at a glance. 📈\
You can filter data by month and keep everything organized. 🗂️

### Bokun spize can be downloaded from [HERE](https://play.google.com/store/apps/details?id=com.josipkilic.bokun_spize).
&nbsp;

![Multi](https://raw.githubusercontent.com/jokilic/bokun_spize/main/screenshots/multi.png)

**Expenses** 💶

Shows a list of your expenses.\
You can change the month, which will filter the values.\
You can filter by category, which will let you see data more clearly.

**New expense** 🧾

Add new expense here.\
You need to choose a category, expense name and amount spent.\
There's a possibility to write a more detailed note or change the time of the expense.\
Expense can also be edited or deleted if necessary.

**New category** 🎨

Add new category here.\
You need to choose a color, category name and icon.\
Category can also be edited or deleted if necessary.

**New location** 📍

Add new location here.\
You need to choose a color, location name and icon.\
You can add an address to your location.\
Location can also be edited or deleted if necessary.
