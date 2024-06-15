class BackendConfiguration {
  final bool debugStatus = true;

  String getBackendApiURL() {
    String apiMeta = "";
    if(debugStatus){
      // provide development backend
      apiMeta = "http://10.0.2.2:8000";
    }else{
      // provide production backend
      apiMeta = "https://api-prod.example.com";
    }
    return apiMeta;
  }
}
