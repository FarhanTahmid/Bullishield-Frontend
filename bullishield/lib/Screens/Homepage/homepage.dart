import 'dart:convert';
import 'package:bullishield/Screens/Complain/complain_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:bullishield/Screens/NavScreen/ComplainFormScreen.dart';
import 'package:bullishield/Screens/Login/login_screen.dart';
import 'package:bullishield/widgets/menu_drawer.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bullishield/backend_config.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:bullishield/complain.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Complain> complainList = [];
  List<Complain> filteredComplainList = [];
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

    var getComplainURL = "$backendApiURL/get_user_complains/";
    try {
      final response = await http.post(
        Uri.parse(getComplainURL),
        body: json.encode({'user_id': '202020'}),
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
            complainList = List<Complain>.from(responseData['complain_list'].map((complainData) {
              return Complain(
                complain_id: complainData['id'],
                bullyName: complainData['bully_name'],
                incidentDate: complainData['incident_date'],
                complainDescription: complainData['complain_description'],
                complainStatus: complainData['complain_status'],
              );
            }));
            filteredComplainList = complainList;
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

  void filterComplaints(String query) {
    List<Complain> filteredList = [];
    if (query.isNotEmpty) {
      filteredList = complainList.where((complain) {
        return complain.bullyName.toLowerCase().contains(query.toLowerCase()) ||
            complain.incidentDate.toLowerCase().contains(query.toLowerCase()) ||
            complain.complainDescription.toLowerCase().contains(query.toLowerCase()) ||
            complain.complainStatus.toLowerCase().contains(query.toLowerCase());
      }).toList();
    } else {
      filteredList = complainList;
    }

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
                  hintText: "Search complaints...",
                  hintStyle: TextStyle(color: Colors.black),
                  border: InputBorder.none,
                ),
                onChanged: (query) => filterComplaints(query),
              )
            : const Text(
                "BulliShield",
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
                        Complain complain = filteredComplainList[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Bully: ${complain.bullyName}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 8),
                                        Text("Date: ${complain.incidentDate}", style: const TextStyle(fontSize: 16)),
                                        const SizedBox(height: 8),
                                        Text(
                                          "Description: ${complain.complainDescription}",
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
                                        complain.complainStatus,
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
                  : const Center(child: Text("No complaints found")),
            ),
      drawer: const MyDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
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