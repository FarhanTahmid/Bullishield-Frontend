import 'package:bullishield/Screens/NavScreen/ComplainFormScreen.dart';
import 'package:bullishield/Screens/ProctorView/proctor_homepage.dart';
import 'package:bullishield/Screens/Profile/user_profile_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Screens/Login/login_screen.dart';
import 'package:bullishield/backend_config.dart';
import 'package:bullishield/user_info.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => MyDrawerState();
}

class MyDrawerState extends State<MyDrawer> {
  String username = '';
  String email = '';
  String userImageUrl = '';
  String userFullName = '';

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    UserInfo userInfo = UserInfo();
    BackendConfiguration backend = BackendConfiguration();
    String backendApiURL = backend.getBackendApiURL();

    Map<String, dynamic>? userDetails = await userInfo.getUsername();
    if (userDetails != null) {
      setState(() {
        userFullName = userDetails['full_name'] ?? '';
        username = userDetails['user_id'] ?? '';
        email = userDetails['email_address'] ?? '';
        userImageUrl = userDetails['user_picture'] ?? '';
        userImageUrl = backendApiURL + userImageUrl;
      });
    }
  }

  Future<void> removeToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }

  Future<void> removeUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
  }

  Future<void> _logout(BuildContext context) async {
    // Remove tokens
    await removeToken();
    await removeUsername();

    // Navigate to login screen
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logout(context);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.purple.shade100,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.purpleAccent),
              margin: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              child: UserAccountsDrawerHeader(
                accountName: Text(userFullName),
                accountEmail: Text(email),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: NetworkImage(userImageUrl),
                ),
              ),
            ),
            ListTile(
              onTap: () {
                Navigator.pop(context);
              },
              leading: Icon(
                CupertinoIcons.house_fill,
                color: Colors.purple.shade900,
              ),
              title: Text(
                "Home",
                textScaler: const TextScaler.linear(1.2),
                style: TextStyle(
                  color: Colors.purple.shade900,
                ),
              ),
            ),
            ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserProfileScreen(),
                  ),
                );
              },
              leading: Icon(
                CupertinoIcons.profile_circled,
                color: Colors.purple.shade900,
              ),
              title: Text(
                "Profile",
                textScaler: const TextScaler.linear(1.2),
                style: TextStyle(
                  color: Colors.purple.shade900,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => NotificationScreen(),
                //   ),
                // );
              },
              child: ListTile(
                leading: Icon(
                  CupertinoIcons.bell_circle_fill,
                  color: Colors.purple.shade900,
                ),
                title: Text(
                  "Notifications",
                  textScaler: const TextScaler.linear(1.2),
                  style: TextStyle(
                    color: Colors.purple.shade900,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => ChatBotScreen(),
                //   ),
                // );
              },
              child: ListTile(
                leading: Icon(
                  CupertinoIcons.chat_bubble_2_fill,
                  color: Colors.purple.shade900,
                ),
                title: Text(
                  "Talk to ChatBot",
                  textScaler: const TextScaler.linear(1.2),
                  style: TextStyle(
                    color: Colors.purple.shade900,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ComplainFormScreen(),
                  ),
                );
              },
              child: ListTile(
                leading: Icon(
                  CupertinoIcons.add_circled_solid,
                  color: Colors.purple.shade900,
                ),
                title: Text(
                  "Add New Complain",
                  textScaler: const TextScaler.linear(1.2),
                  style: TextStyle(
                    color: Colors.purple.shade900,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                // if (widget.currentUser.is_proctor) {
                //   Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //       builder: (context) => ProctorScreen(),
                //     ),
                //   );
                // } else {
                //   if (Platform.isWindows) {
                //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                //       content: Text("You are not a Proctor!"),
                //     ));
                //   } else if (Platform.isAndroid) {
                //     Fluttertoast.showToast(
                //       msg: "You are not a Proctor!",
                //       toastLength: Toast.LENGTH_SHORT,
                //       gravity: ToastGravity.BOTTOM,
                //       timeInSecForIosWeb: 1,
                //       backgroundColor: Colors.grey[700],
                //       textColor: Colors.white,
                //       fontSize: 16.0,
                //     );
                //   }
                // }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProctorHomepage(),
                  ),
                );
              },
              child: ListTile(
                leading: Icon(
                  CupertinoIcons.person_crop_rectangle,
                  color: Colors.purple.shade900,
                ),
                title: Text(
                  "Proctor page",
                  textScaler: const TextScaler.linear(1.2),
                  style: TextStyle(
                    color: Colors.purple.shade900,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                _showLogoutDialog(context);
              },
              child: ListTile(
                leading: Icon(
                  CupertinoIcons.greaterthan_circle_fill,
                  color: Colors.purple.shade900,
                ),
                title: Text(
                  "Logout",
                  textScaler: const TextScaler.linear(1.2),
                  style: TextStyle(
                    color: Colors.purple.shade900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
