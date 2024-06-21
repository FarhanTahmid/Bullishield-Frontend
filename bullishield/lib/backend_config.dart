class BackendConfiguration {
  final bool debugStatus = true;

  String getBackendApiURL() {
    String apiMeta = "";
    if(debugStatus){
      // provide development backend
      apiMeta = "http://192.168.0.123:8000";
    }else{
      // provide production backend
      apiMeta = "https://api-prod.example.com";
    }
    return apiMeta;
  }
}
