import 'dart:convert';
import 'package:bullishield/Screens/Complain/complain_details_screen.dart';
import 'package:bullishield/Screens/Meeting%20Schedules/meeting_schedules.dart';
import 'package:bullishield/complain.dart';
import 'package:bullishield/constants.dart';
import 'package:flutter/material.dart';
import 'package:bullishield/Screens/Login/login_screen.dart';
import 'package:bullishield/widgets/menu_drawer.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bullishield/backend_config.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class UserSchedules extends StatefulWidget {
  const UserSchedules({super.key});

  @override
  State<UserSchedules> createState() => UserSchedulesState();
}

class UserSchedulesState extends State<UserSchedules> {
  List<ScheduledMeetings> meetingList = [];
  List<ScheduledMeetings> filteredMeetingList = [];
  List<Complain> complainList = [];
  bool isLoading = true;
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchComplaints();
  }

  String meetingStatus(String dateTimeStr) {
    String meetingStatus = "";

    // Parse the input dateTime string to a DateTime object
    DateTime meetingDateTime = DateTime.parse(dateTimeStr);

    // Get the current date and time
    DateTime now = DateTime.now();

    // Check the meeting status based on the date and time
    if (meetingDateTime.isBefore(now)) {
      meetingStatus = "Over";
    } else if (meetingDateTime.year == now.year &&
        meetingDateTime.month == now.month &&
        meetingDateTime.day == now.day) {
      meetingStatus = "Today";
    } else {
      meetingStatus = "Upcoming";
    }

    return meetingStatus;
  }

  String dateFormatter(String dateTime) {
    // Parse the input dateTime string to a DateTime object
    DateTime parsedDateTime = DateTime.parse(dateTime);

    // Format the date part
    String formattedDate = DateFormat('dd-MM-yyyy').format(parsedDateTime);

    // Format the time part in 12-hour format
    String formattedTime = DateFormat('h:mm a').format(parsedDateTime);

    // Combine the formatted date and time
    String result = '$formattedDate, Time $formattedTime';

    return result;
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
            meetingList = List<ScheduledMeetings>.from(
                responseData['sceduled_meetings'].map((meetingData) {
              return ScheduledMeetings(
                complainID: meetingData['complain_id_id'].toString(),
                description: "Tap to view complain details",
                scheduledTime: dateFormatter(meetingData['meeting_time']),
                meetingMessage: meetingData['meeting_message'],
                status: meetingStatus(meetingData['meeting_time']),
              );
            }));
            complainList = List<Complain>.from(
                responseData['complain_details'].map((complainData) {
              return Complain.fromJson(complainData);
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
    } catch (error, trace) {
      print('Error fetching complaints: $error');
      print('Error fetching complaints: $trace');
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
      filteredMeetingList = filteredList;
    });
  }

  void filterByStatus(String status) {
    setState(() {
      filteredMeetingList = meetingList
          .where(
              (meeting) => meeting.status.toLowerCase() == status.toLowerCase())
          .toList();
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
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Search meetings...",
                  hintStyle: TextStyle(color: Colors.white),
                  border: InputBorder.none,
                ),
                onChanged: (query) => filterMeetingList(query),
              )
            : const Text(
                "Meeting Schedules",style: TextStyle(color: Colors.white),
                textScaler: TextScaler.linear(1),
              ),
              backgroundColor: kPrimaryColor,
        actions: [
          isSearching
              ? IconButton(
                  icon: const Icon(Icons.clear,color: Colors.white,),
                  onPressed: () {
                    setState(() {
                      isSearching = false;
                      searchController.clear();
                      filteredMeetingList = meetingList;
                    });
                  },
                )
              : Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.search,color: Colors.white,),
                      onPressed: () {
                        setState(() {
                          isSearching = true;
                        });
                      },
                    ),
                    PopupMenuButton<String>(
                      onSelected: filterByStatus,
                      iconColor: Colors.white,
                      itemBuilder: (BuildContext context) {
                        return {'Today', 'Upcoming', 'Over'}
                            .map((String choice) {
                          return PopupMenuItem<String>(
                            value: choice,
                            child: Text(choice),
                          );
                        }).toList();
                      },
                      icon: const Icon(Icons.filter_list),
                    ),
                  ],
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
                        // Ensure index is within range for both lists
                        if (index >= complainList.length || index >= filteredMeetingList.length) {
                          return const SizedBox.shrink(); // Or any other placeholder widget
                        }
                        Complain complain = complainList[index];
                        ScheduledMeetings meetings = filteredMeetingList[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ComplainDetailsScreen(complain: complain),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            "Complain ID: ${meetings.complainID}",
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 8),
                                        Text(
                                            "Scheduled on: ${meetings.scheduledTime}",
                                            style:
                                                const TextStyle(fontSize: 16)),
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
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue),
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

class ScheduledMeetings {
  final String complainID;
  final String description;
  final String scheduledTime;
  final String meetingMessage;
  final String status;

  ScheduledMeetings({
    required this.complainID,
    required this.description,
    required this.scheduledTime,
    required this.meetingMessage,
    required this.status,
  });
}
