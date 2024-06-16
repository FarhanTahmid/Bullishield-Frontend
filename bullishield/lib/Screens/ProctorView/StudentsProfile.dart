import 'package:flutter/material.dart';

class StudentProfile extends StatelessWidget {
  const StudentProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 80,
              backgroundImage: AssetImage('assets/ProfilePicture.png'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Farhan Ishrak',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'ID: 123456',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            _buildProfileItem('Department', 'ECE'),
            const SizedBox(height: 8),
            _buildProfileItem('Email', 'farhanishrak@nsu.edu'),
            const SizedBox(height: 8),
            _buildProfileItem('Phone Number', '01 234 567 890'),
            const SizedBox(height: 8),
            _buildProfileItem('Address', '123 Street, Mohammadpur, Dhaka'),
            const SizedBox(height: 8),
            _buildProfileItem("Parent's Phone Number", '01 987 654 321'),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return Row(
      children: [
        Text(
          '$label:',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
