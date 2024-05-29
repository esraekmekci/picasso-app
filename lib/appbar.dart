import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  CustomAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.amber.shade600),
        onPressed: () => Navigator.pop(context),
        
      ),
      
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center, // Logo'nun gerçekten merkezde olmasını sağlar
        children: [
          Expanded(
            child: Image.asset(
              'assets/picaßo.png',
              height: 200, 
            ),
          ),
          SizedBox(width: AppBar().preferredSize.height), // Sağ taraf için yer bırakır, simetrik görünüm sağlar
        ],
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
    );
    
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
