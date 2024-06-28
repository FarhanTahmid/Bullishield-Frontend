import 'package:flutter/material.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  UserProfileState createState() => UserProfileState();
}

class UserProfileState extends State<UserProfileScreen> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController birthController = TextEditingController();
  final TextEditingController homeAddressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  const CircleAvatar(
                    radius: 80,
                    backgroundImage: AssetImage('assets/ProfilePicture.png'),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt),
                      onPressed: () {
                        // Add functionality to change profile picture
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildEditableField('First Name', fullNameController, true),
              _buildEditableField('Last Name', lastNameController, true),
              _buildEditableField('Email', emailController, true),
              _buildEditableField('Birth Date', birthController, true),
              _buildEditableField('Home Address', homeAddressController, true),
              _buildEditableField('Organization ID', TextEditingController(text: '123456'), false),
              _buildEditableField('Gender', TextEditingController(text: 'Male'), false),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Add functionality to update profile
                },
                child: const Text('Update Profile'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _showChangePasswordDialog(context);
                },
                child: const Text('Change Password'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  // Add functionality to logout
                },
                child: const Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller, bool isEditable) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        enabled: isEditable,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController currentPasswordController = TextEditingController();
        final TextEditingController newPasswordController = TextEditingController();
        final TextEditingController confirmPasswordController = TextEditingController();
        bool showPassword = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Change Password'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: currentPasswordController,
                    obscureText: !showPassword,
                    decoration: InputDecoration(
                      labelText: 'Current Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          showPassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            showPassword = !showPassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: newPasswordController,
                    obscureText: !showPassword,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          showPassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            showPassword = !showPassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: !showPassword,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          showPassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            showPassword = !showPassword;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Add functionality to update password
                  },
                  child: const Text('Update Password'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
