import 'dart:convert';
import 'dart:io';
import 'package:bullishield/Screens/Login/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bullishield/backend_config.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:bullishield/user_info.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;

class ComplainForm extends StatefulWidget {
  const ComplainForm({super.key});

  @override
  State<ComplainForm> createState() => ComplainFormState();
}

class ComplainFormState extends State<ComplainForm> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _bullyNameController = TextEditingController();
  final TextEditingController _bullyIdController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  List<File> _images = [];
  List<File> _bullyImage = [];
  String? _selectedHarassmentType;

  Future<void> _getImages() async {
    // Windows-specific image capturing
    if (Platform.isWindows) {
      final filePickerResult = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );

      if (filePickerResult != null) {
        final pickedFiles =
            filePickerResult.paths.map((path) => File(path!)).toList();
        setState(() {
          _images.addAll(pickedFiles);
        });
      }
    } else {
      final picker = ImagePicker();
      final pickedImages = await picker.pickMultiImage();
      setState(() {
        _images =
            pickedImages.map((pickedImage) => File(pickedImage.path)).toList();
      });
    }
  }

  Future<void> _getBullyImages() async {
    // Windows-specific image capturing
    if (Platform.isWindows) {
      final filePickerResult = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );

      if (filePickerResult != null) {
        final pickedFiles =
            filePickerResult.paths.map((path) => File(path!)).toList();
        setState(() {
          _bullyImage.addAll(pickedFiles);
        });
      }
    } else {
      final picker = ImagePicker();
      final pickedImages = await picker.pickMultiImage();

      setState(() {
        _bullyImage =
            pickedImages.map((pickedImage) => File(pickedImage.path)).toList();
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<List<String>> getHarassmentTypes() async {
    final List<String> harassmentTypes = [];
    BackendConfiguration backend = BackendConfiguration();
    String backendMeta = backend.getBackendApiURL();

    final response =
        await http.get(Uri.parse('$backendMeta/get_complain_type/'));
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      jsonResponse['types'].forEach((key, value) {
        harassmentTypes.add(value);
      });
    } else if (response.statusCode == 404) {
      if (Platform.isAndroid) {
        Fluttertoast.showToast(
          msg: "Cannot load Complain types",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: const Color.fromARGB(255, 228, 215, 215),
          textColor: Colors.red,
          fontSize: 16.0,
        );
      } else if (Platform.isWindows) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Cannot load Complain types!"),
        ));
      }
    }
    return harassmentTypes;
  }

  void complainRegistration(String bullyName, String bullyId,
      String incidentDate, String description, String? harassmentType) async {
    BackendConfiguration backend = BackendConfiguration();
    String backendMeta = backend.getBackendApiURL();
    String postComplainUrl = '$backendMeta/register_complain/';

    UserInfo userInfo = UserInfo();
    Map<String, dynamic>? userDetails = await userInfo.getUsername();

    if (userDetails != null) {
      String userId = userDetails['user_id'];
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      var request = http.MultipartRequest('POST', Uri.parse(postComplainUrl));
      request.fields['complainer_id'] = userId;
      request.fields['bully_name'] = bullyName;
      request.fields['bully_id'] = bullyId;
      request.fields['incident_date'] = incidentDate;
      request.fields['complain_description'] = description;
      request.fields['harassment_type'] = harassmentType ?? '';

      for (var image in _images) {
        var stream = http.ByteStream(image.openRead());
        var length = await image.length();
        var multipartFile = http.MultipartFile(
          'image_proves',
          stream,
          length,
          filename: path.basename(image.path),
        );
        request.files.add(multipartFile);
      }

      for (var image in _bullyImage) {
        var stream = http.ByteStream(image.openRead());
        var length = await image.length();
        var multipartFile = http.MultipartFile(
          'bully_image',
          stream,
          length,
          filename: path.basename(image.path),
        );
        request.files.add(multipartFile);
      }

      request.headers['Authorization'] = 'Bearer $token';

      try {
        var response = await request.send();
        var responseBody = await response.stream.bytesToString();
        var responseData = json.decode(responseBody);

        if (response.statusCode == 200) {
          if (Platform.isAndroid) {
            Fluttertoast.showToast(
              msg: responseData['msg'],
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.grey[700],
              textColor: Colors.green[400],
              fontSize: 16.0,
            );
          } else if (Platform.isWindows) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(responseData['msg']),
            ));
          }
          // get off from the page
          Navigator.pop(context);
        } else if (response.statusCode == 403) {
          if (Platform.isAndroid) {
            Fluttertoast.showToast(
              msg: responseData['msg'],
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.grey[700],
              textColor: Colors.red,
              fontSize: 16.0,
            );
          } else if (Platform.isWindows) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(responseData['msg']),
            ));
          }
        } else if (response.statusCode == 424) {
          if (Platform.isAndroid) {
            Fluttertoast.showToast(
              msg: responseData['msg'],
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.grey[700],
              textColor: Colors.red,
              fontSize: 16.0,
            );
          } else if (Platform.isWindows) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(responseData['msg']),
            ));
          }
        } else {
          if (Platform.isAndroid) {
            Fluttertoast.showToast(
              msg: "Something went wrong! Please try again later.",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.grey[700],
              textColor: Colors.red,
              fontSize: 16.0,
            );
          } else if (Platform.isWindows) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Something went wrong! Please try again later."),
            ));
          }
        }
      } catch (e) {
        if (Platform.isAndroid) {
          Fluttertoast.showToast(
            msg: "$e",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.grey[700],
            textColor: Colors.red,
            fontSize: 16.0,
          );
        } else if (Platform.isWindows) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content:
                Text("Please check your internet connection and try again!"),
          ));
        }
      }
    } else {
      if (Platform.isAndroid) {
        Fluttertoast.showToast(
          msg: "Please try to login again!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey[700],
          textColor: Colors.red,
          fontSize: 16.0,
        );
      } else if (Platform.isWindows) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please try to login again!"),
        ));
      }
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchHarassmentTypes();
  }

  Future<void> fetchHarassmentTypes() async {
    try {
      setState(() {});
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _bullyNameController.dispose();
    _bullyIdController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16.0),
            const Text(
              'Bully Details',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _bullyNameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _bullyIdController,
              decoration: const InputDecoration(labelText: 'ID'),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Incident Details',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 8.0),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: TextField(
                  controller: _dateController,
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
              ),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Select Harassment Type',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 8.0),
            FutureBuilder<List<String>>(
              future: getHarassmentTypes(),
              builder:
                  (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  List<String> harassmentTypes = snapshot.data ?? [];
                  return DropdownButtonFormField<String>(
                    value: _selectedHarassmentType,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedHarassmentType = newValue;
                      });
                    },
                    items: harassmentTypes.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    decoration: const InputDecoration(
                      labelText: 'Select Type',
                      border: OutlineInputBorder(),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Upload Evidence',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: _getImages,
              child: const Text('Select Images'),
            ),
            const SizedBox(height: 8.0),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              children: List.generate(_images.length, (index) {
                File image = _images[index];
                return Image.file(image);
              }),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Upload Bully Images',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: _getBullyImages,
              child: const Text('Select Bully Images'),
            ),
            const SizedBox(height: 8.0),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              children: List.generate(_bullyImage.length, (index) {
                File image = _bullyImage[index];
                return Image.file(image);
              }),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                if (_bullyNameController.text.isEmpty ||
                    _bullyIdController.text.isEmpty ||
                    _dateController.text.isEmpty ||
                    _descriptionController.text.isEmpty) {
                  if (Platform.isAndroid) {
                    Fluttertoast.showToast(
                      msg: 'Please fill all the fields and select images',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                    );
                  } else if (Platform.isWindows) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content:
                          Text("Please fill all the fields and select images"),
                    ));
                  }
                } else {
                  complainRegistration(
                    _bullyNameController.text,
                    _bullyIdController.text,
                    _dateController.text.trim(),
                    _descriptionController.text,
                    _selectedHarassmentType,
                  );
                }
              },
              child: const Text('Submit'),
            ),
            TextButton(
              onPressed: () {
                _bullyNameController.clear();
                _bullyIdController.clear();
                _dateController.clear();
                _descriptionController.clear();
                setState(() {
                  _images = [];
                  _bullyImage = [];
                  _selectedHarassmentType = null;
                });
              },
              child: const Text('Reset'),
            ),
          ],
        ),
      ),
    );
  }
}
