import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:picasso/login.dart';  // Ensure the path to your LoginPage is correct

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isFavoritesPage;  // Check if it is the favorites page

  CustomAppBar({
    Key? key,
    this.isFavoritesPage = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the current route name
    final String? currentRoute = ModalRoute.of(context)?.settings.name;

    // Determine whether to show the back button
    bool showBackButton = !(currentRoute == '/daily' || currentRoute == '/discover' || currentRoute == '/favorites');

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align items to the edges
        children: [
          if (showBackButton)
            IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.amber.shade600),
              onPressed: () => Navigator.pop(context),
            )
          else
            SizedBox(width: 48), // Placeholder for back button to keep the logo centered
          Flexible(
            child: Image.asset(
              'assets/picaßo.png',
              height: 200,
            ),
          ),
          if (isFavoritesPage)
            IconButton(
              icon: Icon(Icons.exit_to_app, color: Colors.amber.shade600),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                // Remove all routes and navigate to LoginPage
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                  (Route<dynamic> route) => false,
                );
                // Show a SnackBar after the LoginPage is loaded
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("You have successfully logged out"),
                      duration: Duration(seconds: 2),
                    ),
                  );
                });
              },
            )
          else
            SizedBox(width: 48), // Placeholder to keep the logo centered
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
