// ignore: file_names

import 'package:bullishield/constants.dart';
import 'package:flutter/material.dart';
import 'package:bullishield/widgets/complain_form.dart';

class ComplainFormScreen extends StatelessWidget {
  const ComplainFormScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: const Text('Complain Form',style: TextStyle(color: Colors.white),),
      ),
      body: const ComplainForm(),
    );
  }
}
