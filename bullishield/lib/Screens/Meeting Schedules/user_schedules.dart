import 'dart:convert';
import 'package:bullishield/Screens/Complain/complain_details_screen.dart';
import 'package:bullishield/Screens/Meeting%20Schedules/meeting_schedules.dart';
import 'package:flutter/material.dart';
import 'package:bullishield/Screens/Login/login_screen.dart';
import 'package:bullishield/widgets/menu_drawer.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bullishield/backend_config.dart';
import 'package:fluttertoast/fluttertoast.dart';

class UserSchedules extends StatefulWidget {
  const UserSchedules({super.key});

  @override
  State<UserSchedules> createState() => UserSchedulesState();
}

class UserSchedulesState extends State<UserSchedules> {
  List<ScheduledMeetings> meetingList = [];
  List<ScheduledMeetings> filteredMeetingList = [];
  bool isLoading = true;
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchComplaints();
  }

  Future<void> fetchComplaints() async {
    setState(() {
      isLoading = true;
    });

    BackendConfiguration backend = BackendConfiguration();
    String backendApiURL = backend.getBackendApiURL();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    var getScheduledMeetingURL = "$backendApiURL/meeting/";
    try {
      final response = await http.get(
        Uri.parse(getScheduledMeetingURL),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var responseBody = response.body;
        if (responseBody.isNotEmpty) {
          var responseData = jsonDecode(responseBody);
          setState(() {
            meetingList = List<ScheduledMeetings>.from(responseData['sceduled_meetings'].map((meetingData) {
              return ScheduledMeetings(
                complainID: meetingData['complain_id_id'].toString(),
                description: "Tap to view complain details",
                scheduledTime: meetingData['meeting_time'],
                meetingMessage: meetingData['meeting_message'],
                status: "Upcoming",
              );
            }));
            filteredMeetingList = meetingList;
            isLoading = false;
          });
        }
      } else if (response.statusCode == 401 || response.statusCode == 400) {
        var responseData = jsonDecode(response.body);
        showErrorToast(responseData['msg']);
        Navigator.of(context).pop();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        showErrorToast('Failed to fetch complaints');
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      print('Error fetching complaints: $error');
      showErrorToast('Failed to fetch complaints');
      setState(() {
        isLoading = false;
      });
    }
  }

  void showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.grey[700],
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void filterMeetingList(String query) {
    List<ScheduledMeetings> filteredList = [];
    if (query.isNotEmpty) {
      filteredList = meetingList.where((meeting) {
        return meeting.complainID.toLowerCase().contains(query.toLowerCase()) ||
            meeting.scheduledTime.toLowerCase().contains(query.toLowerCase()) ||
            meeting.description.toLowerCase().contains(query.toLowerCase()) ||
            meeting.status.toLowerCase().contains(query.toLowerCase());
      }).toList();
    } else {
      filteredList = meetingList;
    }

    setState(() {
      meetingList = filteredList;
    });
  }

  Future<void> _refreshList() async {
    await fetchComplaints();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isSearching
            ? TextField(
                controller: searchController,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  hintText: "Search meetings...",
                  hintStyle: TextStyle(color: Colors.black),
                  border: InputBorder.none,
                ),
                onChanged: (query) => filterMeetingList(query),
              )
            : const Text(
                "Meeting Schedules",
                textScaler: TextScaler.linear(1.2),
              ),
        actions: [
          isSearching
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      isSearching = false;
                      searchController.clear();
                      filteredMeetingList = meetingList;
                    });
                  },
                )
              : IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      isSearching = true;
                    });
                  },
                ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshList,
              child: filteredMeetingList.isNotEmpty
                  ? ListView.builder(
                      itemCount: filteredMeetingList.length,
                      itemBuilder: (context, index) {
                        ScheduledMeetings meetings = filteredMeetingList[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: InkWell(
                            onTap: () {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) => ComplainDetailsScreen(complain: complain),
                              //   ),
                              // );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Complain ID: ${meetings.complainID}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 8),
                                        Text("Scheduled on: ${meetings.scheduledTime}", style: const TextStyle(fontSize: 16)),
                                        const SizedBox(height: 8),
                                        Text(
                                          "Complain Details: ${meetings.description}",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        meetings.status,
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : const Center(child: Text("No meeting schedules found")),
            ),
      drawer: const MyDrawer(),
    );
  }
}