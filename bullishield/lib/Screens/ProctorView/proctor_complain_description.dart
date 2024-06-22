import 'dart:convert';
import 'package:bullishield/backend_config.dart';
import 'package:bullishield/Screens/ProctorView/proctor_complain.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProctorComplainDetails extends StatefulWidget {
  final ProctorComplain complain;

  const ProctorComplainDetails({super.key, required this.complain});

  @override
  // ignore: library_private_types_in_public_api
  _ProctorComplainDetailsState createState() => _ProctorComplainDetailsState();
}

class _ProctorComplainDetailsState extends State<ProctorComplainDetails> {
  bool isLoading = true;
  List<String> proofImages = [];
  List<String> bullyImages = [];
  TextEditingController proctorDecisionController = TextEditingController();
  String status = "Processing";
  bool isBullyGuilty = false;

  @override
  void initState() {
    super.initState();
    fetchComplainDetails();
  }

  Future<void> fetchComplainDetails() async {
    setState(() {
      isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');
    BackendConfiguration backend = BackendConfiguration();
    String backendMeta = backend.getBackendApiURL();

    var getComplainDetailsURL = "$backendMeta/get_complain_details/";

    try {
      final response = await http.post(
        Uri.parse(getComplainDetailsURL),
        body: json.encode({'complain_id': widget.complain.complainId}),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        setState(() {
          proofImages = responseData['proof_images'] != null
              ? List<String>.from(responseData['proof_images'])
              : [];
          bullyImages = responseData['bully_images'] != null
              ? List<String>.from(responseData['bully_images'])
              : [];
          proctorDecisionController.text = responseData['proctor_decision'] ?? "";
          status = responseData['complain_status'] ?? "Processing";
          isBullyGuilty = responseData['is_bully_guilty'] ?? false;
          isLoading = false;
        });
      } else {
        showErrorToast('Failed to fetch complain details');
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      print('Error fetching complain details: $error');
      showErrorToast('Failed to fetch complain details');
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

  void updateComplain() {
    // Implement the update logic here
    print('Update Complain');
  }

  void callMeeting() {
    // Implement the call meeting logic here
    print('Call Meeting');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Complain ID - ${widget.complain.complainId}"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        buildBooleanField(
                            "Validation",
                            widget.complain.complainValidation ? "Valid" : "Invalid",
                            widget.complain.complainValidation ? Colors.green : Colors.red),
                        buildBooleanField("Status", status, Colors.blue),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  buildBox(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildDetailText("Bully Name: ${widget.complain.bullyName}", isBold: true),
                        buildDetailText("Bully ID: ${widget.complain.bullyID}", isBold: true),
                        buildDetailText("Complainer: ${widget.complain.complainer}", isBold: true),
                        buildDetailText("Incident Date: ${widget.complain.incidentDate}"),
                        buildDetailText("Type: Complain Type", isBold: true),
                        buildDetailText("Description:", isBold: true),
                        const SizedBox(height: 8),
                        Text(widget.complain.complainDescription, style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  buildBox(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildDetailText("Proof Images:", isBold: true),
                        buildImageCarousel(proofImages, "No proof images available"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  buildBox(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildDetailText("Bully Images:", isBold: true),
                        buildImageCarousel(bullyImages, "No bully images available"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  buildBox(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildDetailText("Proctor Decision:", isBold: true),
                        const SizedBox(height: 8),
                        TextField(
                          controller: proctorDecisionController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Enter your decision',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  buildBox(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildDetailText("Is Bully Guilty?", isBold: true),
                        Row(
                          children: [
                            Radio(
                              value: true,
                              groupValue: isBullyGuilty,
                              onChanged: (bool? value) {
                                setState(() {
                                  isBullyGuilty = value ?? false;
                                });
                              },
                            ),
                            const Text("Guilty"),
                            Radio(
                              value: false,
                              groupValue: isBullyGuilty,
                              onChanged: (bool? value) {
                                setState(() {
                                  isBullyGuilty = value ?? false;
                                });
                              },
                            ),
                            const Text("Not Guilty"),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  buildBox(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildDetailText("Update Status", isBold: true),
                        const SizedBox(height: 8),
                        DropdownButton<String>(
                          value: status,
                          items: <String>['Processing', 'Validated', 'Completed']
                              .map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              status = newValue ?? status;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: updateComplain,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        child: const Text('Update Complain'),
                      ),
                      ElevatedButton(
                        onPressed: callMeeting,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: const Text('Call Meeting'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget buildBox({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget buildBooleanField(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget buildDetailText(String text, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: color ?? Colors.black,
        ),
      ),
    );
  }

  Widget buildImageCarousel(List<String> images, String emptyText) {
    return images.isNotEmpty
        ? Column(
            children: [
              const Text(
                "Swipe to view more",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              CarouselSlider(
                options: CarouselOptions(
                  height: 200.0,
                  enlargeCenterPage: true,
                  enableInfiniteScroll: false,
                ),
                items: images.map((imageUrl) {
                  return Builder(
                    builder: (BuildContext context) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FullScreenImage(imageUrl: imageUrl),
                            ),
                          );
                        },
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        (loadingProgress.expectedTotalBytes ?? 1)
                                    : null,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ],
          )
        : Text(emptyText);
  }
}

class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Image.network(imageUrl),
      ),
    );
  }
}