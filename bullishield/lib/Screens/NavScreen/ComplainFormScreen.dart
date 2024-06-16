// ignore: file_names

import 'package:flutter/material.dart';
import 'package:bullishield/widgets/complain_form.dart';

class ComplainFormScreen extends StatelessWidget {
  const ComplainFormScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complain Form'),
      ),
      body: const ComplainForm(),
    );
  }
}
