// import 'dart:convert';
// import 'dart:io';
// import 'package:bullishield/Screens/NavScreens/ComplainFormScreen.dart';
// import 'package:bullishield/Screens/Complain/complain.dart';
import 'package:bullishield/Screens/NavScreen/ComplainFormScreen.dart';
import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import '../../widgets/menu_drawer.dart';
// import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  State <HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    // User user = widget.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "BulliShield",
          textScaler: TextScaler.linear(1.2),
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        // child: RefreshIndicator(
        //   onRefresh: _refreshList, // Call the refresh function when pulling down the list
        //   child: (complainList.isNotEmpty)
        //       ? ListView.builder(
        //           itemCount: complainList.length,
        //           itemBuilder: (context, index) {
        //             Complain complain = complainList[index];
        //             return ListTile(
        //               title: Text("Complain Against: ${complain.bullyName}"),
        //               subtitle: Text("Complain Description: ${complain.complainDescription}"),
        //               onTap: () {
        //                 Navigator.push(
        //                   context,
        //                   MaterialPageRoute(
        //                     builder: (context) => ComplainDetailsScreen(complain: complain),
        //                   ),
        //                 );
        //               },
        //             );
        //           },
        //         )
        //       : Center(
        //           child: CircularProgressIndicator(),
        //         ),
        // ),
      ),
      drawer: const MyDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the Complain screen to create a new complain
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ComplainFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}