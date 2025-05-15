class PigeonUserDetails {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;

  PigeonUserDetails({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
  });

  factory PigeonUserDetails.fromJson(Map<String, dynamic> json) {
    return PigeonUserDetails(
      uid: json['uid'] ?? json['userId'],
      email: json['email'],
      displayName: json['displayName'] ?? json['name'],
      photoUrl: json['photoUrl'],
    );
  }

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'email': email,
    'displayName': displayName,
    'photoUrl': photoUrl,
  };
}