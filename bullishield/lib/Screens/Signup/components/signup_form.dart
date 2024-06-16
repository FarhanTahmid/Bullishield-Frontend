import 'dart:convert';
import 'package:bullishield/Screens/Signup/signup_screen.dart';
import 'package:bullishield/backend_config.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import '../../../components/already_have_an_account_acheck.dart';
import '../../../constants.dart';
import '../../Login/login_screen.dart';
import 'package:http/http.dart' as http;

class SignUpForm extends StatefulWidget {
  const SignUpForm({
    super.key,
  });
  @override
  State<SignUpForm> createState() => SignupFormState();
}

class SignupFormState extends State<SignUpForm> {
  // Defining Controllers
  final userIdController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Loading..."),
              ],
            ),
          ),
        );
      },
    );
  }

  void signup() async {
    // Show loading dialog
    _showLoadingDialog(context);

    // get backend information
    BackendConfiguration backend = BackendConfiguration();
    String backendApiURL = backend.getBackendApiURL();

    // declare response variable
    http.Response response;

    // first check if two password matches
    if (passwordController.text.trim() == confirmPasswordController.text.trim()) {
      // declare backend URL for signup
      var signupUrl = "$backendApiURL/user/signup/";
      // Posting response to backend server
      try {
        response = await http.post(Uri.parse(signupUrl), body: {
          'username': userIdController.text.trim(),
          'password': passwordController.text.trim(),
          'email': emailController.text.trim()
        });

        // Hide loading dialog
        Navigator.of(context).pop();

        // Check status of the responses
        if (response.statusCode == 400) {
          final responseData = json.decode(response.body);
          Fluttertoast.showToast(
            msg: responseData['error'],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.grey[700],
            textColor: Colors.red,
            fontSize: 16.0,
          );
        } else if (response.statusCode == 201) {
          final responseData = json.decode(response.body);
          Fluttertoast.showToast(
            msg: responseData['success'],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.grey[700],
            textColor: const Color.fromARGB(255, 54, 244, 187),
            fontSize: 16.0,
          );
          // navigate to login page
          Navigator.push(context,MaterialPageRoute(builder: (context) => const LoginScreen()));
        } else if (response.statusCode == 406) {
          final responseData = json.decode(response.body);
          Fluttertoast.showToast(
            msg: responseData['error'],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.grey[700],
            textColor: Colors.red,
            fontSize: 16.0,
          );
        } else if (response.statusCode == 401) {
          final responseData = json.decode(response.body);
          Fluttertoast.showToast(
            msg: responseData['error'],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.grey[700],
            textColor: Colors.red,
            fontSize: 16.0,
          );
        }
      } catch (e) {
        // Hide loading dialog
        Navigator.of(context).pop();

        Fluttertoast.showToast(
          msg: "Please check your network connection and try again!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey[700],
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } else {
      // Hide loading dialog
      Navigator.of(context).pop();

      Fluttertoast.showToast(
        msg: "Two passwords did not match",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey[700],
        textColor: Colors.red,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          TextFormField(
            controller: userIdController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            cursorColor: kPrimaryColor,
            decoration: const InputDecoration(
              hintText: "User ID",
              prefixIcon: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Icon(Icons.person),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: defaultPadding),
            child: TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              cursorColor: kPrimaryColor,
              onSaved: (email) {},
              decoration: const InputDecoration(
                hintText: "Your email",
                prefixIcon: Padding(
                  padding: EdgeInsets.all(defaultPadding),
                  child: Icon(Icons.email),
                ),
              ),
            ),
          ),
          TextFormField(
            textInputAction: TextInputAction.done,
            controller: passwordController,
            obscureText: true,
            cursorColor: kPrimaryColor,
            decoration: const InputDecoration(
              hintText: "Your password",
              prefixIcon: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Icon(Icons.lock),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: defaultPadding),
            child: TextFormField(
              controller: confirmPasswordController,
              textInputAction: TextInputAction.done,
              obscureText: true,
              cursorColor: kPrimaryColor,
              decoration: const InputDecoration(
                hintText: "Confirm password",
                prefixIcon: Padding(
                  padding: EdgeInsets.all(defaultPadding),
                  child: Icon(Icons.lock),
                ),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding / 2),
          ElevatedButton(
            onPressed: signup,
            child: Text("Sign Up".toUpperCase()),
          ),
          const SizedBox(height: defaultPadding),
          RichText(
            text: TextSpan(
              text: "Already have an account? ",
              style: const TextStyle(color: Colors.black),
              children: <TextSpan>[
                TextSpan(
                  text: 'Login',
                  style: const TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
