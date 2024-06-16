import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<NotificationModel> _notifications = [
    NotificationModel(
      title: 'Complain Posted Successfully',
      description: 'Your complain has been posted successfully.',
      icon: Icons.check_circle,
      iconColor: Colors.green,
      read: false,
    ),
    NotificationModel(
      title: 'New Message',
      description: 'You have received a new message from the authority.',
      icon: Icons.message,
      iconColor: Colors.blue,
      read: true,
    ),
  ];

  int get unreadNotificationsCount =>
      _notifications.where((notification) => !notification.read).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return NotificationCard(
            notification: notification,
            onNotificationRead: () {
              setState(() {
                notification.read = true;
              });
            },
          );
        },
      ),
    );
  }
}

class NotificationModel {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  bool read;

  NotificationModel({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    this.read = false,
  });
}

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onNotificationRead;

  const NotificationCard({super.key, 
    required this.notification,
    required this.onNotificationRead,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        leading: Icon(
          notification.icon,
          color: notification.iconColor,
          size: 36.0,
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: notification.read ? Colors.grey : Colors.black,
          ),
        ),
        subtitle: Text(
          notification.description,
          style: TextStyle(
            color: notification.read ? Colors.grey : Colors.black,
          ),
        ),
        onTap: () {
          onNotificationRead(); // Mark the notification as read
          // Add any specific action you want to perform when the card is tapped
        },
      ),
    );
  }
}

class MyDrawer extends StatelessWidget {
  final int unreadNotificationsCount;

  const MyDrawer({super.key, required this.unreadNotificationsCount});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Stack(
            children: [
              const Icon(Icons.notifications),
              if (unreadNotificationsCount > 0)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      unreadNotificationsCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          label: 'Notifications',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}
