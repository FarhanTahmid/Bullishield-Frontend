import 'package:flutter/material.dart';

class ParentsMeeting extends StatefulWidget {
  const ParentsMeeting({super.key});

  @override
  _ParentsMeetingState createState() => _ParentsMeetingState();
}

class _ParentsMeetingState extends State<ParentsMeeting> {
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController meetingMessageController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

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

  void sendMeetingMessage() {
    // Implement your logic to send the meeting message
    String mobileNumber = mobileNumberController.text;
    String email = emailController.text;
    String meetingMessage = meetingMessageController.text;
    String date = selectedDate.toString();
    String time = selectedTime.toString();

    // Print the selected values (Replace with your logic)
    print('Mobile Number: $mobileNumber');
    print('Email: $email');
    print('Meeting Message: $meetingMessage');
    print('Date: $date');
    print('Time: $time');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parents Meeting'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Schedule a Meeting',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
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
                'Send Meeting Message:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: mobileNumberController,
                decoration: const InputDecoration(
                  labelText: 'Mobile Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: meetingMessageController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Meeting Message',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: sendMeetingMessage,
                  child: const Text('Send Meeting Message'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
