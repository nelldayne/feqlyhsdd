import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class BottomNavBarUser extends StatefulWidget {
  final int SelectedItem;
  final Function(int) onTap;
  const BottomNavBarUser({super.key, required this.onTap,required this.SelectedItem});

  @override
  State<BottomNavBarUser> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBarUser> {
  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    return Container(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: w*0.05,vertical: h*.01),
        child: GNav(
          gap: 10,
          tabBorderRadius: 100,
          backgroundColor: Colors.white,
          activeColor: Colors.white,
          color: Colors.blue,
          tabBackgroundGradient: LinearGradient(
              colors:[
                Colors.blue[400]!,
                Colors.blueAccent.shade700
              ],
              begin: Alignment.topLeft,
              end: Alignment.topRight
          ),
          iconSize: 30,
          textSize: 18,
          padding: EdgeInsets.symmetric(horizontal: w*.01,vertical: h*.01),
          tabs: [
            GButton(icon: CupertinoIcons.home, text: 'Trang chủ',),
            GButton(icon: Icons.support_agent, text: 'Hỗ trợ',),
            GButton(icon: CupertinoIcons.person, text: 'Cá nhân',),

          ],
          onTabChange: widget.onTap,
          selectedIndex: 0,
        ),
      ),
    );
  }
}
