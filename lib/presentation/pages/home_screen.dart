import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:rakna_app/presentation/pages/map_screen.dart';
import 'package:rakna_app/presentation/pages/explore_screen.dart';
import 'package:rakna_app/presentation/pages/reservations_screen.dart';
import 'package:rakna_app/presentation/pages/account_screen.dart';
import 'package:rakna_app/presentation/widgets/glass_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _navBarVisible = true;

  final List<Widget> _screens = const [
    MapScreen(),
    ExploreScreen(),
    ReservationsScreen(),
    AccountScreen(),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBody: true,
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is UserScrollNotification) {
            if (notification.direction == ScrollDirection.reverse &&
                _navBarVisible) {
              setState(() => _navBarVisible = false);
            } else if (notification.direction == ScrollDirection.forward &&
                !_navBarVisible) {
              setState(() => _navBarVisible = true);
            }
          }
          return false;
        },
        child: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: GlassNavBar(
        selectedIndex: _selectedIndex,
        isVisible: _navBarVisible,
        onTabChange: (index) {
          HapticFeedback.selectionClick();
          setState(() {
            _selectedIndex = index;
            _navBarVisible = true;
          });
        },
      ),
    );
  }
}
