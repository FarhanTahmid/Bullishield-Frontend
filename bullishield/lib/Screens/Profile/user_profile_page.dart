import 'dart:convert';
import 'dart:io';
import 'package:bullishield/Screens/Login/login_screen.dart';
import 'package:bullishield/backend_config.dart';
import 'package:bullishield/toasts.dart';
import 'package:bullishield/user_info.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool isLoading = false;

  UserInfo userInfo = UserInfo();
  ShowToasts toasts = ShowToasts();
  BackendConfiguration backend = BackendConfiguration();

  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  Future<void> getUserInfo() async {
    setState(() {
      isLoading = true;
    });

    String backendApiURL = backend.getBackendApiURL();
    // function to get user informations and set the fields up
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
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateProfile() async {
    setState(() {
      isLoading = true;
    });

    String backendApiURL = backend.getBackendApiURL();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    String userInfoUpdateURL = '$backendApiURL/user/user_profile_update/';
    try {
      final response = await http.post(
        Uri.parse(userInfoUpdateURL),
        body: json.encode({
          'full_name': fullNameController.text,
          'contact_no': contactNoController.text,
          'email_address': emailController.text,
          'home_address': homeAddressController.text
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      var responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          isLoading = false;
        });
        toasts.showSuccessToast(responseData['msg']);
      } else if (response.statusCode == 401) {
        setState(() {
          isLoading = false;
        });
        toasts.showErrorToast(responseData['msg']);
        Navigator.pop(context as BuildContext);
        Navigator.push(
          context as BuildContext,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else if (response.statusCode == 404) {
        setState(() {
          isLoading = false;
        });
        toasts.showErrorToast(responseData['msg']);
        Navigator.pop(context as BuildContext);
        Navigator.push(
          context as BuildContext,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (error, traceback) {
      setState(() {
        isLoading = false;
      });
      toasts.showErrorToast('Something went wrong! Try again.');
      Navigator.pop(context as BuildContext);
      print(error);
      print(traceback);
    }
  }

  Future<void> changeProfilePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        isLoading = true;
      });

      File imageFile = File(pickedFile.path);
      String backendApiURL = backend.getBackendApiURL();
      String uploadURL = '$backendApiURL/user/upload_profile_picture/';
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      var request = http.MultipartRequest('POST', Uri.parse(uploadURL));
      request.files.add(await http.MultipartFile.fromPath(
          'picture', imageFile.path,
          filename: basename(imageFile.path)));
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        var responseData = json.decode(responseBody);
        String newImageUrl = responseData['new_picture'];
        setState(() {
          userImageUrl = backendApiURL + newImageUrl;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        // Handle error
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
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
                          onPressed: changeProfilePicture,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Organization ID: $organizationID",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildEditableField('Full Name', fullNameController, true),
                  _buildEditableField('Contact No', contactNoController, true),
                  _buildEditableField('Email', emailController, true),
                  _buildEditableField(
                      'Home Address', homeAddressController, true),
                  _buildEditableField(
                      'Gender', TextEditingController(text: gender), false),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: updateProfile,
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
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
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
