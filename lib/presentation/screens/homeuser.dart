import 'package:flutter/material.dart';
import 'package:qlyhoso/components/bottom_nav_bar_user.dart';
import 'package:qlyhoso/presentation/screens/homeuser_screen.dart';
import 'package:qlyhoso/presentation/screens/profile_user_screen.dart';
import 'package:qlyhoso/presentation/screens/yeucauhotro_screen.dart';

class UserHome extends StatefulWidget {
  const UserHome({super.key});

  @override
  State<UserHome> createState() => _HomeState();
}

class _HomeState extends State<UserHome> {
  late PageController pageController;
  int currentIndex = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pageController = PageController(initialPage: currentIndex);
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    pageController.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavBarUser(onTap: (index){
        pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut);
        setState(() {
          currentIndex = index;
        });
      }, SelectedItem: currentIndex),
      body: PageView(
        controller: pageController,
        onPageChanged: (index){
          setState(() {
            currentIndex = index;
          });
        },
        physics: const NeverScrollableScrollPhysics(),
        children: [
          HomeUserScreen(),
          SupportRequestScreen(),
          ProfileScreen()
        ],
      ),
    );
  }
}
