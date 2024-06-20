import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:bullishield/Screens/NavScreen/ComplainFormScreen.dart';
import 'package:bullishield/Screens/Login/login_screen.dart';
import 'package:bullishield/widgets/menu_drawer.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bullishield/backend_config.dart';
import 'package:bullishield/user_info.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Complain> complainList = [];
  bool isLoading = true;

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
          isLoading = false;
        });
        }
        
      }else if(response.statusCode==401){
          var responseData = jsonDecode(response.body);
          showErrorToast(responseData['msg']);
          Navigator.of(context).pop();
          // Navigate to homepage or another screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
      }else if(response.statusCode==400){
          var responseData = jsonDecode(response.body);
          showErrorToast(responseData['msg']);
          Navigator.of(context).pop();
          // Navigate to homepage or another screen
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

  Future<void> _refreshList() async {
    await fetchComplaints();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "BulliShield",
          textScaler: TextScaler.linear(1.2),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshList,
              child: complainList.isNotEmpty
                  ? ListView.builder(
                      itemCount: complainList.length,
                      itemBuilder: (context, index) {
                        Complain complain = complainList[index];
                        return ListTile(
                          title: Text("Bully: ${complain.bullyName}"),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Date: ${complain.incidentDate}"),
                              Text("Status: ${complain.complainStatus}"),
                              Text(
                                "Description: ${complain.complainDescription}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          onTap: () {
                            // Navigate to the Complain Details Screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ComplainDetailsScreen(complain: complain),
                              ),
                            );
                          },
                        );
                      },
                    )
                  : const Center(child: Text("No complaints found")),
            ),
      drawer: const MyDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the Complain Form Screen to create a new complain
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

class Complain {
  final int complain_id;
  final String bullyName;
  final String incidentDate;
  final String complainDescription;
  final String complainStatus;

  Complain({
    required this.complain_id,
    required this.bullyName,
    required this.incidentDate,
    required this.complainDescription,
    required this.complainStatus,
  });
}

class ComplainDetailsScreen extends StatelessWidget {
  final Complain complain;

  const ComplainDetailsScreen({Key? key, required this.complain})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Complain Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Bully: ${complain.bullyName}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text("Date: ${complain.incidentDate}",
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text("Status: ${complain.complainStatus}", style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text("Description:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(complain.complainDescription, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
