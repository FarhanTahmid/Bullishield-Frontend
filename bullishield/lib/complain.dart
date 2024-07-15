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

  factory Complain.fromJson(Map<String, dynamic> json) {
    return Complain(
      complain_id: json['id'],
      bullyName: json['bully_name'],
      incidentDate: json['incident_date'],
      complainDescription: json['complain_description'],
      complainStatus: json['complain_status'],
    );
  }
  
}