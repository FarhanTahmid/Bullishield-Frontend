import 'dart:convert';
import 'package:bullishield/backend_config.dart';
import 'package:bullishield/complain.dart';
import 'package:bullishield/constants.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ComplainDetailsScreen extends StatefulWidget {
  final Complain complain;

  const ComplainDetailsScreen({super.key, required this.complain});

  @override
  // ignore: library_private_types_in_public_api
  _ComplainDetailsScreenState createState() => _ComplainDetailsScreenState();
}

class _ComplainDetailsScreenState extends State<ComplainDetailsScreen> {
  BackendConfiguration backend = BackendConfiguration();

  bool isLoading = true;
  List<String> proofImages = [];
  List<String> bullyImages = [];

  String organizationName = "";
  bool complainValidation = false;
  String complainType = "";
  String proctorDecision = "";
  String bullyID = "";

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
    String backendApiURL = backend.getBackendApiURL();

    var getComplainDetailsURL = "$backendApiURL/get_complain_details/";

    try {
      final response = await http.post(
        Uri.parse(getComplainDetailsURL),
        body: json.encode({'complain_id': widget.complain.complain_id}),
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
          bullyID = responseData['bully_id'] ?? "";
          organizationName = responseData['organization_name'] ?? "";
          complainValidation = responseData['complain_cyberBullying_flag_validation'] ?? false;
          complainType = responseData['complain_type'] ?? "";
          proctorDecision = responseData['proctor_decision'] ?? "";
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

  void showImageViewer(List<String> images, int initialIndex) {
    String backendApiURL=backend.getBackendApiURL();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Image View',style: TextStyle(color: Colors.white),),
            backgroundColor: kPrimaryColor,
          ),
          body: PhotoViewGallery.builder(
            itemCount: images.length,
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage('$backendApiURL${images[index]}'),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
              );
            },
            scrollPhysics: const BouncingScrollPhysics(),
            backgroundDecoration: const BoxDecoration(
              color: Colors.black,
            ),
            pageController: PageController(initialPage: initialIndex),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Complain Details",style: TextStyle(color: Colors.white)),
        backgroundColor: kPrimaryColor,
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
                        buildBooleanField("Validation",
                            complainValidation ? "Flagged Bullying" : "Invalid Complain",
                            complainValidation ? Colors.red : Colors.green),
                        buildBooleanField("Status", widget.complain.complainStatus,
                            Colors.blue),
                        buildBooleanField("Bully Guilty?",
                            isBullyGuilty ? "Yes" : "No",
                            isBullyGuilty ? Colors.red : Colors.green),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  buildBox(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildDetailText("Bully Name: ${widget.complain.bullyName}",
                            isBold: true),
                        buildDetailText("Organization: $organizationName",
                            isBold: true),
                        buildDetailText("Bully ID: $bullyID", isBold: true),
                        buildDetailText("Complain Type: $complainType", isBold: true),
                        buildDetailText("Date: ${widget.complain.incidentDate}"),
                        buildDetailText("Description:", isBold: true),
                        const SizedBox(height: 8),
                        Text(widget.complain.complainDescription,
                            style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  buildBox(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildDetailText("Proof Images:", isBold: true),
                        if (proofImages.length > 1)
                          const Text(
                            "Swipe to view more",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
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
                        if (bullyImages.length > 1)
                          const Text(
                            "Swipe to view more",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
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
                        Text(proctorDecision, style: const TextStyle(fontSize: 16)),
                      ],
                    ),
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
    String backendApiURL=backend.getBackendApiURL();
    return images.isNotEmpty
        ? Column(
            children: [
              CarouselSlider.builder(
                options: CarouselOptions(
                  height: 200.0,
                  enlargeCenterPage: true,
                  enableInfiniteScroll: false,
                ),
                itemCount: images.length,
                itemBuilder: (context, index, realIndex) {
                  return GestureDetector(
                    onTap: () => showImageViewer(images, index),
                    child: Image.network(
                      '$backendApiURL${images[index]}',
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
              ),
            ],
          )
        : Text(emptyText);
  }
}
