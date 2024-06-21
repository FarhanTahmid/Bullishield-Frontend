import 'dart:convert';
import 'package:bullishield/Screens/Homepage/homepage.dart';
import 'package:bullishield/constants.dart';
import 'package:flutter/material.dart';
import 'package:bullishield/widgets/menu_drawer.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bullishield/backend_config.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:bullishield/Screens/ProctorView/proctor_complain.dart';
// import 'package:bullishield/Screens/ProctorView/proctor_complain_description.dart';

class ProctorHomepage extends StatefulWidget {
  const ProctorHomepage({super.key});

  @override
  State<ProctorHomepage> createState() => ProctorHomepageState();
}

class ProctorHomepageState extends State<ProctorHomepage> {
  List<ProctorComplain> complainList = [];
  List<ProctorComplain> filteredComplainList = [];
  String organizationName = "";
  bool isLoading = true;
  bool isSearching = false;
  String selectedStatus = "All";
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

    var getComplainURL = "$backendApiURL/get_proctor_complains/";
    try {
      final response = await http.post(
        Uri.parse(getComplainURL),
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
            organizationName = responseData['organization_name'];
            complainList = List<ProctorComplain>.from(
                responseData['complain_list'].map((complainData) {
              return ProctorComplain(
                  complainId: complainData['id'],
                  bullyName: complainData['bully_name'],
                  bullyID: complainData['bully_id'],
                  complainer: complainData['complainer'],
                  incidentDate: complainData['incident_date'],
                  complainDescription: complainData['complain_description'],
                  complainStatus: complainData['complain_status'],
                  complainValidation: complainData['complain_validation']
                      ? "Valid"
                      : "Invalid",
                  guilty: complainData['guilty'] ? "Guilty" : "Not Guilty",
                  proctorDecision: complainData['proctor_decision']);
            }));
            filteredComplainList = complainList;
            isLoading = false;
          });
        }
      } else if (response.statusCode == 401 || response.statusCode == 404) {
        var responseData = jsonDecode(response.body);
        showErrorToast(responseData['msg']);
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();
        Navigator.push(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        showErrorToast('Failed to fetch complaints');
        setState(() {
          isLoading = false;
        });
      }
    } catch (error, stacktrace) {
      print('Error fetching complaints: $error and $stacktrace');
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

  void filterComplaints(String query) {
    List<ProctorComplain> filteredList = complainList.where((complain) {
      bool matchesSearch = complain.bullyName
              .toLowerCase()
              .contains(query.toLowerCase()) ||
          complain.complainId.toString().toLowerCase().contains(query.toLowerCase()) ||
          complain.bullyID.toLowerCase().contains(query.toLowerCase()) ||
          complain.complainDescription.toLowerCase().contains(query.toLowerCase()) ||
          complain.complainStatus.toLowerCase().contains(query.toLowerCase());
      bool matchesStatus = selectedStatus == "All" ||
          complain.complainStatus.toLowerCase() == selectedStatus.toLowerCase();
      return matchesSearch && matchesStatus;
    }).toList();

    setState(() {
      filteredComplainList = filteredList;
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
                  hintText: "Search...",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
                onChanged: (query) => filterComplaints(query),
              )
            : Text(
                organizationName,
                textScaler: const TextScaler.linear(1.2),
              ),
        actions: [
          isSearching
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      isSearching = false;
                      searchController.clear();
                      filteredComplainList = complainList;
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
          PopupMenuButton<String>(
            onSelected: (String value) {
              setState(() {
                selectedStatus = value;
                filterComplaints(searchController.text);
              });
            },
            itemBuilder: (BuildContext context) {
              return ["All", "Processing", "Validated", "Completed"].map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshList,
              child: filteredComplainList.isNotEmpty
                  ? ListView.builder(
                      itemCount: filteredComplainList.length,
                      itemBuilder: (context, index) {
                        ProctorComplain complain = filteredComplainList[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          child: InkWell(
                            onTap: () {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) => ProctorComplainDescription(
                              //       complain: complain,
                              //     ),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            "Complain ID: ${complain.complainId}",
                                            style: const TextStyle(
                                                fontSize: 18,
                                                color: kPrimaryColor,
                                                fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 8),
                                        Text(
                                            "Complain Against: ${complain.bullyName} - ${complain.bullyID}",
                                            style: const TextStyle(
                                                fontSize: 18,
                                                color: Color.fromARGB(
                                                    255, 230, 109, 109),
                                                fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 8),
                                        Text("Status: ${complain.complainStatus}",
                                            style:
                                                const TextStyle(fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blue),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "Description: ${complain.complainDescription}",
                                          style: const TextStyle(
                                            fontSize: 14,

                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : const Center(child: Text("No complaints found")),
            ),
      drawer: const MyDrawer(),
    );
  }
}
