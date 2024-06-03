import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int? currentIndex;  // Allows null to indicate no selection
  const CustomBottomNavBar({super.key, this.currentIndex});

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  int? _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;  // Initial index set from parent widget
  }

  void _onItemTapped(int index) {
    if (_currentIndex == index) {
      return; // Prevents navigation to the same page.
    }

    setState(() {
      _currentIndex = index;
    });
    
    switch (index) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(context, '/discover', (route) => false);
        break;
      case 1:
        Navigator.pushNamedAndRemoveUntil(context, '/daily', (route) => false);
        break;
      case 2:
        Navigator.pushNamedAndRemoveUntil(context, '/favorites', (route) => false);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _currentIndex ?? 0,  // Defaults to 0 if _currentIndex is null
      onTap: _onItemTapped,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            _currentIndex == 1 ? 'assets/frame_amber.png' : 'assets/frame_grey.png', // Görüntü dosyanızın yolu
            width: 30, // Genişliği ayarlayın
            height: 30, // Yüksekliği ayarlayın
          ),
          label: '',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: '',
        ),
      ],
      selectedItemColor: _currentIndex != null ? Theme.of(context).primaryColor : Colors.grey,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: false,  // Hides selected labels
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
    );
  }
}
