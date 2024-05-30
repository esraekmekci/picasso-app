import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:picasso/login.dart';  // LoginPage'nizin doğru yolda olduğundan emin olun

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isFavoritesPage;  // Favoriler sayfası mı değil mi kontrolü

  CustomAppBar({
    Key? key,
    this.isFavoritesPage = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Elemanları kenarlara yaslar
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.amber.shade600),
            onPressed: () => Navigator.pop(context),
          ),
          // Spacer widget'ları her iki tarafın boşluklarını dengeler
          Spacer(),
          Image.asset(
            'assets/picaßo.png',
            height: 200,
          ),
          Spacer(),
          // Sadece favoriler sayfasındaysa sağdaki çıkış ikonunu göster
          if (isFavoritesPage)
            IconButton(
              icon: Icon(Icons.exit_to_app, color: Colors.amber.shade600),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("You have successfully logged out"),
                      duration: Duration(seconds: 2),
                    ),
                  );
                });
              },
            ),
          if (!isFavoritesPage) Container(width: 48), // Eğer çıkış ikonu yoksa, simetriyi korumak adına boş bir konteyner koy
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
