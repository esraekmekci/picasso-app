import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  CustomAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
        title: Image.asset(
          'assets/picaßo.png',  // Make sure the asset path is correctly given
          height: 200, // You can adjust the size according to your needs
          width: 1000,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,  // If you want the logo to be centered
        automaticallyImplyLeading: false,
      );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
