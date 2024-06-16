import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../backend_config.dart';

class AuthManager {
  Future<bool> isAuthenticated() async {
    // get backend information
    BackendConfiguration backend = BackendConfiguration();
    String backendApiURL = backend.getBackendApiURL();

    // get token info from shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');
    if (token != null) {
      String checkLoginStatusUrl = "$backendApiURL/user/check_authentication/";
      final response = await http.get(
        Uri.parse(checkLoginStatusUrl),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return true;
      }
    }
    return false;
  }
}
