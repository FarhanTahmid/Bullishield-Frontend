import 'package:bullishield/backend_config.dart';
import 'package:bullishield/user_info.dart';
import 'package:flutter/material.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  UserProfileState createState() => UserProfileState();
}

class UserProfileState extends State<UserProfileScreen> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contactNoController = TextEditingController();
  final TextEditingController birthController = TextEditingController();
  final TextEditingController homeAddressController = TextEditingController();
  String organizationID = '';
  String gender = '';
  String userImageUrl = '';

  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  Future<void> getUserInfo() async {
    // function to get user informations and set the fields up
    UserInfo userInfo = UserInfo();
    BackendConfiguration backend = BackendConfiguration();
    String backendApiURL = backend.getBackendApiURL();

    Map<String, dynamic>? userDetails = await userInfo.getUsername();
    if (userDetails != null) {
      setState(() {
        fullNameController.text = userDetails['full_name'] ?? '';
        organizationID = userDetails['user_id'] ?? '';
        contactNoController.text = userDetails['contact_no'] ?? '';
        emailController.text = userDetails['email_address'] ?? '';
        birthController.text = userDetails['birth_date'] ?? '';
        homeAddressController.text = userDetails['home_address'] ?? '';
        gender = userDetails['gender'] ?? '';
        userImageUrl = userDetails['user_picture'] ?? '';
        userImageUrl = backendApiURL + userImageUrl;
      });
    }
  }

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
                  CircleAvatar(
                    radius: 80,
                    backgroundImage: NetworkImage(userImageUrl),
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
              const SizedBox(height: 20),
              Text(
                "Organization ID: $organizationID",style: const TextStyle(
                  fontSize: 16,
                  fontWeight:FontWeight.bold,
                  color:Colors.black,
                ),
              ),
              
              const SizedBox(height: 16),
              _buildEditableField('Full Name', fullNameController, true),
              _buildEditableField('Contact No', contactNoController, true),
              _buildEditableField('Email', emailController, true),
              _buildEditableField('Birth Date', birthController, true),
              _buildEditableField('Home Address', homeAddressController, true),
              _buildEditableField(
                  'Gender', TextEditingController(text: gender), false),
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

  Widget _buildEditableField(
      String label, TextEditingController controller, bool isEditable) {
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
        final TextEditingController currentPasswordController =
            TextEditingController();
        final TextEditingController newPasswordController =
            TextEditingController();
        final TextEditingController confirmPasswordController =
            TextEditingController();
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
                          showPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
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
                          showPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
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
                          showPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
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
