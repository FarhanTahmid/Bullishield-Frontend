// ignore: file_names
import 'dart:convert';

import 'package:bullishield/Screens/Login/login_screen.dart';
import 'package:bullishield/Screens/ProctorView/proctor_complain.dart';
import 'package:bullishield/backend_config.dart';
import 'package:bullishield/toasts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MeetingCallPage extends StatefulWidget {
  final ProctorComplain complain;
  const MeetingCallPage({super.key, required this.complain});

  @override
  // ignore: library_private_types_in_public_api
  MeetingPageState createState() => MeetingPageState();
}

class MeetingPageState extends State<MeetingCallPage> {
  ShowToasts toast = ShowToasts();
  TextEditingController complainerContactNoController = TextEditingController();
  TextEditingController complainerEmailController = TextEditingController();
  TextEditingController bullyContactNoController = TextEditingController();
  TextEditingController bullyEmailController = TextEditingController();
  TextEditingController meetingMessageController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    getComplainerandBullyInfo();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2021),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (pickedTime != null && pickedTime != selectedTime) {
      setState(() {
        selectedTime = pickedTime;
      });
    }
  }

  Future<void> getComplainerandBullyInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');
    BackendConfiguration backend = BackendConfiguration();
    String backendMeta = backend.getBackendApiURL();

    var meetingTaskURL = '$backendMeta/meeting/';
    try {
      final response = await http.post(
        Uri.parse(meetingTaskURL),
        body: json.encode({
          'task': 'meeting_setup',
          'complain_id': widget.complain.complainId
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      var responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          complainerContactNoController.text =
              responseData['complainer_contact_no'];
          complainerEmailController.text = responseData['complainer_email'];
          bullyContactNoController.text = responseData['bully_contact_no'];
          bullyEmailController.text = responseData['bully_email'];
        });
        toast.showSuccessToast(responseData['msg']);
      } else if (response.statusCode == 401) {
        toast.showErrorToast(responseData['msg']);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else if (response.statusCode == 404) {
        toast.showErrorToast(responseData['msg']);
        Navigator.pop(context);
      } else {
        toast.showErrorToast("Internal server error occured!");
      }
    } catch (error) {
      toast.showErrorToast("Something went wrong! Please try again");
      Navigator.pop(context);
    }
  }

  Future<void> scheduleMeeting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');
    BackendConfiguration backend = BackendConfiguration();
    String backendMeta = backend.getBackendApiURL();

    var meetingTaskURL = '$backendMeta/meeting/';

    try {
      final response = await http.post(
        Uri.parse(meetingTaskURL),
        body: json.encode({
          'task': 'call_meeting',
          'complain_id': widget.complain.complainId,
          'meeting_time':'${selectedDate.year}-${selectedDate.month}-${selectedDate.day} ${selectedTime.hour}:${selectedTime.minute}',
          'meeting_message':meetingMessageController.text,
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      var responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        // something
        print("hello");
      } else if (response.statusCode == 401) {
        toast.showErrorToast(responseData['msg']);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else if (response.statusCode == 404) {
        toast.showErrorToast(responseData['msg']);
        Navigator.pop(context);
      } else {
        toast.showErrorToast("Internal server error occured!");
      }
    } catch (error, traceback) {
      print(error);
      print(traceback);
      toast.showErrorToast("Something went wrong! Please try again");
      Navigator.pop(context);
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Meeting'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select Date and Time:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => _selectDate(context),
                              child: Text(
                                'Date: ${selectedDate.toString().substring(0, 10)}',
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextButton(
                              onPressed: () => _selectTime(context),
                              child: Text(
                                'Time: ${selectedTime.format(context)}',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Complainer Contact Info:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: complainerContactNoController,
                decoration: const InputDecoration(
                  labelText: 'Complainer Mobile Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: complainerEmailController,
                decoration: const InputDecoration(
                  labelText: 'Complainer Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Bully Contact Info:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: bullyContactNoController,
                decoration: const InputDecoration(
                  labelText: 'Bully Mobile Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: bullyEmailController,
                decoration: const InputDecoration(
                  labelText: 'Bully Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Meeting Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: meetingMessageController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Meeting Message',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: scheduleMeeting,
                  child: const Text('Schedule Meeting'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
