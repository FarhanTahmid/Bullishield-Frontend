import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../backend_config.dart';

class UserInfo {
  Future<Map<String, dynamic>?> getUsername() async {
    // get backend information
    BackendConfiguration backend = BackendConfiguration();
    String backendApiURL = backend.getBackendApiURL();

    // get token info from shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');
    if (token != null) {
      String getUserInfoURL = "$backendApiURL/user/user_info/";
      final response = await http.get(
        Uri.parse(getUserInfoURL),
        headers: {'Authorization': 'Bearer $token'},
      );

      var responseData = json.decode(response.body);
      var userInfo = responseData['user_info'];
      if (response.statusCode == 200) {
        return userInfo;
      }
    }
    return null;
  }
}
