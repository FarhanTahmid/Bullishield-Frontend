class ProctorComplain {
  final int complainId;
  final String complainer;
  final String bullyName;
  final String bullyID;

  final String incidentDate;
  final String complainDescription;
  final bool complainValidation;
  final String complainStatus;
  final String proctorDecision;
  final String guilty;

  ProctorComplain({
    required this.complainId,
    required this.bullyName,
    
    required this.complainer,
    required this.bullyID,

    required this.incidentDate,
    required this.complainValidation,
    required this.complainDescription,
    required this.complainStatus,
    required this.proctorDecision,
    required this.guilty,
  });
}
