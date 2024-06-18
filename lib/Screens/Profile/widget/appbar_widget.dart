import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

AppBar buildAppBar(BuildContext context) {


  return AppBar(
    leading: BackButton(),
    backgroundColor: Colors.transparent,
    elevation: 0,
    actions: [
      // ThemeSwitcher(
      //   builder: (context) => IconButton(
      //     icon: Icon(icon),
      //     onPressed: () {
      //       // final theme = isDarkMode ? MyThemes.lightTheme : MyThemes.darkTheme;
      //       //
      //       // final switcher = ThemeSwitcher.of(context)!;
      //       // switcher.changeTheme(theme: theme);
      //     },
      //   ),
      // ),
    ],
  );
}
