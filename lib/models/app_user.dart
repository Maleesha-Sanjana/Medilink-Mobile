class AppUser {
  final String uid;
  final String email;
  final String role; // "patient" | "emt" | "admin"
  final String? displayName;
  final String? phone;

  const AppUser({
    required this.uid,
    required this.email,
    required this.role,
    this.displayName,
    this.phone,
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    return AppUser(
      uid: uid,
      email: map['email'] ?? '',
      role: map['role'] ?? 'patient',
      displayName: map['displayName'],
      phone: map['phone'],
    );
  }

  Map<String, dynamic> toMap() => {
    'email': email,
    'role': role,
    if (displayName != null) 'displayName': displayName,
    if (phone != null) 'phone': phone,
  };
}
